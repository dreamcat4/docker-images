FROM ubuntu:21.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true


# Install docker
RUN apt-get update -qq && apt-get install -qqy \
    lsb-release apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 && apt-get install -qqy docker-ce docker-ce-cli containerd.io && $_apt_clean


# Install pipework
ADD https://github.com/jpetazzo/pipework/archive/master.tar.gz /tmp/pipework-master.tar.gz
RUN tar hzxf /tmp/pipework-master.tar.gz -C /tmp && cp /tmp/pipework-master/pipework /sbin/ && $_clean

# Install networking utils / other dependancies
RUN apt-get update -qq && apt-get install -qqy lsb-release netcat-openbsd curl jq lsof net-tools udhcpc isc-dhcp-client dhcpcd5 arping ndisc6 fping sipcalc bc && $_apt_clean


# # workaround for dhclient error due to ubuntu apparmor profile - http://unix.stackexchange.com/a/155995
# # dhclient: error while loading shared libraries: libc.so.6: cannot open shared object file: Permission denied
# RUN mv /sbin/dhclient /usr/sbin/dhclient


# # Uncomment to hack a local copy of the pipework script
# ADD pipework /sbin/pipework
# RUN chmod +x /sbin/pipework

# Our pipework wrapper script
ADD	entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
