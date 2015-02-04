#!/bin/sh

sleep 1 # make sure that fig has enough time to attach a tty before the script exits
#set -e  # stop when any command returns non-zero exit code
#set -x # enable debugging output

export DOCKER_HOST=${DOCKER_HOST:-"unix:///docker.sock"}
_test_docker ()
{
	# Test for docker socket and client
	if ! docker -D info > /docker_info; then
        echo "error: can't connect to $DOCKER_HOST"
		exit 1
	fi
}
_test_docker;


# ---------------------------------------------------------------------------------
# Taken from https://github.com/jpetazzo/dind/blob/master/wrapdocker
# Configure our container's environment to look more like the host environment
# in regards to /proc cgroups etc.
# ---------------------------------------------------------------------------------

# First, make sure that cgroups are mounted correctly.
CGROUP=/sys/fs/cgroup
: {LOG:=stdio}

[ -d $CGROUP ] || 
	mkdir $CGROUP

mountpoint -q $CGROUP || 
	mount -n -t tmpfs -o uid=0,gid=0,mode=0755 cgroup $CGROUP || {
		echo "Could not make a tmpfs mount. Did you use -privileged?"
		exit 1
	}

if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security
then
    mount -t securityfs none /sys/kernel/security || {
        echo "Could not mount /sys/kernel/security."
        echo "AppArmor detection and -privileged mode might break."
    }
fi

# Mount the cgroup hierarchies exactly as they are in the parent system.
for SUBSYS in $(cut -d: -f2 /proc/1/cgroup)
do
        [ -d $CGROUP/$SUBSYS ] || mkdir $CGROUP/$SUBSYS
        mountpoint -q $CGROUP/$SUBSYS || 
                mount -n -t cgroup -o $SUBSYS cgroup $CGROUP/$SUBSYS

        # The two following sections address a bug which manifests itself
        # by a cryptic "lxc-start: no ns_cgroup option specified" when
        # trying to start containers withina container.
        # The bug seems to appear when the cgroup hierarchies are not
        # mounted on the exact same directories in the host, and in the
        # container.

        # Named, control-less cgroups are mounted with "-o name=foo"
        # (and appear as such under /proc/<pid>/cgroup) but are usually
        # mounted on a directory named "foo" (without the "name=" prefix).
        # Systemd and OpenRC (and possibly others) both create such a
        # cgroup. To avoid the aforementioned bug, we symlink "foo" to
        # "name=foo". This shouldn't have any adverse effect.
        echo $SUBSYS | grep -q ^name= && {
                NAME=$(echo $SUBSYS | sed s/^name=//)
                ln -s $SUBSYS $CGROUP/$NAME
        }

        # Likewise, on at least one system, it has been reported that
        # systemd would mount the CPU and CPU accounting controllers
        # (respectively "cpu" and "cpuacct") with "-o cpuacct,cpu"
        # but on a directory called "cpu,cpuacct" (note the inversion
        # in the order of the groups). This tries to work around it.
        [ $SUBSYS = cpuacct,cpu ] && ln -s $SUBSYS $CGROUP/cpu,cpuacct
done

# Note: as I write those lines, the LXC userland tools cannot setup
# a "sub-container" properly if the "devices" cgroup is not in its
# own hierarchy. Let's detect this and issue a warning.
grep -q :devices: /proc/1/cgroup ||
	echo "WARNING: the 'devices' cgroup should be in its own hierarchy."
grep -qw devices /proc/1/cgroup ||
	echo "WARNING: it looks like the 'devices' cgroup is not mounted."
# ---------------------------------------------------------------------------------


# Resolve @HOSTNAME@, @CONTAINER_NAME@, and @CONTAINER_ID templates
pipework_cmds="$(env | grep pipework_cmd= | sed -e 's/.*pipework_cmd=//g' | sort | uniq)"
if [ "$pipework_cmds" ]; then
    pipework_cmds_needs_find_name="$(echo "$pipework_cmds" | grep '@CONTAINER_NAME@\|@HOSTNAME@\|@CONTAINER_ID@' || true)"
    pipework_cmds="$(echo "$pipework_cmds" | grep -v '@CONTAINER_NAME@\|@HOSTNAME@\|@CONTAINER_ID@' || true)"

    if [ "$pipework_cmds_needs_find_name" ]; then
        while read pc; do
            sn_env="$(env | grep "$pc" | awk '{print length($0) " " $0;}' | sort -r -n | cut -d ' ' -f2- | tail -1 | sed -e 's/_ENV_.*pipework_cmd=.*//g')_NAME"
            name="$(eval "echo \$$sn_env")"

            if [ "$(echo "$pc" | grep '@HOSTNAME@')" ]; then
                hostname="$(docker inspect -f '{{.Config.Hostname}}' "$name")"
                pc="$(echo "$pc" | sed -e "s|@HOSTNAME@|$hostname|g")"
            fi

            if [ "$(echo "$pc" | grep '@CONTAINER_NAME@')" ]; then
                pc="$(echo "$pc" | sed -e "s|@CONTAINER_NAME@|$name|g")"
            fi

            if [ "$(echo "$pc" | grep '@CONTAINER_ID@')" ]; then
                container_id="$(docker inspect -f '{{.Id}}' "$name" | cut -c1-12)"
                pc="$(echo "$pc" | sed -e "s|@CONTAINER_ID@|$container_id|g")"
            fi
            pipework_cmds="$pipework_cmds
$pc"
        done <<- EOF
$pipework_cmds_needs_find_name
EOF
    fi
    pipework_cmds="$(echo "$pipework_cmds" | sed /^$/d)"

    # Run each .*pipework_cmd= env variable
	while read pc; do
		sh -x /sbin/pipework ${pc#pipework }
	done <<- EOF
$pipework_cmds
EOF

else
    # Run pipework from the command line
    sh -x /sbin/pipework "$@"
fi

