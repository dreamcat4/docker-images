#!/bin/bash -x


# Set the uid:gid to run as
[ "$hts_uid" ] && usermod  -o -u "$hts_uid" hts
[ "$hts_gid" ] && groupmod -o -g "$hts_gid" hts


# Set folder permissions
chown -R hts:hts /config
# chown -r /recordings only if owned by root. We asume that means it's a docker volume
[ "$(stat -c %u:%g /recordings)" = "0:0" ] && chown hts:hts /recordings


# Set timezone as specified in /config/etc/timezone
dpkg-reconfigure -f noninteractive tzdata


if [ "$pipework_wait" ]; then
	for _pipework_if in $pipework_wait; do
		echo "Waiting for pipework to bring up $_pipework_if..."
		pipework --wait -i $_pipework_if
	done
	sleep 1
fi


# Clear umask
umask 0


# Copy "$@" special variable into a regular variable
_tvheadend_args="$@"


# Start tvheadend
/usr/bin/tvheadend $_tvheadend_args



