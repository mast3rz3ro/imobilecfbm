# iMobile Carrier-Bundles Manager
* A lightweight utility to download, repack and install carrier bundles files for iOS based devices.

## How to get started?
**Required dependancy: [libplist](https://github.com/libimobiledevice/libplist) [plget](https://github.com/kallewoof/plget) [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice)**

**Windows users:**
1. Install [MSYS2](https://www.msys2.org)
2. Get latest precompiled [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice/releases) from [here](https://github.com/L1ghtmann/libimobiledevice/releases) by @L1ghtmann and then extract the binaries into: 'C:\mmsys64\usr\bin'
3. Install required dependancy: `pacman -S git`
4. Clone this repo

**Linux users:**
1. Install required dependancy:
```shell
sudo apt install git \
libplist-utils \
libimobiledevice-utils
```
2. Clone this repo

**macOS users:**
1. Install [brew](https://brew.sh)
2. Install required dependancy:
```shell
brew install libimobiledevice \
brew install libplist
```
3. Clone this repo

**Cloning repo:**
```shell
git clone https://github.com/mast3rz3ro/imobilecfbm
```

## Usage examples:
**- Examples:**
```shell
    Update local database and check latest carrier bundles available for download:
     cfbm -u -d -p
    Idenify the carrier bundle from local storage and repack it:
     cfbm -i 'file.ipcc' 'folder_contains_ipcc' 'folder_contains_ipcc_files'
    Search and Install a carrier bundle matches the connected device bundle version:
     cfbm -s
    Search and Install a valid carrier bundle with 'default.bundle' payload name:
     cfbm -s -p 1
```

## Where to get support?
* Please open a new ticket [here](https://github.com/mast3rz3ro/imobilecfbm/issues) and describe your issue as much as possible.

## References:
* [ipcc-downloader](https://github.com/mrlnc/ipcc-downloader) by @mrlnc another bundles manager and repo contains some good info.
* [jailbreak10.3.3](https://github.com/WRFan/jailbreak10.3.3) a great repo by @WRFan contains too much info about carrier bundles.

## Credits
* [plget](https://github.com/kallewoof/plget) a lightweight PLIST parser
* [libplist](https://github.com/libimobiledevice/libplist) used for force converting PLIST file into xml.
* [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) Used for installing carrier-bundles and more.
* [L1ghtmann](https://github.com/L1ghtmann/libimobiledevice) for providing a precompiled libimobiledevice binaries for windows.
* [MSYS2](https://www.msys2.org) an alternative to Cygwin but better.
* [brew](https://brew.sh) a package manager same like apt/pacman but for macOS.