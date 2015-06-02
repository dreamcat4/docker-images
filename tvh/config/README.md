<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
 

- [Tvheadend](#tvheadend)
  - [dreamcat4/tvh.config](#dreamcat4tvhconfig)
  - [Customizing the Dockerfile](#customizing-the-dockerfile)
  - [Building](#building)
  - [Using](#using)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Tvheadend

A docker image of Tvheadend Server.

For more information about these tvheadend docker images, please see the full documentation at:

[https://github.com/dreamcat4/docker-images/blob/master/tvh/README.md](https://github.com/dreamcat4/docker-images/blob/master/tvh/README.md)

### dreamcat4/tvh.config

This is an example tvheadend config image, which you need to customize and build for yourself. You must pre-seed with your own config files taken from a previous tvheadend config folder.

* Base image MUST be `ubuntu-debootstrap:14.04` and not tvheadend.
  * To set the missing localization files, including your local timezone.
* In build folder, `config/` contains all the atomic config subfolders.

### Customizing the Dockerfile

Writing the config `Dockerfile`:

Example:

https://github.com/dreamcat4/docker-images/blob/master/tvh/config/Dockerfile

* `print-config` script to list all available configuration elements.
* The `+` is a pathname seperator. For arbitrary nesting. For example:
  * `config/folder+/accesscontrol/` means that `accesscontrol/` is added into tvheadend config.

### Building

```sh
docker build --rm --tag=dreamcat4/tvh.config tvh/config
```

### Using

```sh
 docker create --privileged --volume /media/hdd/Tv/Recordings:/recordings --volumes-from tvh.config.uk.ota --name tvh dreamcat4/tvheadend --satip_xml http://satip.lan:8080/desc.xml
```

Will mount your built `/config` volume inside of the tvheadend image.

```yaml
crane.yml:

containers:
  tvh.config.uk.ota:
    image: dreamcat4/tvh.config
    dockerfile: tvh/config

  tvh:
    image: dreamcat4/tvheadend
    run:
      net: none
      cmd: --satip_xml http://satip.lan:8080/desc.xml
      volume:
        - /media/hdd/Tv/Recordings:/recordings
      volumes-from:
        - tvh.config.uk.ota
```




