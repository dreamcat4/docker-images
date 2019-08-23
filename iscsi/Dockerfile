FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"
# apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y


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


# Install support pkgs, iscsi
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl wget nano man less sudo iscsitarget && $_apt_clean


# You must also "apt-get install iscsitarget" on your docker host, to install the kmod
# and run the following cmds on host side:
# sed -i -e 's/ISCSITARGET_ENABLE=false/ISCSITARGET_ENABLE=true/' /etc/default/iscsitarget
# sudo systemctl disable iscsitarget
# sudo service iscsitarget stop
# sudo modprobe iscsi_trgt


# Create target luns
# cd /iscsi/targets
# fallocate -l 10G FILENAME



# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Set default TERM and EDITOR
# ENV TERM=tmux-256color TERMINFO=/etc/terminfo EDITOR=nano
ENV TERM=xterm TERMINFO=/etc/terminfo EDITOR=nano


# Default container settings
RUN mkdir -p /iscsi/targets
VOLUME /iscsi/targets
EXPOSE 860 3260
ENTRYPOINT ["/init"]



