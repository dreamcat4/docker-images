FROM ubuntu-debootstrap:14.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


# 1. Set your local timezone
RUN mkdir -p /config/.etc/ && echo "Europe/London" > /config/.etc/timezone


# 2. Set the locale here with 'locale-gen' cmd if you are not English or American
# RUN apt-get update -qq && apt-get install -qqy locales && $_apt_clean \
#  && locale-gen en_US.UTF-8 && dpkg-reconfigure locales


# 3. Must always move the lang files into '/config dir', where dreamcat4/tvheadend expects
RUN mkdir -p /config/.var/lib/locales/ /config/.usr/lib/ \
 && mv /var/lib/locales/supported.d /config/.var/lib/locales/ \
 && mv /usr/lib/locale /config/.usr/lib/


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


