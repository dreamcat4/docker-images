# Deluge

### Web UI

Web UI is accessible on port `8112` on the lan_interface. Default password is `deluge`.

### Daemon

Daemon (for GTK and other API clients) is accessible on port `58846` on the lan_interface. Default username: `deluge`, default password: `deluge`.

### File permissions

The container has a `debian-deluged` user and group, with a default `uid:gid` of `101:103` or something like that. Which can be checked inside of the running container.

The deluge daemon is always being launched as the `debian-deluged` user and group. There are several different strategies to permissions management. Depending upon whether or not other user accounts also need to have write access to the same files / directories.

#### Change the debian-deluged uid and gid

This can be done at runtime by setting the following docker env vars:

```sh
deluge_uid=XXX
deluge_gid=YYY
```

By specifying the uid and gid as a number, this lets you control which folder(s) deluge can read/write to.

#### Add your host user account to the debian-deluged group

If you do not change deluge's gid number to match your other accounts, then you can instead permit your own host account(s) file access to the delueg folders by making the group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will need to create a `debian-deluged` group, adding your own user account to be a member of the same group gid (the default value of sonarr's gid is `103`). Copy-paste these commands:

```sh
sudo groupadd -g 103 debian-deluged
sudo usermod -a -G debian-deluged $(id -un)
```

### Networking

These are the interface names as they appear inside the container. It does not setup that aspect of the networking for you. For that use `dreamcat4/pipework`.

Lan interface: Where the deluge daemon and webui will be accessible.

    deluge_lan_interface=eth0

Wan interface: Where the torrent ports will be opened. Usually you link this interface to your vpn tunnel / gateway for example `ppp0`, `tun0` etc.

    deluge_wan_interface=eth1

Daemon port: This setting is entirely optional and not needed. Just leave as the default port #

    deluge_daemon_port=58846

### Configuration

This image comes with some vanilla default configuration.

However you can go one step further and build your own `/config` image, with your own customized pre-seeded configuration settings. Including localization and timezone for your country / region / language. Having your own config image will make reseting / config regeneration a breeze. See the accompanying [`dreamcat4/deluge.config`](https://github.com/dreamcat4/docker-images/tree/master/deluge/config) image for more information how to build.

#### Allow Remote Connections

Leave this setting unchecked. Normally the "Allow Remote Connections" option is used to bind the deluge daemon's TCP port to `0.0.0.0` (all local interfaces). However for the way this docker image is specifically setup, the container's start script will smartly forward the port using `socat` utility to the correct or most appropriate lan interface. Either it will use the one you specify with `deluge_lan_interface` docker environment variable. Else determine you LAN gateway's default nic route and have the deluge daemon available on that nic only (and localhost). By not checking this option, it ensures that your deluge daemon is not accidentally being exposed on your `deluge_wan_interface` too. Where typically your wan nic would be linked to your host's `ppp0`, `tun0` or something like that for VPN provider / VPN gateway.

### Docker Compose

Sorry there is no example for Compose at this time. But it is something like this:

```sh
  deluge.config:
    image: dreamcat4/deluge.config
    dockerfile: deluge/config

  deluge:
    image: dreamcat4/deluge
    run:
      net: none
      cmd: --loglevel=debug
      volumes-from:
        - deluge.config
      volume:
        - /my/torrents/folder:/torrents
        - /my/downloads/folder:/downloads
      env:
        - deluge_uid=65534
        - deluge_gid=44
        - pipework_wait=eth0 eth1
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.1
        - pipework_cmd_eth1=ppp0 -i eth1 @CONTAINER_NAME@ 10.10.0.2
        - deluge_lan_interface=eth0
        - deluge_wan_interface=eth1
      detach: true
```

Where the `pipework_*` env variables are used to setup networking using `dreamcat4/pipework`. Else use docker native networking.

