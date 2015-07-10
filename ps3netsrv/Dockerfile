FROM ubuntu-debootstrap:14.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"

# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar -zxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean

# Launch script
ADD entrypoint.sh /entrypoint.sh

# Install ps3netsrv
ADD https://github.com/dreamcat4/ps3netsrv/raw/master/release/linux/ps3netsrv-x86_64 /ps3netsrv

# Fix permissions
RUN chmod +x /ps3netsrv \
 && chmod +x /entrypoint.sh

# Default container settingsEXPOSE 38008
EXPOSE 38008
VOLUME ["/games"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/games"]
