#!/bin/bash -x


# Set the uid:gid to run as
[ "$(id -u sonarr)" -eq "$sonarr_uid" ] || usermod  -o -u "$sonarr_uid" sonarr
[ "$(id -g sonarr)" -eq "$sonarr_gid" ] || groupmod -o -g "$sonarr_gid" sonarr


# Set folder permissions
chown -R sonarr:sonarr /opt/NzbDrone /config

# chown -r the /media folder only if owned by root. We asume that means it's a docker volume
[ "$(stat -c %u /media):$(stat -c %g /media)" -eq "0:0" ] && chown -R sonarr:sonarr /media


# Disable the logfile on disk (because we have docker logs instead)
_sonarr_logfile="/config/logs/nzbdrone.txt"
mkdir -p "/config/logs"
ln -sf /dev/null $_sonarr_logfile


# Make sure the .pid file doesn't exist
_sonarr_pid_file="/config/nzbdrone.pid"
rm -f "$_sonarr_pid_file"


# Start the sonarr daemon. web UI should bind to * automatically
sudo -E su "sonarr" << EOF
	set -x
	mono /opt/NzbDrone/NzbDrone.exe -data=/config
EOF




