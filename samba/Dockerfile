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


# Install samba
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qqy iproute2 net-tools samba && $_apt_clean


# Create samba user as user 'nobody'
RUN useradd smbuser -o -u 65534 -M


# Generate smb.conf
RUN sed -i 's|^\(   log file = \).*|\1/dev/stdout|' /etc/samba/smb.conf \
 && sed -i 's|^\(   unix password sync = \).*|\1no|' /etc/samba/smb.conf \
 && sed -i '/Share Definitions/,$d' /etc/samba/smb.conf \
 && echo '   security = user' >> /etc/samba/smb.conf \
 && echo '   directory mask = 0775' >> /etc/samba/smb.conf \
 && echo '   force create mode = 0664' >> /etc/samba/smb.conf \
 && echo '   force directory mode = 0775' >> /etc/samba/smb.conf \
 && echo '   load printers = no' >>/etc/samba/smb.conf \
 && echo '   printing = bsd' >>/etc/samba/smb.conf \
 && echo '   printcap name = /dev/null' >>/etc/samba/smb.conf \
 && echo '   disable spoolss = yes' >>/etc/samba/smb.conf \
 && echo '' >> /etc/samba/smb.conf


# Launch script
COPY samba.sh /usr/bin/


# Default container settings
VOLUME ["/etc/samba"]
EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["/init","/usr/bin/samba.sh"]

