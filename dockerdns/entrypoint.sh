#!/bin/sh -x


# Set any optional flags for socat
[ "$_socat_flag" ] || _socat_flags="$@"


# grep ip address of docker internal dns server from container's /etc/resolv.conf
_dockerdns_loopback_ip="$(grep '^nameserver' /etc/resolv.conf  | grep -o '[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*')"


# launch socat, bind to 0.0.0.0, forward all udp requests from port 53 --> docker's dns ip port :53
/usr/bin/socat $_socat_flags udp4-recvfrom:53,reuseaddr,fork udp4-sendto:$_dockerdns_loopback_ip:53 &


# launch socat, bind to 0.0.0.0, forward all tcp requests from port 53 --> docker's dns ip port :53
/usr/bin/socat $_socat_flags tcp4-listen:53,reuseaddr,fork tcp4:$_dockerdns_loopback_ip:53



