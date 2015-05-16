FROM dreamcat4/tvh.build.ubuntu.deps:14.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"


# ENV tvh_branch="master"
ENV tvh_branch="release/4.0"


# Update & checkout tvheadend
WORKDIR /build/tvheadend
RUN git pull && git checkout "$tvh_branch"


# Compile tvheadend .deb pkgs
RUN AUTOBUILD_CONFIGURE_EXTRA="--enable-libffmpeg_static --enable-hdhomerun_static --enable-bundle" ./Autobuild.sh -t precise-amd64
RUN ls -lsa /build \
 && mv /build/*.deb /out


# Upload tvheadend .deb pkgs
WORKDIR /out
RUN ls -lsa /out


