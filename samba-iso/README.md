# Samba-iso

* Mount iso file to a samba share
* Based on [dreamcat4/samba](https://github.com/dreamcat4/docker-images/tree/master/samba) docker image

## Usage

You will need to:

* Bind-mount your iso file --> to the single file `/iso` inside the container

* Set the docker env variable `-e samba_flags=` to set your samba share settings. As would be for the command line options as documented in [dreamcat4/samba](https://github.com/dreamcat4/docker-images/tree/master/samba).

* Set some other necessary permissions, and mount your host's `/dev/loop*` devices as shown in the yaml example below.

## Docker compose

Sorry there isn't an example specifically for compose. However you can adapt from this `crane.yml` file which is very similar:

```yaml

containers:

  ubuntu.iso.smb:
    image: dreamcat4/samba-iso
    run:
      hostname: ubuntu_iso_smb
      volume:
        - /path/to/ubuntu-16.04-desktop-amd64.iso:/iso
      env:
        - samba_flags=-t Europe/London -u smb_username;smb_password;0;0; -s iso;/share/ubuntu/iso;yes;no;no;smb_username
      cap-add:
        - SYS_ADMIN
      device:
        - /dev/loop0
        - /dev/loop1
        - /dev/loop2
        - /dev/loop3
        - /dev/loop4
        - /dev/loop5
        - /dev/loop6
        - /dev/loop7
      security-opt:
        - apparmor:unconfined
        - seccomp:unconfined

```


### Credit

* Version 1 - By Dreamcat4.







