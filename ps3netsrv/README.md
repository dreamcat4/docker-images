## Docker-Ps3netsrv
**_A docker image of ps3netsrv_**

**Source:** [McCloud](http://lime-technology.com/forum/index.php?topic=37859.0)

* Smaller image size
* Added `pipework_wait=<interface>` env var [jpetazzo/pipework](https://github.com/jpetazzo/pipework).
* Other minor improvement

Page on DockerHub ---> [here](https://registry.hub.docker.com/u/dreamcat4/ps3netsrv/).

### Examples

#### Cmdline

```sh
docker run -v /path/to/my/ps3/GAMES:/games dreamcat4/ps3netsrv

Usage: ./ps3netsrv rootdirectory [port] [whitelist]
Default port: 38008
Whitelist: x.x.x.x, where x is 0-255 or * (e.g 192.168.1.* to allow only connections from 192.168.1.0-192.168.1.255)
```

You may specify your own unique command line arguments in the regular docker fashion. As shown in the above `--help`. For example:

```sh
docker run -v /path/to/my/ps3/GAMES:/games dreamcat4/ps3netsrv /games 38009 192.168.1.*
```

### File permissions

By default ps3netsrv will run as the `ps3netsrv` user and group. With a default `uid:gid` of `38008:38008`. Same as it's TCP port number.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
ps3netsrv_uid=XXX
ps3netsrv_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) ps3netsrv has read/write access to.

#### Crane

```yaml
containers:
  myapp:
    image: dreamcat4/ps3netsrv
    volume:
      - /path/to/my/ps3/GAMES:/games
    run:
      detach: true
      env:
        - pipework_wait=eth1
        - pipework_cmd=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.101
```

### Credit

* Version 1 - [McCloud/ps3netsrv](https://github.com/McCloud/ps3netsrv) - by McCloud scottispro@gmail.com
* Minor revisions - Dreamcat4
