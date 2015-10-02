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


# Install jackett dependancies
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qqy curl bzip2 sudo libmono-cil-dev libcurl4-openssl-dev \
 && $_apt_clean


# Download jackett
ENV jackett_version="0.6.7"
RUN curl -Lo /tmp/jackett.tar.bz2 https://jackett.net/Download/v${jackett_version}/Jackett.Mono.v${jackett_version}.tar.bz2 \
 && mkdir /jackett && tar -xjf /tmp/jackett.tar.bz2 --strip-components=1 -C /jackett; rm -f /tmp/jackett.tar.bz2


# Setup sonarr /config dir and /media folder
RUN groupadd -o -g 9117 jackett \
 && useradd -o -u 9117 -N -g jackett --shell /bin/sh -d /config jackett \
 && install -o jackett -g jackett -d /config /media


# Global config
ADD config /config/


# Launch script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Default container settings
VOLUME /config
EXPOSE 9117
ENTRYPOINT ["/init","/entrypoint.sh","-l","-t"]




