# Jackett

### Configuration

All user configuration is performed in the web interface. Therefore there is no pre-seeded `/config` files. You are recommended to bind-mount all of your needed host folders, and backup independantly your `jackett` config directory with some scripted / scheduled task.

You will use jackett's web interface to specify it's configuration. Since jackett is an indexer with local API access, there are no folders to mount aside from the configuration in `/config`.

### File permissions

By default jackett will run as the `jackett` user and group. With a default `uid:gid` of `9117:9117`. The same as it's TCP port number. So you will never forget.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
jackett_uid=XXX
jackett_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) jackett has read/write access to.

#### Add your host user account to the jackett group

If you do not change jackett's gid number to match your other accounts, then you can instead permit your own host account(s) file access to jackett's folders by making the group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will need to create a `jackett` group, adding your own user account to be a member of the same group gid (the default value of jackett's gid is `9117`). Copy-paste these commands:

```sh
sudo groupadd -g 9117 jackett
sudo usermod -a -G jackett $(id -un)
```

### Docker Compose

Sorry there is no example for Docker Compose at this time. But you may do something similar:

```sh
crane.yml:

containers:

  jackett:
    image: dreamcat4/jackett
    run:
      net: none
      env:
        - jackett_uid=65534
        - jackett_gid=44
        - pipework_wait=eth0
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.17
      detach: true
```

The `pipework_` variables are used to setup networking with the `dreamcat4/pipework` helper image.


