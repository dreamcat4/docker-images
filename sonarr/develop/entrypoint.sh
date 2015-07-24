#!/bin/bash -x


# Disable the logfile on disk (because we have docker logs instead)
_sonarr_logfile="/config/logs/nzbdrone.txt"
mkdir -p "/config/logs"
ln -sf /dev/null $_sonarr_logfile


# Set folder permissions
chown -R sonarr:sonarr /opt/NzbDrone /config /torrents /downloads /media /tv


# Make sure the .pid file doesn't exist
_sonarr_pid_file="/config/nzbdrone.pid"
rm -f "$_sonarr_pid_file"


# Start the sonarr daemon. web UI should bind to * automatically
sudo -E su "sonarr" << EOF
	set -x
	mono /opt/NzbDrone/NzbDrone.exe -data=/config
EOF




