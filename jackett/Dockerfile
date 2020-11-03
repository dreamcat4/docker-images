FROM ubuntu:20.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1


# Install s6-overlay
ARG s6_overlay_version="1.22.1.0"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar hzxf /tmp/s6-overlay-amd64.tar.gz -C / --exclude=usr/bin/execlineb \
 && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin/execlineb && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar hzxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean


# Install jackett dependancies
RUN apt-get update -qq && apt-get install -qqy \
 lsb-release apt-transport-https ca-certificates gnupg software-properties-common curl bzip2 sudo \
 && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - \
 && apt-add-repository -y https://packages.microsoft.com/ubuntu/20.04/prod \
 && apt-get install -qqy dotnet-sdk-3.1 \
 && $_apt_clean


# Download jackett
# ENV jackett_version="0.7.504"
ENV jackett_version="0.16.2010"
 RUN curl -Lo /tmp/jackett.tar.gz https://github.com/Jackett/Jackett/releases/download/v${jackett_version}/Jackett.Binaries.LinuxAMDx64.tar.gz \
  && mkdir /jackett && tar -xzf /tmp/jackett.tar.gz --strip-components=1 -C /jackett && rm -f /tmp/jackett.tar.gz


# Setup sonarr /config dir and /media folder
RUN groupadd -o -g 9117 jackett \
 && useradd -o -u 9117 -N -g jackett --shell /bin/sh -d /config jackett \
 && install -o jackett -g jackett -d /config /media


# Global config
ADD config /config/


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Launch script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Default container settings
VOLUME /config
EXPOSE 9117 9118
ENTRYPOINT ["/init"]




