***Source: [kyma/docker-nginx](https://github.com/KyleAMathews/docker-nginx)***

[![logo](http://nginx.org/nginx.png)](http://nginx.org)

# Nginx

A docker image of Nginx v1.9.5+. [DockerHub Page](https://registry.hub.docker.com/u/dreamcat4/nginx/). A high-performance Nginx base image for Docker to serve static websites. It will serve anything in the `/www` directory.


### Enable SSL

First, to obtain an SSL certificate: https://letsencrypt.org/getting-started/

To enable SSL, put your certs in a `/ssl` volume and then to enable the `default-ssl` site: `docker run -e nginx_ssl=true dreamcat4/nginx`. You will need the following 2 certificate files in your mounted `/ssl` volume:

    /ssl/server.crt
    /ssl/server.key

Note: Enabling SSL does not disable HTTP access. Both methods are available and there is no automiatic redirect from HTTP --> SSL. Although there should be in here a reqrite rule to do this, unfortunately there isn't one.


### nginx.conf

The nginx.conf and mime.types are pulled with slight modifications from
the h5bp Nginx HTTP server boilerplate configs project at
https://github.com/h5bp/server-configs-nginx

### File permissions

By default nginx will run as the `nginx` user and group. With a default `uid:gid` of `8080:8080`. This is a typical / sensible value for such a service.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
nginx_uid=XXX
nginx_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) nginx has read/write access to.

#### Add your host user account to the nginx group

This shouldn't really be necessary except for in the case of file uploads. If you do not wish change nginx's gid number you can instead permit your own host account(s) file access to nginx's folders by making them group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will need to create an `nginx` group, adding your own user account to be a member of the same group gid (the default value of nginx's gid is `8080`). Copy-paste these commands:

```sh
sudo groupadd -g 8080 nginx
sudo usermod -a -G nginx $(id -un)
```

### Docker Compose

Sorry there is no example for Docker Compose at this time. But you may do something similar:

```sh
crane.yml:

containers:

  nginx:
    image: dreamcat4/nginx
    run:
      net: none
      log-opt:
        - max-size=10m
        - max-file=2
      volume:
        - /www
      env:
        - nginx_uid=65534
        - nginx_gid=65534
        - pipework_wait=eth0
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.15
      detach: true
```

The `pipework_` variables are used to setup networking with the `dreamcat4/pipework` helper image.


