
# dockerdns

This is a small container (14mb), which uses `socat` to expose / port forward docker's new networking internal DNS server.

If you point your routers dnsmasq.conf to this container's IP address, then it could / should resolve DNS queries of your currently running docker containers on that same docker network. You must also start this container with `--net DOCKER_NETWORK_NAME`.

To add something appropriate to your `dnsmasq.conf` file:

```sh
# Only use DNS servers configured here
no-resolv

# Never forward requests w/o a .TLD
domain-needed
bogus-priv

#expand-hosts

# Local docker-dns

# Forward all dns requests that end in '.DOCKER_NETWORK_NAME'
# (because your 'docker network name' is also its DNS TLD)
server=/DOCKER_NETWORK_NAME/IP_OF_DOCKERDNS_CONTAINER
```

### Docker Compose

Sorry there is no example for Compose at this time. But it is something like this:

```yaml

containers:

  dockerdns:
    image: dreamcat4/dockerdns
    run:
      net: DOCKER_NETWORK_NAME
      ip: IP_OF_DOCKERDNS_CONTAINER
      detach: true

```


