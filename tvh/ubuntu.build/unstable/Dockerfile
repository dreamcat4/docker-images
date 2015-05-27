FROM dreamcat4/tvh.ubuntu.build.deps
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

# Version to build
ENV tvh_branch="master"

# Bintray settings
ENV bintray_user="dreamcat4"
ENV bintray_key="995af15f51d0e2910b73af4ebeb2cbdf604b3a10"
ENV bintray_repo="ubuntu"
ENV bintray_pkg_name="tvheadend"


# Update & checkout tvheadend
WORKDIR /build/tvheadend
RUN git pull && git checkout "$tvh_branch"


# Compile tvheadend .deb pkgs
RUN AUTOBUILD_CONFIGURE_EXTRA="--enable-libffmpeg_static --enable-hdhomerun_static --enable-dvbcsa --enable-bundle" ./Autobuild.sh -w /build/work -t trusty-amd64 \
 && mv /build/*.deb /out && mv /build/*.changes /out && rm -rf /build


# Upload tvheadend ubuntu .deb pkgs --> bintray.com
WORKDIR /out
ADD bintray-version-descr /out/
RUN tvh_deb="$(find /out -name 'tvheadend_*.deb')" && tvh_changes="$(find /out -name 'tvheadend_*.changes')" && tvh_dbg_deb="$(find /out -name 'tvheadend-dbg_*.deb')" \
 && tvh_ver="$(echo $tvh_deb | sed -e 's|.*/tvheadend_||' -e 's|~precise.*||')" \
 && curl -sS -u${bintray_user}:${bintray_key} -H "Content-Type: application/json" -X POST https://api.bintray.com/packages/${bintray_user}/${bintray_repo}/${bintray_pkg_name}/versions --data "{ \"name\": \"${tvh_ver}\", \"desc\": \"$(cat /out/bintray-version-descr)\", }" \
 && for srcfile in $tvh_deb $tvh_changes $tvh_dbg_deb; do \
			distfile=$(echo $srcfile | sed -e "s/precise/trusty/") && mv $srcfile $distfile && deb_repo_path="pool/main/t/tvheadend/$(basename ${distfile})" && \
      curl -sS -T $distfile -u${bintray_user}:${bintray_key} -H X-Bintray-Version:$tvh_ver https://api.bintray.com/content/${bintray_user}/${bintray_repo}/${bintray_pkg_name}/${tvh_ver}/${deb_repo_path}\;deb_distribution=trusty,utopic,vivid\;deb_component=main\;deb_architecture=amd64\;publish=1 ; \
  	done


# Build products are copied to the volume '/out'
VOLUME /out





