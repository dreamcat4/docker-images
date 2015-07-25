# Sonarr

### Configuration

All user configuration is performed in the web interface. Therefore there is no pre-seeded `/config` files. You are recommended to bind-mount all of your needed host folders, and backup independantly your `sonarr` config directory with some scripted / scheduled task.

### File permissions

The container has a `sonarr` user and group, with `uid:gid` of `8989:8989` which can be verified on the cmdline:

```sh
$ docker exec sonarr sh -c "cat /etc/passwd | grep sonarr ; cat /etc/group | grep sonarr"
sonarr:x:9898:9898:Also known as nzbdrone - runs mono NzbDrone.exe:/config:/bin/sh
sonarr:x:9898:
```

Since the sonar server is always being launched as that process user & group. Then the simplest solution is to keep the container's user as `sonarr`. And just permit yourself file access using the group level writable permissions bits e.g. chmod `0664` and `0775`.

On host side you will need to create a `sonarr` group, adding your own user account to be a member of the same group gid (`8989`). Just copy-paste these commands:

```sh
sudo groupadd -g 8989 sonarr
sudo usermod -a -G sonarr $(id -un)
```

### Docker Compose

Sorry there is no example for Compose at this time. But it is something like this:

```sh
  sonarr:
    image: dreamcat4/sonarr
    run:
      net: none
      volume:
        - /my/sonarr/config/folder:/config
        - /my/torrent/downloads/folder:/downloads
        - /my/managed/media/folder/of/tvshows:/tv
      env:
        - eth0_up=true
        - pipework_wait=eth0
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.15
      detach: true
```

Where the `pipework_*` env variables are used to setup networking using `dreamcat4/pipework`. Else use docker native networking.

You can mount any media or downloads folders into the sonarr container. However the start script sets permissions only on these recognized mountpoints:

```sh
chown -R sonarr:sonarr /opt/NzbDrone /config /torrents /downloads /media /tv
```

You can edit in the `entrypoint.sh` script to your liking.
