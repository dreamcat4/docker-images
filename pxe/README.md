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

* Example `pxe.example/` folder tree
  * Auto-populates your `/pxe` docker volume with example files and further instructions.
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
* Follow instructions in the `/pxe` example folder, how to unpack those missing boot files.

To get these first 4 [SAMBA] boot options working you also need to:

* Mount required installer ISOs each on separate local samba shares.
* Can use something else e.g. `dreamcat4/samba-iso` helper image to do that with.

Please see in the subfolder `pxe.example/*/README.md` for further instructions per OS.

### Credit

* pxe Version 1 - By Dreamcat4.



