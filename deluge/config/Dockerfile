FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


# 1. Set locale - change 'en_US.UTF-8' --> the correct one for your county / region
# 1b. You will also need to specify the locale at run time e.g. `docker run -e LANG="en_US.UTF-8" ...`
ENV LANG="en_US.UTF-8"

RUN apt-get update -qqy && apt-get install -qqy locales && $_apt_clean \
 && grep "$LANG" /usr/share/i18n/SUPPORTED >> /etc/locale.gen && locale-gen \
 && update-locale LANG=$LANG

# 2. Must always move the lang files into '/config dir', where dreamcat4/deluge expects
RUN mkdir -p /config/.link/usr/lib/ /config/.link/etc \
 && mv /usr/lib/locale /config/.link/usr/lib/ \
 && mv /etc/locale.gen /config/.link/etc

# 3. Set your local timezone
ENV TIMEZONE="Europe/London"
RUN echo "${TIMEZONE}" > /config/.link/etc/timezone \
 && ln -sf /config/.link/etc/timezone /etc/timezone \
 && ln -sf /usr/share/zoneinfo/${TIMEZONE} /config/.link/etc/localtime \
 && ln -sf /config/.link/etc/localtime /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata



# 4. Populate the Deluge Config Folder with the config pieces you need

# # Instructions:
# # a. Run the cmd './print-config' in the build folder, to show all available ADD cmds
# # b. Paste the output of './print-config' in here. Comment out the ones you don't require
# # c. Create your own config pieces for tvheadend - must be taken from an existing setup

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


# Default parts - don't change this bit
VOLUME /config
ENTRYPOINT ["/bin/echo","/config volume for the dreamcat4/deluge image"]


