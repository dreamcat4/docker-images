### What is this folder for?

We need to copy a certain few boot files to here.

First thing to do is:

* Create winPE output folder (or WinPE iso). That must be done on windows, with WADK.

Instructions is on iPXE.org website:

http://ipxe.org/howto/winpe

And then copy from your WADK WinPE output folder, in to here:

*  `sources/boot.wim`
*  `boot/BCD`
*  `boot/boot.sdi`


Done!

Now must mount / modify the folder tree inside of `boot.wim` archive. See `modified/winpe` folder for more instructions.

