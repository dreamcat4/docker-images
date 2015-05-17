FROM dreamcat4/tvh.build.ubuntu.deps:14.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

# Version to build
ENV tvh_branch="release/4.0"
ENV repo="ubuntu-stable"


# Update & checkout tvheadend
WORKDIR /build/tvheadend
RUN git pull && git checkout "$tvh_branch"


# Compile tvheadend .deb pkgs
RUN AUTOBUILD_CONFIGURE_EXTRA="--enable-libffmpeg_static --enable-hdhomerun_static --enable-bundle" ./Autobuild.sh -t precise-amd64 \
 && mv /build/*.deb /out && mv /build/*.changes /out


# Upload tvheadend ubuntu .deb pkgs --> bintray.com
WORKDIR /out
RUN pkg_name="tvheadend" && tvh_deb="$(find /out -name 'tvheadend_*.deb')" && tvh_changes="$(find /out -name 'tvheadend_*.changes')" && tvh_dbg_deb="$(find /out -name 'tvheadend-dbg_*.deb')" \
 && tvh_ver="$(echo $tvh_deb | sed -e 's|.*/tvheadend_||' -e 's|~precise.*||')" \
 && for srcfile in $tvh_deb $tvh_changes $tvh_dbg_deb; do \
			distfile=$(echo $srcfile | sed -e "s/precise/trusty/") && mv $srcfile $distfile \
			deb_repo_path="pool/main/t/tvheadend" && chksum="b084fd7f4ac2cd46df13dadfa96ba36f63c9d190" && \
           curl -sS -T $distfile -udreamcat4:$chksum -H X-Bintray-Version:$tvh_ver https://api.bintray.com/content/dreamcat4/${repo}/${pkg_name}/${tvh_ver}/${deb_repo_path}\;deb_distribution=trusty,utopic,vivid\;deb_component=main\;deb_architecture=amd64\;publish=1 ; \
			echo curl -sS -T $distfile -udreamcat4:$chksum -H X-Bintray-Version:$tvh_ver https://api.bintray.com/content/dreamcat4/${repo}/${pkg_name}/${tvh_ver}/${deb_repo_path}\;deb_distribution=trusty,utopic,vivid\;deb_component=main\;deb_architecture=amd64\;publish=1 ; \
  	done


# Build products are copied to the volume '/out'
VOLUME /out





