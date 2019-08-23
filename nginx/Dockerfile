FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"


# Install s6-overlay
ENV s6_overlay_version="1.22.1.0"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar hzxf /tmp/s6-overlay-amd64.tar.gz -C / --exclude=usr/bin/execlineb \
 && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin/execlineb && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar hzxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean


# Install gnupg2
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qqy iproute2 net-tools gnupg2 && $_apt_clean


# Install nginx
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 \
 && echo "deb http://nginx.org/packages/mainline/ubuntu xenial nginx" >> /etc/apt/sources.list \
 && apt-get update && apt-get install -y ca-certificates nginx && $_apt_clean


# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log


# Setup nginx user
RUN groupmod -o -g 8080 nginx \
 && usermod -o -u 8080 -g nginx --shell /bin/sh -d /www nginx \
 && install -o nginx -g nginx -d /www /ssl


# Copy config files
COPY nginx.conf /etc/nginx/nginx.conf
COPY mime.types /etc/nginx/mime.types
COPY default /etc/nginx/sites-enabled/default
COPY default-ssl /etc/nginx/sites-available/default-ssl


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Default container settings
VOLUME /www
EXPOSE 80 443
ENTRYPOINT ["/init"]


