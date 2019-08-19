FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"

# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar hzxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean

# Install sudo
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qqy sudo && $_apt_clean

# Install ps3netsrv
ADD https://github.com/dreamcat4/ps3netsrv/raw/master/release/linux/ps3netsrv-x86_64 /ps3netsrv
RUN chmod +x /ps3netsrv

# Setup ps3netsrv user
RUN groupadd -o -g 38008 ps3netsrv \
 && useradd -o -c "ps3netsrv" -u 38008 -N -g ps3netsrv --shell /bin/sh ps3netsrv

# Launch script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default container settingsEXPOSE 38008
EXPOSE 38008
VOLUME ["/games"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/games"]

