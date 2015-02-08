FROM 		ubuntu:trusty
MAINTAINER 	dreamcat4 <dreamcat4@gmail.com>

RUN apt-get update -qq && apt-get install -y apt-transport-https

# Install
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 \
&&  echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list \
&&  apt-get update -qq \
&&  apt-get install -y lxc-docker

RUN apt-get install -y wget zip arping ndisc6 fping sipcalc bc

# workaround for ubuntu apparmor profile - http://unix.stackexchange.com/a/155995
# dhclient: error while loading shared libraries: libc.so.6: cannot open shared object file: Permission denied
RUN mv /sbin/dhclient /usr/sbin/dhclient

RUN wget https://github.com/jpetazzo/pipework/archive/master.zip && \
			unzip master.zip && cp /pipework-master/pipework /sbin/ && rm master.zip

# # Uncomment to hack a local copy of the pipework script
# ADD pipework /sbin/pipework
# RUN chmod +x /sbin/pipework

ADD	entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT 	["/entrypoint.sh"]
CMD 		["--help"]

