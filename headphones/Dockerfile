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


# Install dependancies
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive \
    apt-get install -qqy sudo git python python-openssl flac lame && $_apt_clean


# Download headphones
RUN git clone https://github.com/rembo10/headphones.git \
 && cd headphones && git checkout develop


# Setup the headphones user
RUN groupadd -o -g 8181 headphones \
 && useradd  -o -u 8181 -N -g headphones --shell /bin/sh -d /config headphones \
 && install -o headphones -g headphones -d /config /media


# Copy configuration files
ADD config.default /etc/config.preseed
ADD config.custom  /etc/config.preseed


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Default container settings
VOLUME /config /downloads
EXPOSE 8181
ENTRYPOINT ["/init"]


