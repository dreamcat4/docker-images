FROM ubuntu-debootstrap:14.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

# Install s6-overlay
ENV s6_overlay_version="1.10.0.3"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar zxf /tmp/s6-overlay-amd64.tar.gz -C / && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar -zxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean


# Install samba
RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends samba \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    useradd smbuser -M && \
    sed -i 's|^\(   log file = \).*|\1/dev/stdout|' /etc/samba/smb.conf && \
    sed -i 's|^\(   unix password sync = \).*|\1no|' /etc/samba/smb.conf && \
    sed -i '/Share Definitions/,$d' /etc/samba/smb.conf && \
    echo '   security = user' >> /etc/samba/smb.conf && \
    echo '   directory mask = 0775' >> /etc/samba/smb.conf && \
    echo '   force create mode = 0664' >> /etc/samba/smb.conf && \
    echo '   force directory mode = 0775' >> /etc/samba/smb.conf && \
    echo '   force user = smbuser' >> /etc/samba/smb.conf && \
    echo '   force group = users' >> /etc/samba/smb.conf && \
    echo '' >> /etc/samba/smb.conf
COPY samba.sh /usr/bin/

VOLUME ["/etc/samba"]

EXPOSE 139 445

ENTRYPOINT ["/init","/usr/bin/samba.sh"]

