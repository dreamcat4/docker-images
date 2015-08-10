FROM ubuntu-debootstrap:14.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


# Install s6-overlay
ENV s6_overlay_version="1.13.0.0"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar zxf /tmp/s6-overlay-amd64.tar.gz -C / && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar -zxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean


# Launch script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Default container settings
ENTRYPOINT ["/init","/entrypoint.sh"]


# usage:
#
# file - crane.yml:
#
# containers:
#   wan.test:
#     image: dreamcat4/wan.test
#     dockerfile: wan.test
#     run:
#       net: none
#       env:
#         - pipework_wait=eth0 eth1
#         - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ dhcp 0a:00:00:91:00:04
#         - pipework_cmd_eth1=eth0 -i eth1 @CONTAINER_NAME@ dhcp 0a:00:00:91:02:44
#         - lan_interface=eth0
#         - wan_interface=eth1
#       detach: true
#
#
# commands to run:
#
# $ crane provision -v wan.test
# $ crane create -v --recreate wan.test
# $ docker start wan.test
# $ docker exec -it wan.test bash
# # > ping -c1 8.8.8.8



