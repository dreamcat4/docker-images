FROM ubuntu:xenial-20160125
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"
# apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y


# Install s6-overlay
ENV s6_overlay_version="1.17.1.1"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar zxf /tmp/s6-overlay-amd64.tar.gz -C / && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar -zxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean


# Install bitlbee, znc, irssi, tmux, sshd and other supportive pkgs
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y wget apt-transport-https ca-certificates \
 && wget -O- https://code.bitlbee.org/debian/release.key | apt-key add - \
 && echo "deb http://code.bitlbee.org/debian/master/wily/amd64/ ./" >> /etc/apt/sources.list \
 && wget -O- https://jgeboski.github.io/obs.key | apt-key add - \
 && echo "deb http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_15.10 ./" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C03AA79CFFEBD240 \
 && echo "deb http://ppa.launchpad.net/aap/pidgin/ubuntu wily main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 531EE72F4C9D234C \
 && echo "deb http://ppa.launchpad.net/nilarimogard/webupd8/ubuntu wily main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D1820DB22A11534E \
 && echo "deb https://weechat.org/ubuntu wily main" >> /etc/apt/sources.list \
 \
 && apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git sudo znc ngircd \
    libtime-duration-perl rsyslog bitlbee-libpurple bitlbee-plugin-otr \
    bitlbee-steam bitlbee-facebook \
    pidgin-sipe pidgin-skypeweb telegram-purple \
    python-dev python-pip pkg-config graphviz graphviz-dev python-cobe \
    libwww-perl libnotify-bin libmime-base64-urlsafe-perl \
    irssi make cpanminus irssi-scripts irssi-plugin-otr irssi-plugin-xmpp \
    weechat weechat-plugins \
    tmux openssh-server socat nano less man nmap \
 \
 && cpanm WebService::HipChat Algorithm::Diff \
 && pip install --upgrade pip \
 && pip install -r https://raw.githubusercontent.com/ProgVal/Limnoria/master/requirements.txt --upgrade \
 && pip install limnoria --upgrade && chmod +x /usr/local/bin/supybot* \
 && pip install -r https://raw.githubusercontent.com/ProgVal/Supybot-plugins/master/requirements.txt --upgrade \
 && wget -q -O- https://raw.githubusercontent.com/GLolol/SupyPlugins/master/requirements.txt | grep -v "Limnoria.git" > /tmp/glol.reqs.txt \
 && pip install -r /tmp/glol.reqs.txt --upgrade && rm /tmp/glol.reqs.txt \
 \
 && $_apt_clean

# For irssi / adv_windowlist.pl:
 # && cpanm Text::CharWidth \



# Hack, install older version of libprotobuf to meed dependancies
# This whatsapp-purple PPA needs newer ubuntu version as trusty 14.04 too old now
RUN wget -O /tmp/libprotobuf8_amd64.deb http://security.ubuntu.com/ubuntu/pool/main/p/protobuf/libprotobuf8_2.5.0-9ubuntu1_amd64.deb && dpkg -i /tmp/libprotobuf8_amd64.deb \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C777F0E392FAE28B \
 && echo "deb http://ppa.launchpad.net/whatsapp-purple/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y pidgin-whatsapp \
 && $_apt_clean


# NOTE: overlayfs bug causes pip dependancies install failure below ^^;
#   https://github.com/docker/docker/issues/12327#issuecomment-171496303
#   https://gist.github.com/amercader/4432ed33a73d510b4a08
#
# Using patch / feature branch with Frog's rejected PIP pr ! didnt work
# RUN apt-get update && apt-get install -y python-dev python-pip && pip install --upgrade pip \
#  && pip install git+https://github.com/FragLegs/pip@patch-for-issue-2953 && $_apt_clean



# Spline plugins with broken deps: "Stock Tweety WebHooks WorldTime"
# ENV _spline_plugins="GitPull LogTail Series Stock Supybot-Pastebin Travis Tweety UrbanDictionary Weather WebHooks WolframAlpha WorldTime ZNC"
ENV _spline_plugins="GitPull LogTail Series Supybot-Pastebin Travis UrbanDictionary Weather WebHooks WolframAlpha ZNC"

RUN mkdir -p limnoria-plugins/spline \
 && for _spline_plugin in $_spline_plugins; \
 do wget -q -O- https://raw.githubusercontent.com/reticulatingspline/${_spline_plugin}/master/requirements.txt | grep -v "Limnoria.git" > /tmp/spline.reqs.txt || break ; \
    echo "processing deps for \"reticulatingspline/${_spline_plugin}\":" && cat /tmp/spline.reqs.txt && echo \
 && pip install -r /tmp/spline.reqs.txt --upgrade && rm /tmp/spline.reqs.txt && echo \
  ; done \
 \
 && for _spline_plugin in $_spline_plugins; \
 do git clone https://github.com/reticulatingspline/${_spline_plugin} limnoria-plugins/spline/${_spline_plugin} \
  ; done \
 && $_apt_clean



# ! TEMP for bitlbee torchat, znc-push module
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y tor libcurl3 && $_apt_clean


# Bitlbee - libpurpletorchat
ENV _torchat_ver="2.0-alpha-14"
RUN wget -O /tmp/libpurpletorchat.tbz https://github.com/downloads/prof7bit/TorChat/libpurpletorchat-${_torchat_ver}-linux-x86-64.tar.bz2 \
 && tar -C /usr/lib/purple-2 --strip-components=1 -jxvf /tmp/libpurpletorchat.tbz libpurpletorchat/libpurpletorchat.so && $_apt_clean


# TODO: Future (not ready yet) - tox-prpl - https://github.com/jin-eld/tox-prpl/issues/54


# Irssi - Download scripts and themes
RUN git clone https://github.com/irssi/scripts.irssi.org.git \
 && git clone https://github.com/irssi-import/themes.git \
 && git clone https://github.com/huyz/irssi-colors-solarized

RUN mkdir -p limnoria-plugins \
 && git clone https://github.com/ProgVal/Supybot-plugins limnoria-plugins/progval \
 && git clone https://github.com/GLolol/SupyPlugins limnoria-plugins/glolol


RUN echo Checking limnoria was installed && ls -lsa /usr/local/bin/supybot


# Setup bitlbee user
RUN groupmod -o -g 6111 bitlbee \
 && usermod -o -u 6111 -g bitlbee --shell /bin/bash -d /config/bitlbee bitlbee \
 && install -o bitlbee -g bitlbee -d /config/bitlbee


# Setup atheme user
RUN groupadd -o -g 8153 atheme \
 && useradd -o -u 8153 -g atheme --shell /bin/bash -d /config/atheme atheme \
 && install -o atheme -g atheme -d /config/atheme


# Setup ngircd user
RUN groupadd -o -g 5914 ngircd \
 && useradd -o -u 5914 -g ngircd --shell /bin/bash -d /config/ngircd ngircd \
 && install -o ngircd -g ngircd -d /config/ngircd


# Setup limnoria user
RUN groupadd -o -g 1135 limnoria \
 && useradd -o -u 1135 -g limnoria --shell /bin/bash -d /config/limnoria limnoria \
 && install -o limnoria -g limnoria -d /config/limnoria


# Setup znc user
RUN groupadd -o -g 6697 znc \
 && useradd -o -u 6697 -g znc --shell /bin/bash -d /config/znc znc \
 && install -o znc -g znc -d /config/znc


# Setup irssi user
ENV TERM=linux TERMINFO=/etc/terminfo EDITOR=nano
RUN groupadd -o -g 22 irssi \
 && useradd -o -u 22 -g irssi --shell /bin/bash -d /config/irssi irssi \
 && install -o irssi -g irssi -d /config/irssi


# Sudo without password
RUN echo "irssi ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


# Setup sshd
ENV TERM="tmux-256color" tmux_socket="/tmp/tmux.irssi.sock" tmux_session="tmux" tmux_irc_clients="irssi weechat"
RUN mkdir -p /var/run/sshd \
 && echo "\n\n\
# Container specific sshd settings\n\
PasswordAuthentication no\n\
\n\
Match User irssi\n\
		ForceCommand tmux -S $tmux_socket -u attach-session -t $tmux_session\n\
\n" >> /etc/ssh/sshd_config


# Copy configuration files
ADD config.default /etc/config.preseed
ADD config.custom  /etc/config.preseed


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# ! temp
COPY znc-modules-linux-x86_64.tar.gz /tmp/
RUN tar zxf /tmp/znc-modules-linux-x86_64.tar.gz -C /usr/lib/znc/ --skip-old-files && $_clean

ENV atheme_version="7.2.6"
COPY atheme-${atheme_version}_linux-x86_64.tar.gz /tmp/atheme-linux-x86_64.tar.gz
RUN tar zxf /tmp/atheme-linux-x86_64.tar.gz -C / --skip-old-files && $_clean


# Default container settings
RUN echo Regenerating apt cache && apt-get update -qqy
VOLUME /config /irc
EXPOSE 6697 22
ENTRYPOINT ["/init"]








