#!/usr/bin/bash

usage (){
		printf -- " iMobile Carrier-Bundles Manager 1.0
 - Licensed: GPL-2.0 License
 - Credits:
    iMobile CarrierBundles Manager: cfbm, https://github.com/mast3rz3ro/imobilecfbm
    PLIST parser: plget, https://github.com/kallewoof/plget
    PLIST converter: libplist, https://github.com/libimobiledevice/libplist
    Device communication: libimobiledevice, https://github.com/libimobiledevice/libimobiledevice

 - Usage: cfbm [options]
 - Parameters:
    -i input file/dir (throwing anything is OK)
    -o output directory
    -u update local carrier-bundles db
    -d download carrier bundle
    -c use stored carrier-bundle names
    -p payload name: 0 = Bundle Name (default)
        1 = default.bundle 3 = unknown.bundle
        2 = Default.bundle 4 = Unknown.bundle
    -s install carrier bundle from local db

 - Examples:
    Update local database and check latest carrier bundles available for download:
     cfbm -u -d -p
    Idenify the carrier bundle from local storage and repack it:
     cfbm -i 'file.ipcc' 'folder_contains_ipcc' 'folder_contains_ipcc_files'
    Search and Install a carrier bundle matches the connected device bundle version:
     cfbm -s
    Search and Install a valid carrier bundle with 'default.bundle' payload name:
     cfbm -s -p 1
"
exit 1
}

set_config (){
		# Check platform and set required tools
#if [ ! -s './depcontainer/tools/initdep' ]; then
#		printf -- "- Checking for dependancy ..."
		platform=$(uname | tr '[:upper:]' '[:lower:])
		arch=$(uname -m')
	if [[ "$platform" = 'MSYS'* ]] || [[ "$platform" = 'MINGW'* ]]; then
		platform='windows'
	fi
		dep='ideviceinfo ideviceinstaller plget plistutil'
		#dep='ideviceinfo ideviceinstaller idevicepair plget plistutil'
for d in $dep; do
	if [[ "$(which $d)" = *"$d" ]]; then
		export declare $d="$d"
	elif [ -s "depcontainer/tools/$platform_stuff/$d" ]; then
		declare $d="depcontainer/tools/$platform_stuff/$d"
	else
		printf -- "- Error missing: $d"
		exit 100
	fi
#fi
done
}

get_info (){
		# Read bundle info
		printf -- "- Reading info: '$x'\n"
		bundle=$(plistutil -f xml -i "$pattern" -o - | plget - 'CFBundleExecutable')
		ver=$(plistutil -f xml -i "$pattern" -o - | plget - 'CFBundleVersion')
		eri=$(find "$pattern2" -maxdepth 1 -name 'overrides_'*.plist | awk -F 'overrides_' '{print $2}' | sed 's/.plist//') # if more than two then it's will return \n
		ipcc_type=$(printf -- "$eri" | tr ' ' '\n' | wc -l)
		eri=$(printf -- "$eri" | tr '\n' '_')
	if [ ! -z "$bundle" ] && [ "$ipcc_type" -le '2' ]; then # default bundle has no overrides files, so ipcc_type will return 0
		ipcc_bundle=printf""$bundle".bundle_"$ver"_user_"$eri".ipcc"
		ipcc_bundle="$(printf -- ""$bundle".bundle_"$ver"_user_"$eri".ipcc"| sed 's/\_\.ipcc/.ipcc/')"
	elif [ ! -z "$bundle" ] && [ "$ipcc_type" -ge '3' ]; then
		ipcc_bundle=""$bundle".bundle_"$ver"_carrier.ipcc"
	else
		printf '- An unexpected error occurred while reading the bundle info.\n'
		exit 100
	fi
	
		# output config
		if [ -z "$output" ]; then output='./CarrierBundles'; fi # output directory
		ipcc_dir=""$output"/"$bundle".bundle/"$ver"/" # place to store ipcc
		if [ ! -d "$ipcc_dir" ]; then mkdir -p "$ipcc_dir"; fi # create output folder
		if [ ! -d './depcontainer/tmp/' ]; then mkdir -p './depcontainer/tmp/'; fi
		if [ ! -d './depcontainer/Payload/' ]; then mkdir -p './depcontainer/Payload/'; fi
		if [ "$payload_method" = '0' ]; then payload="$bundle.bundle"; fi
		if [ ! -d "./depcontainer/Payload/$payload" ]; then mkdir -p "./depcontainer/Payload/$payload"; fi
		export ipcc_bundle="$ipcc_bundle"
		export ipcc_dir="$ipcc_dir"
}

gen_ipcc (){
		# prepare ipcc for repack
		
		# sometimes you need to try different payload name
	if [ -z "$payload_method" ]; then
		payload_method='0' # name payload with parsed bundle name
	elif [ "$payload_method" = '1' ]; then
		payload='default.bundle'
	elif [ "$payload_method" = '2' ]; then
		payload='Default.bundle'
	elif [ "$payload_method" = '3' ]; then
		payload='unknown.bundle'
	elif [ "$payload_method" = '4' ]; then
		payload='Unknown.bundle'
	else
		printf -- '- Error payload name are incorrect.'
		exit 100
	fi


		#####################################
		### deal with multi dirs or files ###
		#####################################
		printf -- '- Searching for CarrierBundles ...\n'
for i in "$@"; do # process passed single or multi file(s)
	if [ -s "$i" ]; then
			x="$i"
			bundle_type='1'; set_process_bundle # call function
	elif [ -d "$i" ] && [ -z "$cbundle_name_mode" ]; then # proces pass directories contains file(s)
		find "$i" -type f \( -name '*.ipcc' -o -name 'carrier.plist' \) -print0 | 
			while IFS= read -r -d '' line; do
		if [ "$(printf -- "$line" | grep -o 'ipcc' | sed -n 1p)" = 'ipcc' ]; then
			x="$line"
			bundle_type='1'; set_process_bundle # call function
		elif [ "$(printf -- "$line" | grep -o 'carrier.plist' | sed -n 1p)" = 'carrier.plist' ]; then # process all
			x="$(printf -- "$line" | sed 's\/carrier.plist\\')"
			bundle_type='2'; set_process_bundle # call function
		fi
			done
	elif [ -d "$i" ] && [ "$cbundle_name_mode" = 'yes' ]; then
			cbundle_name=$(cat './depcontainer/bundles') # the required bundles list
		for c in $cbundle_name; do
		find "$i" -type d -name "$c" -print0 | 
			while IFS= read -r -d '' line; do
		if [ "$(printf -- "$line" | grep -o "$c" | sed -n 1p)" = "$c" ]; then # process only required
			x="$line"
			bundle_type='2'; set_process_bundle # call function
		fi
			done
		done
	fi
done
}

set_process_bundle (){
		# process ipcc
if [ "$bundle_type" = '1' ]; then
		rm -Rf './depcontainer/Payload/'*
		rm -Rf './depcontainer/tmp/'*
		unzip -qo "$x" -d './depcontainer/tmp/'
	find './depcontainer/tmp/' -type f -name 'carrier.plist' -print0 | 
		while IFS= read -r -d '' line; do
if [ -s "$line" ]; then
		pattern=$(printf -- "$line" | sed 's/carrier.plist/Info.plist/') # return the info.plist from the unknown bundle dir name
		pattern2=$(printf -- "$line" | sed 's/carrier.plist//') # return the dir name of bundle
		get_info # call function
	if [ ! -s "$ipcc_dir""$ipcc_bundle" ]; then
		printf -- "- Processing: '$line'\n"
		mv -f "$pattern2"* "./depcontainer/Payload/"$payload/"" # rename payload
		find './depcontainer/Payload' -exec touch -t '202401010700' {} \;
		find './depcontainer/Payload' -exec chmod 000 {} \;
		$(cd 'depcontainer'; zip -Xqr "$ipcc_bundle" 'Payload'; cd './') # Include parenthesis so cd does not affect your current terminal
		mv -f "depcontainer/$ipcc_bundle" "$ipcc_dir""$ipcc_bundle"
	elif [ -s "$ipcc_dir""$ipcc_bundle" ]; then
		printf -- "- Bundle exist: '"$ipcc_dir""$ipcc_bundle"'\n"
	fi
fi
done
elif [ "$bundle_type" = '2' ]; then
		pattern="$x/info.plist"
		pattern2="$x"
		get_info # call function
	if [ ! -s "$ipcc_dir""$ipcc_bundle" ]; then
		printf -- "- Processing: '$ipcc_bundle'\n"
		rm -Rf './depcontainer/Payload/'*
		cp -Rf "$x/." "./depcontainer/Payload/$payload"
		find './depcontainer/Payload' -exec touch -t '202401010700' {} \;
		find './depcontainer/Payload' -exec chmod 000 {} \;
		$(cd 'depcontainer'; zip -Xqr "$ipcc_bundle" 'Payload'; cd './') # Include parenthesis so cd does not affect your current terminal
		mv -f "depcontainer/$ipcc_bundle" "$ipcc_dir""$ipcc_bundle"
	elif [ -s "$ipcc_dir""$ipcc_bundle" ]; then
		printf -- "- Bundle exist: '"$ipcc_dir""$ipcc_bundle"'\n"
	fi
fi
		rm -Rf './depcontainer/Payload/'*
		rm -Rf './depcontainer/tmp/'*
}

set_install (){
		# install ipcc into connected device

		printf -- '- Reading connected device info ...\n'
		hw_model="$("$ideviceinfo" -s | grep 'HardwareModel' | awk -F 'HardwareModel: ' '{print $2}')"; hw_model="${hw_model:0:3}"
		cfb_ver=$("$ideviceinfo" | grep 'CFBundleVersion' | awk -F 'CFBundleVersion: ' '{print $2}')
if [ ! -z "$hw_model" ] && [ ! -z "$cfb_ver" ]; then
		printf -- "- AutoMode: Hardware:'$hw_model' CFBundleVersion:'$cfb_ver'\n"
select list in $(find 'CarrierBundles' -type f -name "*$cfb_ver*$hw_model*") exit; do
   case "$list" in
	exit) echo "exiting"
            break ;;
	   *) ipcc_bundle="$list"
			break;;
   esac
done
else
	printf -- '- Could not find a carrier-bundle matches current connected device.\n'
	exit 100
fi
	if [ ! -z "$payload_method" ]; then
		output='./depcontainer/misc/tmp'
		gen_ipcc "$ipcc_bundle"
		ipcc_bundle="$ipcc_dir""$ipcc_bundle"
	fi
	if [ ! -z "$ipcc_bundle" ]; then
		printf -- "- Payload name: '$payload'\n"
		"$ideviceinstaller" install "$ipcc_bundle" # install ipcc
		rm -rf './depcontainer/misc/tmp/'
	fi
}

get_bundle_down (){
		# download bundle
		
	if [ "$update_mode" = 'yes' ]; then
		get_bundles_update # call function
	fi
if [ "$cbundle_name_mode" = 'yes' ] && [ -z "$cbundle_name" ]; then
		cbundle_name="$(cat './depcontainer/bundles' | sed 's/.bundle//')"
select list in $cbundle_name exit; do
   case "$list" in
	exit) echo "exiting"
            break ;;
	   *) bundle="$list"
			break;;
   esac
done
#elif [ -z "$cbundle_name_mode" ] && [ ! -z "$cbundle_name" ]; then # in case user passed custom bundle name
#		bundle="$(printf -- "$cbundle_name" | sed 's/.bundle//')"
else
		printf -- "'- Please add '-c' switch"
		#printf -- '- Error invalid bundle name'
		exit 100
fi

	select list in $(plget './depcontainer/bundles_db.xml' "MobileDeviceCarrierBundlesByProductVersion/$bundle/*" | tr -d '\n\t ' | tr '*' '\n' | sed 's/ByProductType//g' | sort -nr -) exit; do
		case $list in
		exit) echo "exiting"
            break ;;
         *) ver="$list"
			break;;
		esac
	done

if [ ! -z "$bundle" ] && [ ! -z "$ver" ]; then
		printf -- "- Downloading: "$bundle".bundle_"$ver"\n"
		bundle_url="$(plget 'depcontainer/bundles_db.xml' "MobileDeviceCarrierBundlesByProductVersion/$bundle/$ver/BundleURL")"
	if [ ! -z "$output" ] && [ ! -d "$output" ]; then # set output folder
		mkdir -p "$output"
	else
		output="./depcontainer/tmp"
		mkdir -p "$output"
	fi
		curl -s "$bundle_url" -o "./depcontainer/tmp/$bundle.bundle_$ver.ipcc"
	if [ -s "./depcontainer/tmp/$bundle.bundle_$ver.ipcc" ]; then
		printf -- "- Succeed, file saved as: './depcontainer/tools/tmp/$bundle.bundle_$ver.ipcc'\n"
	else
		printf -- "- An error occurred while trying to download the file."
		exit 100
	fi
else
		printf -- '- An error occurred invalid bundle name'
		exit 100
fi
}

get_bundles_update (){
		# get latest bundle db
		
		printf -- '- Downloading carrier bundles database...'
		curl -s 'https://s.mzstatic.com/version' -o './depcontainer/bundles_db_new.xml'
if [ -s './depcontainer/bundles_db_new.xml' ]; then
	if [ "$(tail -n +212440 'depcontainer/bundles_db_new.xml' | grep -o '</plist>')" = '</plist>' ]; then
		mv -f 'depcontainer/bundles_db_new.xml' 'depcontainer/bundles_db.xml'
	fi
else
		printf -- '- An error occurred while updating database.'
		exit 100
fi
}


		########################################
		#                main                  #
		########################################
set_config # call function
if [ "$1" = '' ]; then usage; fi # call function
while getopts i:o:p:ducs option
	do
		case "${option}"
	in
		i) get_filesnames='yes';;
		o) output="${OPTARG}";;
		u) update_mode='yes';;
		d) download_mode='yes';;
		c) cbundle_name_mode='yes';;
		p) payload_method="${OPTARG}";;
		s) install_mode='yes';;
		?) usage;; # call function
	esac
done


		# run method
if [ "$install_mode" = 'yes' ]; then
		set_install # call function
elif [ "$download_mode" = 'yes' ]; then
		get_bundle_down # call function
elif [ "$get_filesnames" = 'yes' ]; then
		gen_ipcc "$@" # call function
else
		printf 'Unknown option\n'
		exit 100
fi
