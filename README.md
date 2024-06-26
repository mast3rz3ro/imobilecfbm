# iMobile Carrier-Bundles Manager
* A lightweight utility to download, repack and install carrier bundles files for iOS based devices.

## How to get started?
**Required dependancy: [libplist](https://github.com/libimobiledevice/libplist) [plget](https://github.com/kallewoof/plget) [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice)**

**Windows users:**
1. Install [MSYS2](https://www.msys2.org)
2. Get the latest precompiled [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) from [here](https://github.com/L1ghtmann/libimobiledevice/releases) and then extract the binaries into: `C:\msys64\usr\bin`
3. Get the latest precompiled [plget](https://github.com/kallewoof/plget) from [here](https://github.com/mast3rz3ro/plget/releases) and then extract the binaries into: `C:\msys64\usr\bin` *Important note: Don't replace any file If already exist !*
4. Install required dependancy: `pacman -S git`
5. Clone this repo

**Linux users:**
1. Install required dependancy:
```shell
sudo apt install git \
libplist-utils \
libimobiledevice-utils
```
2. Follow the instructions here [plget](https://github.com/kallewoof/plget) for compiling plget utility.
3. After you have compiled plget you either have to set the variable plget via `export plget=/home/location/plget` or you can avoid always exporting the plget variable by simply copying the plget binary into: `/usr/bin`.
4. Clone this repo

**macOS users:**
1. Install [brew](https://brew.sh)
2. Install required dependancy:
```shell
brew install libimobiledevice libplist
```
3. Follow the instructions here [plget](https://github.com/kallewoof/plget) for compiling plget utility.
4. After you have compiled plget make sure to always set the variable plget via `export plget=/home/location/plget`
5. Clone this repo

**Cloning repo:**
```shell
git clone https://github.com/mast3rz3ro/imobilecfbm
```

**How to run?**
```shell
$ cd imobilecfbm
$ chmod +x cfbm.sh
$ ./cfbm.sh

# If you have installed the required dependancy then you should be able to see the parameters options
# otherwise it's will warn you that you are missing one of the dependancy.
```

## Usage examples:
**- Examples:**
```shell
  # Update local database and check latest carrier bundles available for download:
     cfbm -u -d
  # Idenify the carrier bundle from local storage and repack it:
     cfbm -i 'file.ipcc' 'folder_contains_ipcc_files'
  # Search and Install a carrier bundle matches the connected device bundle version:
     cfbm -s
  # Search and Install a valid carrier bundle with 'default.bundle' payload name:
     cfbm -s -p 1
```

## Where to get support?
* Please open a new ticket [here](https://github.com/mast3rz3ro/imobilecfbm/issues) and describe your issue as much as possible.

## References:
* [ipcc-downloader](https://github.com/mrlnc/ipcc-downloader) another bundles downloader by @mrlnc this repo contains some good info.
* [jailbreak10.3.3](https://github.com/WRFan/jailbreak10.3.3) a great repo by @WRFan contains too much info about carrier bundles.
* [anchumosaku](https://anchumosaku.com/how-to-use-rakuten-mobile-with-an-unsupported-iphone/) a great tutorial by @liathfeth about extracting and repacking the carrier bundle.
* [CarrierBundle](https://theapplewiki.com/wiki/Carrier_Bundle) More info about carrier bundles by TheAppleWiki
* [samsam123](https://samsam123.name.my/ipcc/generate.php) Online website for fetching carrier Bundles.

## Credits
* [plget](https://github.com/kallewoof/plget) a lightweight PLIST parser
* [libplist](https://github.com/libimobiledevice/libplist) used for force converting PLIST file into xml.
* [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) Used for installing carrier-bundles and more.
* [L1ghtmann](https://github.com/L1ghtmann/libimobiledevice) for providing a precompiled libimobiledevice binaries for windows.
* [MSYS2](https://www.msys2.org) an alternative to Cygwin but better.
* [brew](https://brew.sh) a package manager same like apt/pacman but for macOS.