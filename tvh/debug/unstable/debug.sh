#!/bin/bash

# This script will take a coredump & immediate gdb backtrace upon segfault
# While tvheadend is running will log --debug all --trace all

# Tvheadend Debugging Guide
# https://tvheadend.org/projects/tvheadend/wiki/Debugging

_cleanup ()
{
	if [ "$core_pattern_orig" ]; then
		# Restore core path
		echo "$core_pattern_orig" > /proc/sys/kernel/core_pattern
	fi

	# Restore original file ownership and permissions
	chown -R ${crash_uid}:${crash_gid} /crash && chmod ${crash_rwx} /crash

  exit 0
}
trap _cleanup TERM INT QUIT HUP

# Remember the folder ownership for later
crash_uid="$(stat -c %u /crash)"
crash_gid="$(stat -c %g /crash)"
crash_rwx="$(stat -c %a /crash)"

# Set the uid:gid to run as
[ "$hts_uid" ]   && usermod  -o -u "$hts_uid"   hts
[ "$hts_gid" ]   && groupmod -o -u "$hts_gid"   hts
[ "$video_gid" ] && groupmod -o -g "$video_gid" video

# Set folder permissions
chown -R hts:video /config; chown -R --from=:44 :video /dev
chown hts:video /crash && chmod u+rwx /crash

# chown -r /recordings only if owned by root. We asume that means it's a docker volume
[ "$(stat -c %u:%g /recordings)" -eq "0:0" ] && chown hts:video /recordings

# Set timezone as specified in /config/etc/timezone
dpkg-reconfigure -f noninteractive tzdata

if [ "$pipework_wait" ]; then
	echo "Waiting for pipework to bring up $pipework_wait..."
	pipework --wait -i $pipework_wait
fi

# Enable core dumps
ulimit -c unlimited
echo "Set: ulimit -c unlimited"

tvh_version="$(tvheadend --version | cut -d' ' -f 3)"

# Override core path
core_pattern_orig=$(cat /proc/sys/kernel/core_pattern)
core_pattern="/crash/%e-${tvh_version}.t%t.core.new"
echo "$core_pattern" > /proc/sys/kernel/core_pattern

# Make sure our core files get saved as '/crash/core*'
if [ "$?" -ne "0" ]; then
	echo "error: can't modify /proc/sys/kernel/core_pattern
Did you run this image with --privileged=true flag?"
fi

if [ "$(cat /proc/sys/kernel/core_pattern | grep -v -e '^/crash/.*.core.new')" ]; then
	echo "error: the save path of core files is not /crash/.*.core.new
Aborting."
	exit 1
fi
echo "Set: core_pattern=/crash/%e-${tvh_version}.t%t.core.new"

# Uname
echo "uname -a:"
uname -a

# Dmesg
dmesg > /crash/tvheadend-${tvh_version}.dmesg.new
echo "Saved: dmesg --> /crash/dmesg.new"

# Clear umask
umask 0

# Start tvheadend
echo /usr/bin/tvheadend "$@"
     /usr/bin/tvheadend "$@"

# Echo full trace to stdout
tvh_pid="$(ps -o pid= -C tvheadend | head -1 | tr -d ' ')"
[ "${tvh_pid}" ] || exit 1
tail -n 99999 -F --pid=$tvh_pid /crash/tvheadend.log

# Restore core path
echo "$core_pattern_orig" > /proc/sys/kernel/core_pattern

# Exit cleanly if there was no segfault crash
core_file_new="$(find /crash -name '*core.new*' | tail -n 1)"

if [ ! "$core_file_new" ]; then
	# Rename log file
	uname -a > "/crash/tvheadend-${tvh_version}.log"
	echo /usr/bin/tvheadend "$@"   >> "/crash/tvheadend-${tvh_version}.log"
	tvheadend --version            >> "/crash/tvheadend-${tvh_version}.log"
	cat "/crash/tvheadend.log"     >> "/crash/tvheadend-${tvh_version}.log"
	rm "/crash/tvheadend.log"

	# Restore original file ownership and permissions
	chown -R ${crash_uid}:${crash_gid} /crash && chmod ${crash_rwx} /crash
	exit 0
fi

# Rename files so they don't conflict with other sessions
file_prefix="${core_file_new%.core.new.*}"
core_file="${file_prefix}.core"
mv "$core_file_new" "$core_file"
mv "/crash/tvheadend-${tvh_version}.dmesg.new" "${file_prefix}.dmesg"

# Rename log file
uname -a > "${file_prefix}.log"
echo /usr/bin/tvheadend "$@"   >> "${file_prefix}.log"
tvheadend --version            >> "${file_prefix}.log"
cat "/crash/tvheadend.log"     >> "${file_prefix}.log"
rm "/crash/tvheadend.log"

echo "
***********************************************************************
GDB Backtrace
***********************************************************************
"
echo "set logging on ${file_prefix}.gdb.txt
set pagination off
bt full" | gdb /usr/bin/tvheadend "$core_file"
echo "
***********************************************************************

 Tvheadend Debugging Guide
 ----> https://tvheadend.org/projects/tvheadend/wiki/Debugging

 Tvheadend Issue Tracker
 ----> https://tvheadend.org/projects/tvheadend/issues

 Tvheadend New Issue
 ----> https://tvheadend.org/projects/tvheadend/issues/new
"

# Restore original file ownership and permissions
chown -R ${crash_uid}:${crash_gid} /crash && chmod ${crash_rwx} /crash
