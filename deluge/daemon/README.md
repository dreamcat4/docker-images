# Deluge

### Web UI

Web UI is accessible on port `8112` on the lan_interface. Default password is `deluge`.

### Daemon

Daemon (for GTK and other API clients) is accessible on port `58846` on the lan_interface. Default username: `deluge`, default password: `deluge`.

### Docker Env Variables

These are the interface names as they appear inside the container. It does not setup that aspect of the networking for you. For that use `dreamcat4/pipework`.

Lan interface: Where the deluge daemon and webui will be accessible.

    deluge_lan_interface=eth0

Wan interface: Where the torrent ports will be opened. Usually you link this interface to your vpn tunnel / gateway for example `ppp0`, `tun0` etc.

    deluge_wan_interface=eth1

Daemon port: This setting is entirely optional and not needed. Just leave as the default port #

    deluge_daemon_port=58846

### Config

This image comes with some vanilla default configuration.

However you can go one step further and build your own `/config` image, with your own customized pre-seeded configuration settings. Including localization and timezone for your country / region / language. Having your own config image will make reseting / config regeneration a breeze. See the accompanying [`dreamcat4/deluge.config`](https://github.com/dreamcat4/docker-images/tree/master/deluge/config) image for more information how to build.

### Allow Remote Connections

Leave this setting unchecked. Normally the "Allow Remote Connections" option is used to bind the deluge daemon's TCP port to `0.0.0.0` (all local interfaces). However for the way this docker image is specifically setup, the container's start script will smartly forward the port using `socat` utility to the correct or most appropriate lan interface. Either it will use the one you specify with `deluge_lan_interface` docker environment variable. Else determine you LAN gateway's default nic route and have the deluge daemon available on that nic only (and localhost). By not checking this option, it ensures that your deluge daemon is not accidentally being exposed on your `deluge_wan_interface` too. Where typically your wan nic would be linked to your host's `ppp0`, `tun0` or something like that for VPN provider / VPN gateway.

### File permissions

The container has a user and a group each named `debian-deluged`. With a `uid:gid` of `101:103`. This can be verified on the cmdline:

```sh
$ docker exec deluge sh -c "cat /etc/passwd | grep debian-deluged ; cat /etc/group | grep debian-deluged"
debian-deluged:x:101:103::/config:/bin/sh
debian-deluged:x:103:
```

Since the deluge daemon is always being launched as that process user & group. Then the simplest solution is to keep the container's user as `debian-deluged`. And just permit yourself file access using the group level writable permissions bits e.g. chmod `0664` and `0775`.

On host side you will need to create a group named `debian-deluged`. Adding your own user account to be a member of the same group gid (`103`). Just copy-paste these commands:

```sh
sudo groupadd -g 103 debian-deluged
sudo usermod -a -G debian-deluged $(id -un)
```

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
        - pipework_wait=eth0 eth1
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.1
        - pipework_cmd_eth1=ppp0 -i eth1 @CONTAINER_NAME@ 10.10.0.2
        - deluge_lan_interface=eth0
        - deluge_wan_interface=eth1
      detach: true
```

Where the `pipework_*` env variables are used to setup networking using `dreamcat4/pipework`. Else use docker native networking.

