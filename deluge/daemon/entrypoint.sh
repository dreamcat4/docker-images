#!/bin/bash -x

_deluged_pid_file="/config/deluged.pid"

_cleanup ()
{
    [ "$_socat_pid" ] && kill $_socat_pid
    [ -e "$_deluged_pid_file" ] && rm -f $_deluged_pid_file
}
trap _cleanup TERM INT QUIT HUP


# Set folder permissions
chown -R debian-deluged:debian-deluged /config
chown    debian-deluged:debian-deluged /torrents /downloads


# Set timezone as specified in /config/etc/timezone
dpkg-reconfigure -f noninteractive tzdata


if [ "$pipework_wait" ]; then
	for _pipework_if in $pipework_wait; do
		echo "Waiting for pipework to bring up $_pipework_if..."
		pipework --wait -i $_pipework_if
	done
	sleep 1
fi


if [ "$deluge_wan_interface" ]; then
	_wan_ip="$(ip -4 -o address show "$deluge_wan_interface" | tr -s ' ' | cut -d' ' -f4 | sed -e 's|/.*||g')"
	[ "$_wan_ip" ] || exit 1
	_wan_if_flag="--interface=$_wan_ip"
fi


if [ "$deluge_lan_interface" ]; then
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


# Copy "$@" special variable into a regular variable
_deluged_args="$@"


# Start the deluge daemon. web UI should start automatically based on the default config
sudo -E su "debian-deluged" << EOF
	set -x
	deluged --do-not-daemonize $_wan_if_flag $_deluged_args
EOF


_cleanup;

