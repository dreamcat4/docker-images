# Sonarr

### Configuration

All user configuration is performed in the web interface. Therefore there is no pre-seeded `/config` files. You are recommended to bind-mount all of your needed host folders, and backup independantly your `sonarr` config directory with some scripted / scheduled task.

### Media folders

You will use sonarr's web interface to specify which folders sonarr must use.

Sonarr may be given read-only access to your top-level media folder. From there, you should grant sonarr write access in 2 subfolders of your main `/media` folder:

For example: 1) `TvStaging` and 2) `TvShows`. However they can be given any name you wish.

1) The 1st folder is where sonarr will instruct your torrent client to download new episodes to.

2) The 2nd folder is sonarr's managed media folder. When a download completes, lets assume it appears in the first `TvStaging` folder. Then sonarr will MOVE (unix `mv` cmd) the downloaded file (or files) into it's destination. Which is the sonarr managed media folder. In this example we have it called `TvShows`. Because that's what sonarr is most commonly used for.

The unix `mv` move operation is usually most effecient when BOTH the source + destination paths are are inside the same mountpoint. To avoid lots of copying large files. And that is the reason we mount the parent folder `/media` into a docker volume. It does not mean sonarr will be managing your ENTIRE `/media` folder. Only the subdirectories that you will later specify.

If you have other unrelated folders inside your `/media` folder (music, games etc). Then set the uid/gid and folder permissions to ensure that `sonarr` cannot read or write to the other folders.

### File permissions

By default sonarr will run as the `sonarr` user and group. With a default `uid:gid` of `8989:8989`. The same as it's TCP port number.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
sonarr_uid=XXX
sonarr_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) sonarr has read/write access to.

#### Add your host user account to the sonarrr group

If you do not change sonarr's gid number to match your other accounts, then you can instead permit your own host account(s) file access to sonarr's folders by making the group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will need to create a `sonarr` group, adding your own user account to be a member of the same group gid (the default value of sonarr's gid is `8989`). Copy-paste these commands:

```sh
sudo groupadd -g 8989 sonarr
sudo usermod -a -G sonarr $(id -un)
```

### Docker Compose

Sorry there is no example for Docker Compose at this time. But you may do something similar:

```sh
crane.yml:

containers:

  sonarr:
    image: dreamcat4/sonarr
    run:
      net: none
      volume:
        - /my/sonarr/config/folder:/config
        - /my/media/top/level/folder:/media
      env:
        - sonarr_uid=65534
        - sonarr_gid=44
        - pipework_wait=eth0
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.15
      detach: true
```

The `pipework_` variables are used to setup networking with the `dreamcat4/pipework` helper image.


