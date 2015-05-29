FROM dreamcat4/tvh.ubuntu.build.deps
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


# Version to build
ENV tvh_branch="release/4.0"


# Update & checkout tvheadend
WORKDIR /build/tvheadend
RUN git pull && git checkout "$tvh_branch"


# Compile tvheadend .deb pkgs
RUN AUTOBUILD_CONFIGURE_EXTRA="--enable-libffmpeg_static --enable-hdhomerun_static --enable-dvbcsa --enable-bundle" ./Autobuild.sh -w /build/work -t trusty-amd64 \
 && mv /build/*.deb /out && mv /build/*.changes /out && rm -rf /build


# Upload tvheadend ubuntu .deb pkgs --> bintray.com
WORKDIR /out
ADD upload-to-bintray /bin/
RUN chmod +x /bin/upload-to-bintray


# Execute our upload script
ADD bintray-env /out/
RUN upload-to-bintray && rm /out/bintray-env


# Build products are copied to the volume '/out'
VOLUME /out





