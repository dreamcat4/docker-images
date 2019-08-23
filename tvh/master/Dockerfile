FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


# Choose from: master, unstable, testing, or stable
ENV tvh_release=master


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


# Install gnupg2
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qqy gnupg2 && $_apt_clean


# Install xmltv & tvheadend
RUN apt-get update -qq && apt-get install -qqy apt-transport-https \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61 \
 && echo deb https://dl.bintray.com/dreamcat4/ubuntu ${tvh_release} main > /etc/apt/sources.list.d/tvheadend.list \
 && apt-get update -qq && apt-get install -qqy bzip2 libavahi-client3 xmltv \
 && apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qqy udev tvheadend \
 && rm -rf /home/hts && $_apt_clean


# Relocate the timezone file
RUN mkdir -p /config/.etc && mv /etc/timezone /config/.etc/ && ln -s /config/.etc/timezone /etc/

# Set locale
ENV LANG="en_US.UTF-8"

RUN apt-get update -qqy && apt-get install -qqy locales && $_apt_clean \
 && grep "$LANG" /usr/share/i18n/SUPPORTED >> /etc/locale.gen && locale-gen \
 && update-locale LANG=$LANG

# Relocate the locale files in /usr/lib/locale/
RUN mkdir -p /config/.link/usr/lib/ /config/.link/etc \
 && mv /usr/lib/locale /config/.link/usr/lib/ \
 && mv /etc/locale.gen /config/.link/etc \
 && ln -s /config/.link/usr/lib/locale /usr/lib/ \
 && ln -s /config/.link/etc/locale.gen /etc/


# Global config
ADD config/backup/unknown.tar.bz2+ /config/
ADD config/dvr/recordings+ /config/
ADD config/users/admin+ /config/


# Configure the hts user account and it's folders
RUN groupmod -o -g 9981 hts \
 && usermod -o -u 9981 -a -G video -d /config hts \
 && install -o hts -g hts -d /config /recordings


# Launch script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Default container settings
VOLUME /config /recordings
EXPOSE 9981 9982
ENTRYPOINT ["/init","/entrypoint.sh","-u","hts","-g","hts","-c","/config"]

