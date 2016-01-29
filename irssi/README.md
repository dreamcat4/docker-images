# Irssi

Irssi + ZNC + Bitlbee + tmux + ssh. Work in progress.

General diagram how these services are connected up:

```sh
Public IRC Servers <--- ZNC <--- IRSSI <--- TMUX Session <--- SSH <--- Client computers
           Bitlbee <-/
```

Thanks to TMUX, simultaneous ssh / irssi logins are supported. So you can have the same irssi session open on multiple machines no problem.

Current status:

Have basic working chain of services. Everything comes up automatically.

Left todo:

* Improve the default user interface, fix broken theme
* Improve the default settings, default selection of scripts
* Publish on Docker Hub

Not done here, may be left unsolved forever:

* Desktop notifications for growl, libNotify, Windows, Android / iOS etc.
* SSH port forwarding the znc server's IRC port for other external irc clients (i.e. weechat etc)
* Web based tty access with nginx / wetty / tty.js.

### Configuration

Pre-seeded Configuration Files:

All configuration files are held in the working folder `/config`. There are different versions of the config folder. See [`config.default/README.md`](#config.default/README.md) and [`config.custom/README.md`](#config.custom/README.md) for more information about those.

SSH Configuration:

For ssh terminal access you can put your existing ssh public key (e.g. `id_rsa.pub`) into `/config/irssi/.ssh/known_hosts` file. Else a new keypair will be automatically generated per container on first run. And the resultant `id_rsa` private key file can be copied from `/config/irssi/.ssh/id_rsa` of your new running container's mounted `/config` volume.

ZNC Configuration:

By web browser:

The znc server will be configurable from any standard web browser, available on SSL protocol `https://$your_container_ip:6697`. The default username and password for znc admin user is `znc:znc`. It is recommended to then goto manage users --> Duplicate the default `znc` user with your own IRC nick name.

Be text file:

The `znc.conf` file is stored in the usual loacation at `/config/znc/configs/znc.conf`

IRC Logs:

By default all IRC channel logs are kept by ZNC in the mounted docker volume `/logs`.

Bitlbee:

Tends to be configured interactively by commands to the `&bitlbee` control channel, all done while running irssi client. There may also be text config file saved to 

TMUX:

The config file is located at `/config/irssi/.tmux.conf`

### Service ports

This container runs multiple services on it, and as several different user accounts. They are as follows:

```sh
INTERFACE, TCP_PORT, (PROTOCOL), UNIX_USER, SERVICE, COMMENT

0.0.0.0 (all interfaces), 22, (SSH term), irssi, irssi client in a tmux session, always running

0.0.0.0 (all interfaces), 6697, (SSL HTTPS), znc, znc web interface, for configuring the znc service

localhost, 9997 (SSL IRC), znc, znc irc server, only visible inside container, only IRC client is local irssi program terminal client

localhost, 6667, (http IRC), bitlbee, bitlbee irc server, only visible inside container, only client is localhost ZNC server
```

The user is intended to access the IRC service primarily as the user `irssi`, on ssh port 22. Via public-private SSH key authentication (no ssh password). The container's irssi program itself is always kept running under a perpetual tmux session named `tmux`. Which supports simultaneous logins from multiple computers.

### Connecting to the irssi session

From a remote machine:

Connect via ssh terminal session by logging in as the user `irssi`. For example: `ssh irssi@your_container_ip`. You must have a keyfile which is listed in the container's ssh `known_hosts` file.

From local machine (same docker host):

```sh
docker exec -it CONTAINER_NAME bash [return]
irssi [return]
```

### Disconnecting from an irssi session

In these cases, the irssi program and it's TMUX session will be kept running as normal:

* It is preferred to disconnect with the default TMUX keybinding of `Ctrl-B` then `d`.
* You may also disconnect by killing ssh window in your ssh client. Eg `ctrl+c`

In these cases, the irssi program will exit:

* Quit the irssi program and naturally end the tmux session with `/quit` in irssi
* Kill the irssi program and disconnect by killing the tmux session with `Ctrl-B` then `@`

However in these last 2 cases ^^ a new tmux session and instance of the irssi program will be re-launched within < 3 seconds. So in general your irssi client is always kept running. So long as its docker container is kept running.

The container's ZNC and Bitlbee servers are also kept running too. Like irssi, if they crash or are exited for any reason, then they will be automatically restarted within a few seconds.

### File permissions

There is the main unix account `irssi`. However this container also has unix accounts named `bitlbee` and `znc` for those other supportive services.

By specifying an alternative uid and gid as a number, this lets you control which folder(s) those specific services have read/write access to. For example, setting these daemons to your own local user account's UID will allow you to access these services IRC `/config` files from outside of the docker session and on the host machine.

The default `uid:gid` of these accounts is named after their TCP port number:

```sh
USER, UID, GID
irssi, 22, 22
znc, 6697, 6697
bitlbee, 6667, 6667
```

You can change the unix UIDs and/or GIDs to your liking by setting the following docker env vars:

```sh
irssi_uid=XXX
irssi_gid=YYY

znc_uid=XXX
znc_gid=YYY

bitlbee_uid=XXX
bitlbee_gid=YYY
```

### Docker Compose

Sorry there is no example for Docker Compose at this time. But you may do something similar:

```sh
crane.yml:

containers:

  irssi:
    image: dreamcat4/irssi
    run:
      net: none
      volume:
        - /path/to/my/irc/current.config:/config
        - /path/to/my/irc/logs:/logs
      env:
        - irssi_uid=65534
        - irssi_gid=65534
        - pipework_wait=eth0
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.17
      detach: true
```

The `pipework_` variables are used to setup networking with the `dreamcat4/pipework` helper image.


