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


# Install deluge
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive \
    apt-get install -qqy sudo socat iproute2 deluged deluge-web deluge-console \
 && $_apt_clean

# Install openvpn
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive \
    apt-get install -qqy openvpn openssl net-tools easy-rsa dante-server curl wget ca-certificates \
 && $_apt_clean


# Setup the deluge user
RUN groupmod -o -g 8112 --new-name deluge debian-deluged \
 && usermod -o -u 8112 --login deluge --shell /bin/sh -d /config/deluge debian-deluged \
 && install -o deluge -g deluge -d /config/deluge /torrents /downloads


# Setup cmdline access to deluge-console
ENV TERM=linux TERMINFO=/etc/terminfo
RUN mkdir -p /root/.config && ln -s /config /root/.config/deluge


# Copy configuration files
ADD config.default /etc/config.preseed
ADD config.custom  /etc/config.preseed


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Default container settings
VOLUME /config /torrents /downloads
EXPOSE 58846 8112
ENTRYPOINT ["/init"]


