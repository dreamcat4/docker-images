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


# Supportive pkgs
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    iproute2 net-tools wget curl git sudo nano less man && $_apt_clean

# Output folder
RUN mkdir -p /out



# ===
# dnsmasq - install build time dependancies
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates make gcc && $_apt_clean

# dnsmasq - Build from source
RUN mkdir -p /build/dnsmasq
WORKDIR /build/dnsmasq

# dnsmasq - git checkout
RUN git clone git://thekelleys.org.uk/dnsmasq.git && cd dnsmasq \
 && dnsmasq_version="$(git tag  | grep -E 'v[0-9][0-9]*\.[0-9][0-9][rc]*[0-9]*$' | sort | tail -1)" \
 && release_version=$(git tag | grep -E "^${dnsmasq_version%rc*}$" || true) \
 && if [ "$release_version" ]; then dnsmasq_version=$release_version; fi \
 && echo "$dnsmasq_version" > /out/dnsmasq_version \
 && git checkout "${dnsmasq_version}"

# dnsmasq - compile & install
RUN cd dnsmasq && sed -i -e 's|/usr/local|/usr|' Makefile && make install DESTDIR=$PWD/out \
 && mkdir -p out/etc && cp dnsmasq.conf.example out/etc/

# dnsmasq - Create tarball in /out/
RUN cd dnsmasq/out && tar -czvf /out/dnsmasq-$(cat /out/dnsmasq_version)_linux-x86_64.tar.gz *



# ===
# ipxe - install build time dependancies
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gcc binutils make perl syslinux liblzma-dev genisoimage && $_apt_clean


# ipxe - Build from source
RUN mkdir -p /build/ipxe \
 && date -I > /out/ipxe_version

WORKDIR /build/ipxe

# ipxe - git checkout
RUN git clone git://git.ipxe.org/ipxe.git

# RUN cd ipxe \
#  && ipxe_version="$(git tag | grep -E 'v[0-9][0-9]*\.[0-9]\.[0-9][-rc]*[0-9]*$' | sort | tail -1)" \
#  && release_version=$(git tag | grep -E "^${ipxe_version%-rc*}$" || true) \
#  && if [ "$release_version" ]; then ipxe_version=$release_version; fi \
#  && echo "$ipxe_version" > /out/ipxe_version \
#  && git checkout "${ipxe_version}"

# Disable entropy gathering - avoids +20 seconds boot delay
ADD ipxe/nocrypto /build/ipxe/ipxe/src/config/local/nocrypto

# ipxe - compile & install
RUN cd ipxe/src \
 && CONFIG=nocrypto make bin/undionly.kpxe \
 && CONFIG=nocrypto make bin-x86_64-efi/ipxe.efi

RUN mkdir -p out \
 && cp ipxe/src/bin/undionly.kpxe out/ \
 && cp ipxe/src/bin-x86_64-efi/ipxe.efi out/

# ipxe - Create tarball in /out/
RUN cd /build/ipxe/out && tar -czvf /out/ipxe-$(cat /out/ipxe_version)_linux-x86_64.tar.gz *



# # ===
# # istgt - install build time dependancies
# RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
#     curl wget gcc binutils make libssl-dev && $_apt_clean

# # istgt - Build from source
# RUN mkdir -p /build/istgt \
#  && curl --silent http://svnweb.freebsd.org/ports/head/net/istgt/Makefile?view=co | grep "PORTVERSION=" | cut -f2 > /out/istgt_version

# WORKDIR /build/istgt - dead

# # istgt - download source tarball
# RUN wget http://www.peach.ne.jp/archives/istgt/istgt-$(cat /out/istgt_version).tar.gz \
#  && tar -zxf istgt-$(cat /out/istgt_version).tar.gz && ln -sf istgt-$(cat /out/istgt_version) istgt

# # istgt - compile & install
# RUN cd istgt \
#  && ./configure --sysconfdir=/etc --localstatedir=/var \
#     --localedir=/usr/share/locale --datarootdir=/usr/share --prefix=/usr --enable-symlink-device \
#  && make && make install DESTDIR=$PWD/out

# # istgt - Create tarball in /out/
# RUN cd /build/istgt/istgt/out && tar -czvf /out/istgt-$(cat /out/istgt_version)_linux-x86_64.tar.gz *



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





