FROM ubuntu:20.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG DEBIAN_FRONTEND=noninteractive


# Install s6-overlay
ARG s6_overlay_version="1.22.1.0"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar hzxf /tmp/s6-overlay-amd64.tar.gz -C / --exclude=usr/bin/execlineb \
 && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin/execlineb && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar hzxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean


# Install deluge
RUN apt-get update -qq && apt-get install -qqy lsb-release sudo curl socat iproute2 tcpdump jq iputils-ping iputils-tracepath inetutils-traceroute net-tools less nmap dnsutils nano tzdata deluged deluge-web deluge-console \
 && $_apt_clean

# Patch deluge migration bug, see - https://forum.deluge-torrent.org/viewtopic.php?t=55662
RUN sed -i -e "s/def findCaller(self, stack_info=False):  # NOQA: N802/def findCaller(self, *args, **kwargs):  # NOQA: N802/g" /usr/lib/python3/dist-packages/deluge/log.py

# Set default locale
RUN apt-get update -qqy && apt-get install -qqy lsb-release locales && $_apt_clean
ARG LANG="en_US.UTF-8"
RUN sed -i "/$LANG/s/^# //g" /etc/locale.gen && locale-gen && update-locale LANG=$LANG


# Relocate the locale files in /usr/lib/locale/
RUN mkdir -p /config/.link/usr/lib/ /config/.link/etc \
 && mv /usr/lib/locale /config/.link/usr/lib/ \
 && mv /etc/locale.gen /config/.link/etc \
 && ln -sf /config/.link/usr/lib/locale /usr/lib/ \
 && ln -sf /config/.link/etc/locale.gen /etc/

# Symlink the 2 timezone files
ENV TIMEZONE="Etc/UTC"
RUN echo "$TIMEZONE" > /config/.link/etc/timezone \
 && ln -sf /config/.link/etc/timezone /etc/timezone \
 && ln -sf /usr/share/zoneinfo/$TIMEZONE /config/.link/etc/localtime \
 && ln -sf /config/.link/etc/localtime /etc/localtime \
 && dpkg-reconfigure tzdata


# Setup the deluge user
RUN groupmod -o -g 8112 --new-name deluge debian-deluged \
 && usermod -o -u 8112 --login deluge --shell /bin/sh -d /config debian-deluged \
 && install -o deluge -g deluge -d /config /torrents /downloads


# Setup cmdline access to deluge-console
ENV TERM=linux TERMINFO=/etc/terminfo
RUN mkdir -p /root/.config && ln -s /config /root/.config/deluge


# Global config
ADD config/core/default+ /config/
ADD config/plugins/official/blocklist+ /config/
ADD config/plugins/official/notifications+ /config/
ADD config/plugins/official/web+ /config/
ADD config/plugins/third.party/autopriority+ /config/
ADD config/plugins/third.party/autoremoveplus+ /config/
ADD config/plugins/third.party/batchrenamer+ /config/
ADD config/plugins/third.party/labelplus+ /config/
ADD config/plugins/third.party/libtorrentconfig+ /config/
ADD config/plugins/third.party/myscheduler+ /config/
ADD config/plugins/third.party/webapi+ /config/
ADD config/users/deluge+ /config/


# Launch script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Default container settings
VOLUME /config /torrents /downloads
EXPOSE 58846 8112
ENTRYPOINT ["/init","/entrypoint.sh","--config=/config"]


