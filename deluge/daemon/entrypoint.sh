#!/bin/bash -x

_deluged_pid_file="/config/deluged.pid"

_cleanup ()
{
    [ "$_socat_pid" ] && kill $_socat_pid
    [ -e "$_deluged_pid_file" ] && rm -f $_deluged_pid_file
}
trap _cleanup TERM INT QUIT HUP


# Set the uid:gid to run as
[ "$deluge_uid" ] && usermod  -o -u "$deluge_uid" deluge
[ "$deluge_gid" ] && groupmod -o -g "$deluge_gid" deluge


# Set folder permissions
chown -R deluge:deluge /config

# chown -r /downloads & /torrents only if owned by root. We asume that means it's a docker volume
[ "$(stat -c %u:%g /torrents )" = "0:0" ] && chown deluge:deluge /torrents
[ "$(stat -c %u:%g /downloads)" = "0:0" ] && chown deluge:deluge /downloads


ENV TIMEZONE="Europe/London"

echo "${TIMEZONE}" > /config/.link/etc/timezone \
 && ln -sf /usr/share/zoneinfo/${TIMEZONE} /config/.link/etc/localtime \
 && ln -sf /config/.link/etc/timezone /etc/timezone \
 && ln -sf /config/.link/etc/localtime /etc/localtime \

if [ "$TIMEZONE" ]; then
	mkdir -p /config/.link/etc
	echo "${TIMEZONE}" > /config/.link/etc/timezone
  ln -sf /config/.link/etc/timezone /etc/timezone
	ln -sf /usr/share/zoneinfo/${TIMEZONE} /config/.link/etc/localtime
  ln -sf /config/.link/etc/localtime /etc/localtime
fi

# Set timezone as specified in /config/.link/etc/timezone
dpkg-reconfigure -f noninteractive tzdata


# set the default route
if [ "$default_route" ]; then
  route del default
  route add default gw $default_route
fi



if [ "$deluge_wan_ip" ]; then
  _wan_if_flag="--interface=$deluge_wan_ip"

elif [ "$deluge_wan_interface" ]; then
	_wan_ip="$(ip -4 -o address show "$deluge_wan_interface" | tr -s ' ' | cut -d' ' -f4 | sed -e 's|/.*||g')"
	[ "$_wan_ip" ] || exit 1
	_wan_if_flag="--interface=$_wan_ip"
fi


if [ "$deluge_lan_ip" ]; then
  _lan_ip="$deluge_lan_ip"

elif [ "$deluge_lan_interface" ]; then
	_lan_ip="$(ip -4 -o address show "$deluge_lan_interface" | tr -s ' ' | cut -d' ' -f4 | sed -e 's|/.*||g')"

else
	_lan_gateway_ip="$(ip route | grep default | cut -d' ' -f3)"
	_lan_ip="$(ip route get "$_lan_gateway_ip" | grep "$_lan_gateway_ip" | tr -s ' ' | cut -d' ' -f5)"
fi


# Make sure the .pid file doesn't exist
rm -f "$_deluged_pid_file"


# Make sure we know the deluge daemon port number
[ "$deluge_daemon_port" ] || deluge_daemon_port="58846"


if [ "$_lan_ip" ]; then
	# forward deluge daemon localhost ---> lan interface
	socat tcp4-listen:${deluge_daemon_port},bind=$_lan_ip,fork tcp:localhost:${deluge_daemon_port} &
	_socat_pid=$!

else
	echo "entrypoint.sh: error: _lan_ip could not be determined"
	echo "warning: deluge daemon will not be accessible except on the container's localhost interface"
fi


# Ensure $HOSTNAME can be pinged otherwise WAN networking will not work
ping -q -c1 $(hostname) > /dev/null 2>&1 || echo "$_lan_ip $(hostname)" >> /etc/hosts


# Copy "$@" special variable into a regular variable
_deluged_args="$@"


# Start the deluge daemon. web UI should start automatically based on the default config
sudo -E su "deluge" << EOF
	set -x
	deluged --do-not-daemonize $_wan_if_flag $_deluged_args
EOF


_cleanup;

