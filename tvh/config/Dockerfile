FROM ubuntu:20.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG DEBIAN_FRONTEND=noninteractive


# 1. Set your local timezone
RUN mkdir -p /config/.link/etc/ && echo "Europe/London" > /config/.link/etc/timezone


# Get locales
RUN apt-get update -qqy && apt-get install -qqy lsb-release locales && $_apt_clean


# 2a. Uncomment this line to see the full list of available locales
# RUN cat /etc/locale.gen && false


# 2b. Set chosen locale - change 'en_US.UTF-8' --> the correct one for your county / region
ENV LANG="en_US.UTF-8"


# 2c. If importing this image simply as a volume, then also set
#     the locale at run time e.g. `docker run -e LANG="en_US.UTF-8" ...`


# Set locale
RUN sed -i "/$LANG/s/^# //g" /etc/locale.gen && locale-gen && update-locale LANG=$LANG


# 3. Must always move the lang files into '/config dir', where dreamcat4/deluge expects
RUN mkdir -p /config/.link/usr/lib/ /config/.link/etc \
 && mv /usr/lib/locale /config/.link/usr/lib/ \
 && mv /etc/locale.gen /config/.link/etc


# 4. Populate the Tvheadend Config Folder with the config pieces you need

# Instructions:
# a. Run the cmd './print-config' in the build folder, to show all available ADD cmds
# b. Paste the output of './print-config' in here. Comment out the ones you don't require
# c. Create your own config pieces for tvheadend - must be taken from an existing setup


# EXAMPLE for a generic 'UK' setup
ADD config/backup/unknown.tar.bz2+ /config/
ADD config/dvr/recordings+ /config/
ADD config/epg/ota/uk+ /config/
ADD config/global/language/uk+ /config/
ADD config/users/admin+ /config/


# Default parts - don't change this bit
VOLUME /config
ENTRYPOINT ["/bin/echo","/config volume for the dreamcat4/tvheadend image"]


