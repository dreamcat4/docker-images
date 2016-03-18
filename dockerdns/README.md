
# dockerdns

This is a small container (14mb) based on Alpine linux. It uses `dnsmasq` to forward local DNS requests on to [docker's internal DNS server](https://docs.docker.com/engine/userguide/networking/configure-dns/) (eg loopback address `127.0.0.11`).

If you point your routers `dnsmasq.conf` to also use this container's IP address, then it will resolve DNS queries of your currently running docker containers on the specified docker network. So you must start this container with `--net=DOCKER_NETWORK_NAME` for it to be on that same docker network as your other containers. And maybe to avoid recursion bug, possibly override its `--dns=` flag to something else. See next sections for more infos.

## Usage

Its pretty simple. See final docker compose section, or:

```sh
docker run --net=YOUR_DOCKER_NETWORK_NAME --ip=IP_OF_DOCKERDNS_CONTAINER --dns=8.8.8.8 dreamcat4/dockerdns
```

### LAN Router configuration

This setup assumes you have dnsmasq running as a private DNS server of your local LAN. For example on a DDWrt Router, or pfSense, OpenWRT / or whatever the device you have. So we need to point that device to ask our dockerdns container for DNS queries on container names. Then add this lines to it's `dnsmasq.conf` file, or similar DNS configuration pages:

```sh
# For dockerdns local container lookups:

# 1. Forward all dns requests that end in '.DOCKER_NETWORK_NAME'
# As the 'docker network name' is also its toplevel .TLD of dockers internal dns
server=/DOCKER_NETWORK_NAME/IP_OF_DOCKERDNS_CONTAINER


# 2. To also forward (and try to resolve as containers) any remaining un-matched dns requests which have no .TLD
server=//IP_OF_DOCKERDNS_CONTAINER

# Also be sure to also DISABLE (comment-out) these following 2 options so your router's dnsmasq will forward un-matched requests without .TLD endings
# domain-needed
# expand-hosts
```

That assumes all your local clients already use your local router as their DNS server. Now that device in turn can ask this docker container for otherwise not-matched queries on running container names. Any stopped container will not be resolved by this docker's DNS server.

But wait... we are not done yet, because there is a problem, characterized by slow or unresponsive DNS lookups. That is tackled in next section:

### Recursive dns loop

There can be slow response or failed lookups when using this container. That may be since docker is taking from your host's `resolv.conf` as the upstream DNS server. If you `docker logs <THIS_CONTAINER>` and find `max requests limit reached` error messages. Then there is a recursive DNS loop. Not sure why that happens.

To break the DNS loop, just override this container's default dns upstream server, to avoid it being taken automatically from your docker host's `resolv.conf` file. For example setting `docker run --dns=8.8.8.8` will point to googles public dns servers instead. Or `208.67.220.220` / similar for OpenDNS servers.

### Docker Compose

Sorry there is no example for Compose at this time. But it is something like this:

```yaml

containers:

  dockerdns:
    image: dreamcat4/dockerdns
    run:
      net: DOCKER_NETWORK_NAME
      ip: IP_OF_DOCKERDNS_CONTAINER
      dns:
       - 208.67.220.220 # or 8.8.8.8
      detach: true

```


