### What is this folder for?

We need to copy a certain few boot files to here (from the ISOs)

* Why?

* We need to extract, then re-compress winpe's `boot.wim` with an extra couple of scripts.
* To run `install.bat` automatically, and perform necessary init tasks.
* The script `install.bat` will HTTP GET settings from the file: `/pxe/winpe/win10.config`
* To fine the samba share containing the actual windows installer ISO files.
* Then `install.bat` will launch the windows `setup.exe` program from the mounted samaba share / ISO files.
* We show an example versions for
  * win10 ISO installer
  * win7 ISO installer


First thing to do is:

* Create winPE output folder (or WinPE iso). That must be done on windows, with WADK.

Instructions is on iPXE.org website:

http://ipxe.org/howto/winpe

* And copy `boot.wim` and other files to the `clean/winpe` folder

Then in this folder is where you should:

* Extract the file `/pxe/iso/extracted/clean/winpe/source/boot.wim`, a product avaialble from the winpe ISO.
* See in the folders each `filename__PUT_HERE__.txt` is just a placeholder.

Like this:

  # extract boot.wim into a local folder
  wimextract /pxe/iso/extracted/clean/winpe/sources/boot.wim 1 --dest-dir=/pxe/iso/extracted/modified/winpe/boot_wim


* Add any missing network drivers / .inf files.
  * Which probably must be done in windows, with WADK, using  `dsim /add-driver`
  * Then move the commited `boot.wim` back over to linux here.

For adding missing drivers, see:

http://ipxe.org/howto/winpe#adding_a_network_card_driver

https://technet.microsoft.com/en-GB/library/dn613857.aspx

* Add the contents of the folder `boot_wim_overlay/win10` or `boot_wim_overlay/win7`.

Like this:

  # Add extra files to modified boot_wim tree
  cp -Rf boot_wim_overlay/win10 boot_wim/

  # The boot script "install.bat" also requires wget for windows, so must include that too
  wget https://eternallybored.org/misc/wget/current/wget64.exe
  cp wget64.exe boot_wim/Windows/


* Re-compress the modified `boot_wim/` folder, to include your added file(s)

Like this:

  wimcapture boot_wim sources/win10_setup.exe/boot.wim --boot




