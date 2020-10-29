FROM ubuntu:20.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG DEBIAN_FRONTEND=noninteractive


# Install dependancies
RUN apt-get update -qq && apt-get install -qqy \
			git wget curl libcurl4-gnutls-dev zlib1g-dev bzip2 \
			build-essential pkg-config debhelper libssl-dev liburiparser-dev \
			python3 libavahi-client-dev libhdhomerun-dev libdvbcsa-dev \
			libavcodec-dev libavutil-dev libavformat-dev libswscale-dev \
			libavresample-dev libavfilter-dev libavcodec-extra a52dec cmake \
			dvb-apps gettext libpcre2-dev libiconv-hook-dev python3-minimal python-requests \
			libva-dev libva-drm2 libva-glx2 libva-wayland2 libva-x11-2 \
 && $_apt_clean


# Download tvheadend
RUN mkdir /build /out \
 && git clone https://github.com/tvheadend/tvheadend.git /build/tvheadend


