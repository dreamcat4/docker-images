FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"

# Install gnupg2
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qqy gnupg2 && $_apt_clean

# Install docker
RUN apt-get update -qq && apt-get install -qqy apt-transport-https \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys F76221572C52609D \
 && echo deb https://apt.dockerproject.org/repo ubuntu-wily main > /etc/apt/sources.list.d/docker.list \
 && apt-get update -qq && apt-get install -qqy docker-engine && $_apt_clean

# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar hzxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean

# Install networking utils / other dependancies
RUN apt-get update -qq && apt-get install -qqy netcat-openbsd curl jq lsof net-tools udhcpc isc-dhcp-client dhcpcd5 arping ndisc6 fping sipcalc bc && $_apt_clean

# workaround for dhclient error due to ubuntu apparmor profile - http://unix.stackexchange.com/a/155995
# dhclient: error while loading shared libraries: libc.so.6: cannot open shared object file: Permission denied
RUN mv /sbin/dhclient /usr/sbin/dhclient

# # Uncomment to hack a local copy of the pipework script
# ADD pipework /sbin/pipework
# RUN chmod +x /sbin/pipework

# Our pipework wrapper script
ADD	entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
