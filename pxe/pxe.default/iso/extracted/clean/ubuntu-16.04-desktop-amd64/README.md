### What is this folder for?

We need to copy a certain few boot files to here (from the ISOs)

This folder you should put:

* The contents of `casper/` folder, taken from mounted ubuntu ISO file.
* See in the folders each `filename__PUT_HERE__.txt` is just a placeholder.
* You need to take the real files from the mounted .ISO

Why?

* To be served to ipxe over http, which is done by the built-in `nginx` webserver.
* They are used in file `ipxe/ipxe.boot` for directives for 'kernel' and 'initrd'.
* It starts the boot process


For ubuntu ISO, and other linux:

You can extract directly the kernel boot files with `osirrox` program.

Like this:

    osirrox -indev /pxe/iso/ubuntu-16.04-desktop-amd64.iso -extract /casper/initrd.lz /pxe/iso/extracted/clean/ubuntu/casper/
    osirrox -indev /pxe/iso/ubuntu-16.04-desktop-amd64.iso -extract /casper/vmlinuz.efi /pxe/iso/extracted/clean/ubuntu/casper/


