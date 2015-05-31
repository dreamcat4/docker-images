FROM dreamcat4/tvh.ubuntu.build.deps
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


# Update & checkout tvheadend
WORKDIR /build/tvheadend
RUN git pull \
 && tvh_last_tag="$(git tag | grep v[456789].[13579] | sort | tail -1)" \
 && if [ "$tvh_last_tag" ]; then git checkout "$tvh_last_tag" ; \
		else echo "error: no git tag for v${tvh_major_ver}.x unstable" && false ; fi


# Compile tvheadend .deb pkgs
RUN if [ -e "Autobuild/trusty-amd64.sh" ]; then target=trusty; else target=precise; fi \
 && AUTOBUILD_CONFIGURE_EXTRA="--enable-libffmpeg_static --enable-hdhomerun_static --enable-dvbcsa --enable-bundle" ./Autobuild.sh -w /build/work -t ${target}-amd64 \
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


