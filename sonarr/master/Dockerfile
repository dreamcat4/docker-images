FROM ubuntu:20.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV sonarr_release=master


ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true


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


# Install gnupg2
RUN apt-get update -qq && apt-get install -qqy gnupg2 && $_apt_clean


# Install sonarr
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xA236C58F409091A18ACA53CBEBFF6B99D9B78493 \
 && echo "deb http://apt.sonarr.tv ${sonarr_release} main" >> /etc/apt/sources.list \
 && apt-get update -qq && apt-get install -qqy lsb-release sudo libmono-cil-dev nzbdrone \
 && $_apt_clean

# to modify sonarr image for curl
# ====
# add apt pkgs:
# 	curl iputils-ping ca-certificates

# ln -s /usr/lib/x86_64-linux-gnu/libcurl-gnutils.so.4 /opt/NzbDrone/libcurl.so.4


# Setup sonarr /config dir and /media folder
RUN groupadd -o -g 8989 sonarr \
 && useradd -o -c "Also known as nzbdrone - runs mono NzbDrone.exe" \
    -u 8989 -N -g sonarr --shell /bin/sh -d /config sonarr \
 && install -o sonarr -g sonarr -d /config /media


# Launch script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Default container settings
VOLUME /config /media
EXPOSE 8989 9898
ENTRYPOINT ["/init","/entrypoint.sh"]




