#!/bin/bash


# Set the uid:gid to run as
[ "$hts_uid" ]   && usermod  -o -u "$hts_uid"   hts
[ "$video_gid" ] && groupmod -o -g "$video_gid" video


# Set folder permissions
chown -R hts:video /config; chown -R --from=:44 :video /dev

# chown -r /recordings only if owned by root. We asume that means it's a docker volume
[ "$(stat -c %u:%g /recordings)" -eq "0:0" ] && chown hts:video /recordings


# Set timezone as specified in /config/etc/timezone
dpkg-reconfigure -f noninteractive tzdata


if [ "$pipework_wait" ]; then
	echo "Waiting for pipework to bring up $pipework_wait..."
	pipework --wait -i $pipework_wait
fi


# Clear umask
umask 0


echo /usr/bin/tvheadend "$@"
     /usr/bin/tvheadend "$@"



