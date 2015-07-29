FROM dreamcat4/tvheadend:unstable
MAINTAINER dreamcat4 <dreamcat4@gmail.com>

# Install debugging dependancies
RUN apt-get update -qq && apt-get install -qqy tvheadend-dbg corekeeper gdb && $_apt_clean

# Debug script
ADD debug.sh /debug.sh
RUN chmod +x /debug.sh

# Stacktrace script
ADD stacktrace /usr/sbin/stacktrace
RUN chmod +x /usr/sbin/stacktrace

# Debugging '/crash' volume to save core dump etc.
VOLUME /crash
ENTRYPOINT ["/init","/debug.sh","-u","hts","-g","hts","-c","/config", \
"--fork","--dump","--logfile","/crash/tvheadend.log"]
