FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


# Install dependancies
RUN apt-get update -qq && apt-get install -qqy \
			git wget curl libcurl4-gnutls-dev zlib1g-dev bzip2 \
			build-essential pkg-config debhelper libssl-dev liburiparser-dev \
			python libavahi-client-dev libhdhomerun-dev libdvbcsa-dev \
			libavcodec-dev libavutil-dev libavformat-dev libswscale-dev \
			libavresample-dev libavfilter-dev libavcodec-extra a52dec cmake \
 && $_apt_clean

# Download tvheadend
RUN mkdir /build /out \
 && git clone https://github.com/tvheadend/tvheadend.git /build/tvheadend


