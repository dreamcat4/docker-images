### What is this folder for?

We need to copy a certain few boot files to here (from the ISOs)

This folder you should put:

* The contents of `boot/` folder, and `sources/` folder. Taken from mounted win10 ISO file.
* See in the folders each `filename__PUT_HERE__.txt` is just a placeholder.
* You need to take the real files from the mounted .ISO

Why?

* To be served to ipxe over http, which is done by the built-in `nginx` webserver.
* They are used in file `ipxe/ipxe.boot` for directives for 'kernel' and 'initrd'.
* It starts the boot process






