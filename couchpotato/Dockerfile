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
    apt-get install -qqy sudo iproute2 net-tools git python python-openssl python-lxml && $_apt_clean


# Download couchpotato
RUN git clone https://github.com/CouchPotato/CouchPotatoServer.git /couchpotato \
 || git clone https://github.com/RuudBurger/CouchPotatoServer.git  /couchpotato

# $ git clone https://github.com/___???___/CouchPotatoServer.git
# Cloning into 'CouchPotatoServer'...
# fatal: Could not read from remote repository.
# Please make sure you have the correct access rights
# and the repository exists.


# Setup the couchpotato user
RUN groupadd -o -g 5050 couchpotato \
 && useradd  -o -u 5050 -N -g couchpotato --shell /bin/sh -d /config couchpotato \
 && install -o couchpotato -g couchpotato -d /config /media


# Copy configuration files
ADD config.default /etc/config.preseed
ADD config.custom  /etc/config.preseed


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Default container settings
VOLUME /config /torrents /downloads
EXPOSE 5050
ENTRYPOINT ["/init"]
