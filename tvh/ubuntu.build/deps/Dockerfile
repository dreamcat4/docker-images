FROM ubuntu:21.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG DEBIAN_FRONTEND=noninteractive

# Install all known build dependancies for tvheadend
# 
# This is just to have them available and baked into the builder base image,
# regardless whether or not you actually enable a specific feature for your specific build.
# Dependancies are grouped into categories for easier checking and for future updating.
# 


# These packages are the default build deps for tvheadend on 20.04 focal
# as were listed in the "focal-amd64" section of the .doozer.json file in master branch
RUN apt-get update -qq && apt-get install -qqy \
    cmake git build-essential pkg-config gettext libavahi-client-dev libssl-dev zlib1g-dev wget bzip2 git-core liburiparser-dev libpcre2-dev libdvbcsa-dev python3 python3-requests debhelper ccache \
 && $_apt_clean


# Other important or useful deps that were not included in the default doozer.json
RUN apt-get update -qq && apt-get install -qqy \
    lsb-release asciidoc curl libcurl4-gnutls-dev dvb-apps libsystemd-dev libc6-dev libtool-bin libpcre3-dev libprotobuf-dev libkqueue-dev libhdhomerun-dev nasm xmlto \
 && $_apt_clean


# Extra dependancies for libav
RUN apt-get update -qq && apt-get install -qqy \
    libavcodec-dev libavutil-dev libavformat-dev libswscale-dev libavresample-dev libavfilter-dev libavcodec-extra \
 && $_apt_clean


# Extra deps for GPU acceleration, if you have a gpu that can take advantage of these
RUN apt-get update -qq && apt-get install -qqy \
    libva-dev libva-drm2 libva-glx2 libva-wayland2 libva-x11-2 i965-va-driver-shaders \
 && $_apt_clean


# Extra deps for better debugging or profiling
RUN apt-get update -qq && apt-get install -qqy \
    libgoogle-perftools-dev libtcmalloc-minimal4 \
 && $_apt_clean


# Download tvheadend
RUN mkdir /build /out && git clone https://github.com/tvheadend/tvheadend.git /build/tvheadend


