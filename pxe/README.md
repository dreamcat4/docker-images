### PXE

* Network boot your local PCs.
* No disks, USBs or DVDs required!

![ipxe boot menu](http://i.imgur.com/7LT2dxg.png "ipxe boot menu")

### Features

This docker image contains:

* dnsmasq server
  * pre-configured in proxy mode for replying to initial PXE boot request
  * with TFTP server, to send the initial boot file (official ipxe binary)
  * tested working for both legacy BIOS, and UEFI clients

* ipxe
  * Versions for both BIOS mode and UEFI mode
  * ipxe provides better features, including:
    * understands http urls (faster than TFTP)
    * includes iscsi client driver (ATM for legacy BIOS only, not available in UEFI mode)
  * An example ipxe configuration file, including boot menu (pictured above)

* nginx webserver, to send further boot files after ipxe is loaded up

* Example `pxe.default/` folder tree
  * Auto-populates your `/pxe` docker volume with pre-seeded example files and further instructions.
  * You will need to manually download / unpack certain files:
    * installer ISOs (namely the windows installer .ISO dvd, and ubuntu-desktop.iso)
    * assoiated boot files
  * The examples are made for the following operating systems:
    * ubuntu-16.04
    * win10
    * win7

### Requirements

* Some time
* To download the ISO files for the operating systems you wish to boot
* As those cannot be re-distributed / downloaded from here.
* To get these main -- SAMBA -- boot options working you also need to perform certain extra steps...

***Windows***

Follow instructions in the `/pxe.default` folder, how to unpack each PLACEHOLDER missing essential BOOT files. You can also see those needed files referenced in the [boot.ipxe](https://github.com/dreamcat4/docker-images/blob/e793b29f43a8c31aa2a01a77c3e80a54d8d7cbb3/pxe/pxe.default/ipxe/boot.ipxe) conf file.

* Mount required installer ISOs each on separate local samba shares.
* Can use something else e.g. [`dreamcat4/samba-iso`](https://github.com/dreamcat4/docker-images/tree/master/samba-iso) helper image to do that with.

***Ubuntu***

To get the ubuntu boot options working you also need to:

* [Read further instructions in the `:ubuntu` section of `boot.ipxe` configuration file](https://github.com/dreamcat4/docker-images/blob/e793b29f43a8c31aa2a01a77c3e80a54d8d7cbb3/pxe/pxe.default/ipxe/boot.ipxe#L56-L63)
* To set in there your samba username, password etc. for the samba share of the ubuntu livecd iso file

To get the ubuntu persistence mode working with `casper-rw` file, you will also need to:

* [Read further instructions in the `:ubuntu_casper_rw` section of `boot.ipxe` configuration file](https://github.com/dreamcat4/docker-images/blob/e793b29f43a8c31aa2a01a77c3e80a54d8d7cbb3/pxe/pxe.default/ipxe/boot.ipxe#L70-L103)
* Use legacy mode? It was not working for me in UEFI pxe boot mode.

### Known Issues

Can't be 100% sure if these are going to affect other people. But the following issues were encountered during testing:

***Windows***

* If the Win10 installer option (via WinPE environment) is booted, then no little 'Repair' button will appear on Setup.exe first screens, cannot launch into the windows recovery menu.

* If the Win10 recovery menu is booted (ironically that is via 'clean' non-WinPE installer boot files). Then the same setup.exe launches, and the little 'repair' button appears. So the recovery menu can work. However without WinPE files, setup.exe cannot install windows.

* Solution to above ^^ problem was to split into 2 separate boot items in the menu.

* On some UEFI clients, Win7 setup.exe will take an exceeding long time to appear on the screen. Booting seems as-if hanged at `'Loading...'`. Its just very slow. Other clients are fine.

* If WinPE / Windows Installer is booted with iscsi lun attached (via ipxe's `sanhook` command). Then the disk is not visible / cannot be seen by the Windows installer.

***Ubuntu***

* Patched persistence mode with `casper-rw` file and `home-rw` file. Does not properly dismount partitions during shutdown.

* Patched persistence mode with `casper-rw` file and `home-rw` file. Only seems to work for Legacy BIOS netboot. It does not appear to mount the persistence partitions if the computer is booted into UEFI mode.

### FAQ

*** What about Mac OS X? ***

Macs are a bit tougher to do. But it might be possible perhaps. Here is some useful resources for helping that:

BSDPy - for mac netbooting - https://github.com/bruienne/bsdpy

Booting into Mac OS X from iPXE menu - https://github.com/ipxe/ipxe/pull/54



### Credit

* pxe Version 1 - By Dreamcat4.



