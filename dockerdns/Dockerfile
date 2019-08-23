FROM alpine:latest
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


# Install s6-overlay
ENV s6_overlay_version="1.22.1.0"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar hzxf /tmp/s6-overlay-amd64.tar.gz -C / --exclude=usr/bin/execlineb \
 && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin/execlineb && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# install dnsmasq
RUN apk --update-cache add dnsmasq && rm -rf /var/cache/apk/*


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Default container settings
EXPOSE 53 53/udp
ENTRYPOINT ["/init"]



