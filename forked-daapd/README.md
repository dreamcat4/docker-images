# Forked-daapd

This version of forked-daapd is the official package found in ubuntu 15.10 (or higher). And seems to be this one:

https://github.com/ejurgensen/forked-daapd

Source / inspiration:

http://www.mrericsir.com/blog/technology/setting-up-ubuntu-as-an-itunes-music-server/

### Configuration

There are very few configuration variables to worry about. Simply bind-mount your iTunes Music folder to `/music`, and with the default config file it should take care of everything for you. The configuration file is pre-seeded into `/config/forked-daapd.conf`. However if you muck it up, the original version can be found in `/etc/`.

Note:

The daapd protocol relies upon Bonjour / mDNS service discovery protocol (multicast), it is also needed to make sure your container's networking solution supports multicast. Otherwise your DAAPD server may not be findable / visible on LAN. For that it is also recommended the `dreamcat4/pipework` image, which was tested and found to support multicasting.

### File permissions

By default the server will run as the `daapd` user and group. With a default `uid:gid` of `3689:3689`. The same as it's TCP port number. So you will never forget.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
daapd_uid=XXX
daapd_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) forked-daapd has read/write access to.

#### Add your host user account to the jackett group

Note: Normally this server only needs read and execute permission to your iTunes music folder. It very rarely / if ever needs write access.

If you do not change the daapd group's gid number to match your other accounts, then you can instead permit your own host account(s) file access to the same folders by making the group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will also need to create a `daapd` or equivalent GID group, adding your own user account to be a member of that group (the default value of the gid is `3689`). Copy-paste these commands:

```sh
sudo groupadd -g 3689 daapd
sudo usermod -a -G daapd $(id -un)
```

### Docker Compose

Sorry there is no example for Docker Compose at this time. But you may do something similar:

```sh
crane.yml:

containers:

  fdaapd:
    image: dreamcat4/forked-daapd
    run:
      net: none
      volume:
        - /path/to/my/music:/music:ro
      env:
        - daapd_uid=65534
        - daapd_gid=65534
        - pipework_wait=eth0
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.17
      detach: true
```

The `pipework_` variables are used to setup networking with the `dreamcat4/pipework` helper image.


