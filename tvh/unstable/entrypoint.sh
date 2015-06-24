#!/bin/bash

# Set folder permissions
chown -R hts:video /config /recordings

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
