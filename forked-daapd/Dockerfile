FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


# Install s6-overlay
ENV s6_overlay_version="1.22.1.0"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar hzxf /tmp/s6-overlay-amd64.tar.gz -C / --exclude=usr/bin/execlineb \
 && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin/execlineb && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar hzxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean


# Install forked-daapd
RUN apt-get update && apt-get install -y sudo iproute2 net-tools forked-daapd && $_apt_clean


# Setup daapd user
RUN groupadd -o -g 3689 daapd \
 && usermod -o -u 3689 -g daapd --shell /bin/sh -d /config daapd \
 && install -o daapd -g daapd -d /config /music


# Configuration file
ADD forked-daapd.conf /etc/forked-daapd.conf.docker


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Default container settings
VOLUME /config /music
EXPOSE 3689 6600
ENTRYPOINT ["/init"]

