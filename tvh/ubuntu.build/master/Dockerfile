FROM dreamcat4/tvh.ubuntu.build.deps
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

# Version to build
ENV tvh_branch="trusty-build-target"

# Bintray settings
ENV bintray_user="dreamcat4"
ENV bintray_key="995af15f51d0e2910b73af4ebeb2cbdf604b3a10"
ENV bintray_repo="ubuntu"
ENV bintray_pkg_name="tvheadend"
ENV deb_dist="master"
ENV deb_component="main"

# # releases (git-tagged series eg `4.0.0`,`4.0.1`,`4.0.2`)
# tvheadend/stable 4.0.1~trusty amd64
# tvheadend/unstable 4.1.3~trusty amd64

# # nightlies (commits of the two branches)
# tvheadend/master 4.1.0-18~gd149c5b~trusty amd64
# tvheadend/testing 4.1.0-18~gd149c5b~trusty amd64


RUN cd /build && rm -rf tvheadend && git clone https://github.com/dreamcat4/tvheadend.git

# Update & checkout tvheadend
WORKDIR /build/tvheadend
RUN git pull && git checkout "$tvh_branch"

# Compile tvheadend .deb pkgs
RUN AUTOBUILD_CONFIGURE_EXTRA="--enable-libffmpeg_static --enable-hdhomerun_static --enable-dvbcsa --enable-bundle" ./Autobuild.sh -w /build/work -t trusty-amd64 \
 && mv /build/*.deb /out && mv /build/*.changes /out && rm -rf /build


# Upload tvheadend ubuntu .deb pkgs --> bintray.com
WORKDIR /out
ADD bintray-version-descr /out/
ADD upload-to-bintray /bin/
RUN chmod +x /bin/upload-to-bintray


# Build products are copied to the volume '/out'
VOLUME /out





