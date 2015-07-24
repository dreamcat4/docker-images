FROM ubuntu-debootstrap:14.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


# 1. Set your local timezone
RUN mkdir -p /config/.etc/ && echo "Europe/London" > /config/.etc/timezone


# Uncomment these lines if you are not English or American
# and change 'en_US.UTF-8' --> the correct one for your county / region
# 2. Set the locale to your own country with 'locale-gen' cmd
# RUN apt-get update -qq && apt-get install -qqy locales && $_apt_clean \
#  && locale-gen en_US.UTF-8 && dpkg-reconfigure locales


# 3. Must always move the lang files into '/config dir', where dreamcat4/deluge expects
RUN mkdir -p /config/.var/lib/locales/ /config/.usr/lib/ \
 && mv /var/lib/locales/supported.d /config/.var/lib/locales/ \
 && mv /usr/lib/locale /config/.usr/lib/


# 4. Populate the Deluge Config Folder with the config pieces you need

# # Instructions:
# # a. Run the cmd './print-config' in the build folder, to show all available ADD cmds
# # b. Paste the output of './print-config' in here. Comment out the ones you don't require
# # c. Create your own config pieces for tvheadend - must be taken from an existing setup

ADD config/core/default+ /config/
ADD config/plugins/3rd.party/autopriority+ /config/
ADD config/plugins/3rd.party/autoremoveplus+ /config/
ADD config/plugins/3rd.party/batchrenamer+ /config/
ADD config/plugins/3rd.party/categorize+ /config/
ADD config/plugins/3rd.party/labelplus+ /config/
ADD config/plugins/3rd.party/libtorrentconfig+ /config/
ADD config/plugins/3rd.party/movetools+ /config/
ADD config/plugins/3rd.party/myscheduler+ /config/
ADD config/plugins/3rd.party/webapi+ /config/
ADD config/plugins/official/autoadd+ /config/
ADD config/plugins/official/blocklist+ /config/
ADD config/plugins/official/execute+ /config/
ADD config/plugins/official/label+ /config/
ADD config/plugins/official/notifications+ /config/
ADD config/plugins/official/scheduler+ /config/
ADD config/plugins/official/web+ /config/
ADD config/users/deluge+ /config/


# Default parts - don't change this bit
VOLUME /config
ENTRYPOINT ["/bin/echo","/config volume for the dreamcat4/deluge image"]


