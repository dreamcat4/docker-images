FROM ubuntu:xenial-20160125
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


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
RUN apt-get update && apt-get install -y wget git sudo znc \
 libtime-duration-perl bitlbee bitlbee-plugin-otr \
 libwww-perl libnotify-bin libmime-base64-urlsafe-perl \
 irssi irssi-scripts irssi-plugin-otr irssi-plugin-xmpp \
 tmux openssh-server socat nano less nmap man && $_apt_clean


# Download scripts from https://scripts.irssi.org, and the irssi theme 'weed'
RUN git clone https://github.com/irssi/scripts.irssi.org.git \
 && git clone https://github.com/ronilaukkarinen/weed.git


# Setup bitlbee user
RUN groupmod -o -g 6667 bitlbee \
 && usermod -o -u 6667 -g bitlbee --shell /bin/bash -d /config/bitlbee bitlbee \
 && install -o bitlbee -g bitlbee -d /config/bitlbee


# Setup znc user
RUN groupadd -o -g 6697 znc \
 && useradd -o -u 6697 -g znc --shell /bin/bash -d /config/znc znc \
 && install -o znc -g znc -d /config/znc


# Setup irssi user
ENV TERM=linux TERMINFO=/etc/terminfo EDITOR=nano
RUN groupadd -o -g 22 irssi \
 && useradd -o -u 22 -g irssi --shell /bin/bash -d /config/irssi irssi \
 && install -o irssi -g irssi -d /config/irssi


# Setup sshd
ENV tmux_socket="/tmp/tmux.irssi.sock" tmux_session="tmux"
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


# Default container settings
VOLUME /config /logs
EXPOSE 6697 22
ENTRYPOINT ["/init"]








