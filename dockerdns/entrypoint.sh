#!/bin/sh -x


# Set any optional flags for socat
[ "$_dnsmasq_flags" ] || _dnsmasq_flags="$@"


# grep ip address of docker internal dns server from container's /etc/resolv.conf
_dockerdns_loopback_ip="$(grep '^nameserver' /etc/resolv.conf  | grep -o '[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*')"


# create dnsmasq.conf
echo "user=root" >> /etc/dnsmasq.conf
echo "server=$_dockerdns_loopback_ip" >> /etc/dnsmasq.conf


# start dnsmasq
/usr/sbin/dnsmasq --no-daemon --conf-file=/etc/dnsmasq.conf $_dnsmasq_flags


# temp dont exit on failure
sleep 999999


