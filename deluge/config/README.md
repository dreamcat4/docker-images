## Deluge

A docker image of Deluge Daemon & WebUI.

### dreamcat4/deluge.config

This is an example of a deluge config image, which you would customize and build for yourself. You must pre-seed with your own config files taken from a previous deluge `/config` folder.

* Base image MUST be `ubuntu-debootstrap:14.04` and not deluge.
  * To set the missing localization files, including your local timezone.
* In build folder, `config/` contains all the atomic config subfolders.

### Customizing the Dockerfile

Writing the config `Dockerfile`:

Example:

https://github.com/dreamcat4/docker-images/blob/master/deluge/config/Dockerfile

* `print-config` script to list all available configuration elements.
* The `+` is a pathname seperator. For arbitrary nesting. For example:
  * `config/folder+/auth` means that the file `auth` is added into the deluge `/config` folder.

### Building

```sh
docker build --rm --tag=dreamcat4/deluge.config deluge/config
```

### Using

```sh
docker create --volumes-from deluge.config --name deluge dreamcat4/deluge
```

Will mount your built `/config` volume inside of the tvheadend image.

```yaml
crane.yml:

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




