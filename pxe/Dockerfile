FROM dreamcat4/nginx
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"
# apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y


# Install support pkgs
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    iproute2 curl wget nano man less sudo unzip xorriso tcpdump wimtools \
 && $_apt_clean


# Install dnsmasq
RUN wget -O /tmp/dnsmasq.tar.gz https://dl.bintray.com/dreamcat4/linux/dnsmasq/dnsmasq-latest_linux-x86_64.tar.gz \
 && tar zxf /tmp/dnsmasq.tar.gz -C / --skip-old-files && $_clean


# RUN echo foo


# Change html folder from /www to /pxe
RUN sed -i -e 's|root /www;|root /pxe;|' /etc/nginx/sites-enabled/default


# Set default TERM and EDITOR
# ENV TERM=tmux-256color TERMINFO=/etc/terminfo EDITOR=nano
ENV TERM=xterm TERMINFO=/etc/terminfo EDITOR=nano


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d



# Add pxe.default/ tree
ADD pxe.default /etc/pxe.preseed


# Add user custom files
ADD pxe.custom /etc/pxe.preseed


# Install ipxe binaries
RUN wget -O /tmp/ipxe.tar.gz https://dl.bintray.com/dreamcat4/linux/ipxe/ipxe-latest_linux-x86_64.tar.gz \
 && mkdir -p /etc/pxe.preseed/ipxe && tar zxf /tmp/ipxe.tar.gz -C /etc/pxe.preseed/ipxe --skip-old-files \
 && wget -O /tmp/wimboot.zip http://git.ipxe.org/releases/wimboot/wimboot-latest.zip \
 && unzip -j /tmp/wimboot.zip */wimboot -d /etc/pxe.preseed/ipxe && $_clean


# Default container settings
VOLUME /pxe
EXPOSE 67 67/udp 69 69/udp
ENTRYPOINT ["/init"]



