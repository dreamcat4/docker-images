# Deluge-PIA

### Web UI

Web UI is accessible on port `8112` on the lan_interface. Default password is `deluge`.

### Daemon

Daemon (for GTK and other API clients) is accessible on port `58846` on the lan_interface. Default username: `deluge`, default password: `deluge`.

### File permissions

By default deluge will run as the `deluge` user and group. With a default `uid:gid` of `8112:8112`. Same as it's web interface TCP port number. So you will never forget.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
deluge_uid=XXX
deluge_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) deluge has read/write access to.

#### Add your host user account to the deluge group

If you do not change deluge's gid number to match your other accounts, then you can instead permit your own host account(s) file access to the delueg folders by making the group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will need to create a `deluge` group, adding your own user account to be a member of the same group gid (the default value of sonarr's gid is `103`). Copy-paste these commands:

```sh
sudo groupadd -g 103 deluge
sudo usermod -a -G deluge $(id -un)
```

### Env vars

PIA Gateway: The remote PIA server to connect to.

    pia_gateway=swiss.privateinternetaccess.com

Lan interface: Where the deluge daemon and webui will be accessible. This setting is entirely optional and not needed. Just leave as nothing and will be automatically detected.

    lan_interface=eth0

Daemon port: This setting is entirely optional and not needed. Just leave as the default port #

    deluge_daemon_port=58846

### Configuration

You need to bind mount a text file named `pw` to `/config/openvpn/pw`. Containing your openvpn username and password credentials for logging into the remote PIA servers.

This image comes with some vanilla default configuration in the `config.default` sub-folder. Its also possible to override that default config by adding extra files to `config.custom` and then rebuilding this docker image.

#### Allow Remote Connections

Leave this setting unchecked. Normally the "Allow Remote Connections" option is used to bind the deluge daemon's TCP port to `0.0.0.0` (all local interfaces). However for the way this docker image is specifically setup, the container's start script will smartly forward the port using `socat` utility to the correct or most appropriate lan interface. Either it will use the one you specify with `lan_interface` docker environment variable. Else determine you LAN gateway's default nic route and have the deluge daemon available on that nic only (and localhost). By not checking this option, it ensures that your deluge daemon is not accidentally being exposed on all the other interfaces too. Such as `tun0` for the openvpn gateway.

### Docker Compose

Sorry there is no example for Compose at this time. But it is something like this:

```sh

  deluge:
    image: dreamcat4/deluge-pia
    run:
      net: macvlan_driver
      ip: 192.168.2.2
      cap-add:
        - NET_ADMIN
      device:
        - /dev/net/tun
      volume:
        - /path/to/etc/openvpn/pw:/config/openvpn/pw
        - /path/to/deluge-pia/config.current:/config
        - /path/to/deluge/downloads:/downloads
        - /path/to/deluge/torrents:/torrents
      env:
        - deluge_uid=65534
        - deluge_gid=44
        - pia_gateway=swiss.privateinternetaccess.com
      detach: true
```



