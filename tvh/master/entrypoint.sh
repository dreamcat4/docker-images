#!/bin/bash -x


# Set the uid:gid to run as
[ "$hts_uid" ] && usermod  -o -u "$hts_uid" hts
[ "$hts_gid" ] && groupmod -o -g "$hts_gid" hts


# Set folder permissions
chown -R hts:hts /config
# chown -r /recordings only if owned by root. We asume that means it's a docker volume
[ "$(stat -c %u:%g /recordings)" -eq "0:0" ] && chown hts:hts /recordings


# Set timezone as specified in /config/etc/timezone
dpkg-reconfigure -f noninteractive tzdata


if [ "$pipework_wait" ]; then
	echo "Waiting for pipework to bring up $pipework_wait..."
	pipework --wait -i $pipework_wait
fi


# Clear umask
umask 0


# Copy "$@" special variable into a regular variable
_tvheadend_args="$@"


# Start tvheadend
/usr/bin/tvheadend $_tvheadend_args



