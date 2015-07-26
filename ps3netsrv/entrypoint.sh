#!/bin/sh -x


if [ "$pipework_wait" ]; then
	echo "Waiting for pipework to bring up $pipework_wait..."
	pipework --wait -i $pipework_wait
fi


# Set the uid:gid to run as
[ "$ps3netsrv_uid" ] && usermod  -o -u "$ps3netsrv_uid" ps3netsrv
[ "$ps3netsrv_gid" ] && groupmod -o -g "$ps3netsrv_gid" ps3netsrv


# Copy "$@" special variable into a regular variable
_ps3netsrv_args="$@"


# Start ps3netsrv, should bind to *:38008 automatically
sudo -E su "ps3netsrv" << EOF
	set -x
	/ps3netsrv "$_ps3netsrv_args"
EOF


