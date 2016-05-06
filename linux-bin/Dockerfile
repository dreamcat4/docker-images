FROM ubuntu:16.04
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


# Supportive pkgs
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget curl git sudo nano less man && $_apt_clean

# Output folder
RUN mkdir -p /out


# ===
# dnsmasq - install build time dependancies
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates make gcc && $_apt_clean


# dnsmasq - Build external modules
RUN mkdir -p /build/dnsmasq
WORKDIR /build/dnsmasq

# dnsmasq - ./configure && make && make install
RUN git clone git://thekelleys.org.uk/dnsmasq.git && cd dnsmasq \
 && dnsmasq_version="$(git tag  | grep -E 'v[0-9][0-9]*\.[0-9][0-9]$' | tail -1)" \
 && echo "$dnsmasq_version" > /out/dnsmasq_version \
 && git checkout "${dnsmasq_version}" \
 && sed -i -e 's|/usr/local|/usr|' Makefile


# dnsmasq - Apply patch, compile dnsmasq
ADD dnsmasq/fix--dhcp-proxy-for-uefi-clients_02-mar-2016_jpolok.patch pxe-uefi.patch
RUN cd dnsmasq && patch -p1 < ../pxe-uefi.patch \
 && echo && echo WE CHANGED THIS CODE... && echo && git diff && echo && echo END OF CHANGES. Compiling... && echo \
 && make install DESTDIR=$PWD/out \
 && mkdir -p out/etc && cp dnsmasq.conf.example out/etc/


# dnsmasq - Create tarball in /out/
RUN cd dnsmasq/out && tar -czvf /out/dnsmasq-$(cat /out/dnsmasq_version)_linux-x86_64.tar.gz *


# Upload linux binaries --> bintray.com
WORKDIR /out
ADD upload-to-bintray /bin/
RUN chmod +x /bin/upload-to-bintray


# Execute our upload script
ADD bintray-env /out/
RUN upload-to-bintray && rm /out/bintray-env && ls -lsa /out/


# Default container settings
VOLUME /out
ENTRYPOINT ["/init","/bin/sleep","99999999"]





