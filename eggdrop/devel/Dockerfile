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


# Install build deps
RUN apt-get update \
 && apt-get install -y wget git sudo build-essential gcc libc6 libtcl8.6 tcl8.6 tcl8.6-dev zlib1g tcllib wget unzip eggdrop-data


RUN useradd -c 'Eggdrop user' -m -d /home/eggdrop -s /bin/bash eggdrop
RUN chown -R eggdrop:eggdrop /home/eggdrop

USER eggdrop
ENV HOME /home/eggdrop

WORKDIR /home/eggdrop
RUN wget ftp://ftp.eggheads.org/pub/eggdrop/source/1.6/eggdrop1.6.21.tar.gz

RUN tar zxvf eggdrop1.6.21.tar.gz

ADD modules-extra/* /home/eggdrop/eggdrop1.6.21/src/mod/

WORKDIR /home/eggdrop/eggdrop1.6.21

RUN CFLAGS="-std=gnu89" ./configure --with-tclinc=/usr/include/tcl8.6/tcl.h --with-tcllib=/usr/lib/x86_64-linux-gnu/libtcl8.6.so

RUN make config

RUN make

RUN make install

WORKDIR /home/eggdrop

RUN cd eggdrop && mkdir tmp

ENTRYPOINT ["/bin/sleep","999999"]

