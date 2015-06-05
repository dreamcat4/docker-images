#!/bin/bash

_pipework_image_name="dreamcat4/pipework"
_global_vars="run_mode host_routes host_route_arping up_time key cmd sleep debug event_filters"

for _var in $_global_vars; do
    _value="$(eval echo \$${_var})"
    [ "$_value" ] || _value="$(eval echo \$pipework_${_var})"
    eval "_pipework_${_var}=\"${_value}\""
done

[ "$_pipework_debug" ] && _debug="sh -x"
[ "$_pipework_sleep" ] && sleep $_pipework_sleep

_pipework="$_debug /sbin/pipework"
_args="$@"

export DOCKER_HOST=${DOCKER_HOST:-"unix:///docker.sock"}
_test_docker ()
{
	# Test for docker socket and client
	if ! docker -D info > /docker_info; then
        echo "error: can't connect to $DOCKER_HOST"
		exit 1
	fi
}

_cleanup ()
{
    [ "$_while_read_pid" ]     && kill  $_while_read_pid
    [ "$_docker_events_pid" ]  && kill  $_docker_events_pid
    [ "$_docker_events_log" ]  && rm -f $_docker_events_log
    exit 0
}
trap _cleanup TERM INT QUIT HUP

_setup_container_for_host_access ()
{
    # ---------------------------------------------------------------------------------
    # Taken from https://github.com/jpetazzo/dind/blob/master/wrapdocker
    # Configure our container's environment to look more like the host environment
    # for /proc,cgroups,etc. Apache 2.0 License, Credit @ github.com/jpetazzo/dind
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
}

_expand_macros ()
{
    for _macro in $_macros; do
        case $_macro in

            @CONTAINER_NAME@)
            name="$(docker inspect -f {{.Name}} ${c12id})"
            _pipework_vars="$(echo "$_pipework_vars" | sed -e "s|@CONTAINER_NAME@|${name#/}|g")"
            ;;

            @CONTAINER_ID@)
            _pipework_vars="$(echo "$_pipework_vars" | sed -e "s|@CONTAINER_ID@|$c12id|g")"
            ;;

            @HOSTNAME@)
            hostname="$(docker inspect -f '{{.Config.Hostname}}' "$c12id")"
            _pipework_vars="$(echo "$_pipework_vars" | sed -e "s|@HOSTNAME@|$hostname|g")"
            ;;

            @INSTANCE@)
            instance="$(docker inspect -f {{.Name}} ${c12id} | grep -o -e '[0-9]*' | tail -1)"
            _pipework_vars="$(echo "$_pipework_vars" | sed -e "s|@INSTANCE@|${instance}|g")"
            ;;
        esac
    done
}

_docker_pid ()
{
    exec docker inspect --format '{{ .State.Pid }}' "$@"
}

_decrement_ipv4 ()
{
    ipv4_address_spaced="$(echo "$1" | tr . ' ')"
    ipv4_address_hex="$(printf "%02x%02x%02x%02x\n" $ipv4_address_spaced)"
    ipv4_address_uint32="$(printf "%u\n" 0x${ipv4_address_hex})"
    ipv4_address="$(printf "obase=256\n$(expr $ipv4_address_uint32 - 1)\n" | bc | tr ' ' . | cut -c2- | sed -e 's/255/254/g')"
    [ "$ipv4_address" != "${ipv4_address%.0*}" ] && _decrement_ipv4 "$ipv4_address"
    printf "$ipv4_address\n"
}

_decrement_ipv6 ()
{
    ipv6_address_hex="$(echo "$1" | tr -d '\t :' | tr '[:lower:]' '[:upper:]')"

    # echo "echo \"obase=16;ibase=16; $ipv6_address_hex - 1;\" | bc"
    # echo "obase=16;ibase=16; $ipv6_address_hex - 1;" | bc

    ipv6_address_hex="$(echo "obase=16;ibase=16; $ipv6_address_hex - 1;" | bc)"
    padding="$(expr 32 - $(echo -n "$ipv6_address_hex" | wc -c))"

    if [ "$padding" -gt "0" ]; then
        ipv6_address_hex="$(printf "%0${padding}x${ipv6_address_hex}\n" | sed 's/.\{4\}/&:/g')"
    else
        ipv6_address_hex="$(printf "${ipv6_address_hex}\n" | sed 's/.\{4\}/&:/g')"
    fi

    printf "${ipv6_address_hex%:}\n"
}

_create_host_route ()
{
    c12id="$1" ; pipework_cmd="$2"
    set $pipework_cmd ; unset _arping

    [ "$_pipework_host_route_arping" ] || [ "$pipework_host_route_arping" ] && _arping=true

    [ "$2" = "-i" ] && cont_if="$3" || \
    cont_if="eth1"
    host_if="$1"

    _pid="$(_docker_pid $c12id)"

    # Apache 2.0 License, Credit @ jpetazzino
    # https://github.com/jpetazzo/pipework/blob/master/pipework#L201-203
    [ ! -d /var/run/netns ] && mkdir -p /var/run/netns
    [ -f /var/run/netns/$_pid ] && rm -f /var/run/netns/$_pid
    ln -s /proc/${_pid}/ns/net /var/run/netns/$_pid

    for proto in inet inet6; do
        ip_and_netmask="$(ip netns exec $_pid ip -o -f $proto addr show $cont_if | tr -s ' ' | cut -d ' ' -f4)"

        [ "$ip_and_netmask" ] || continue
        ip="$(echo "$ip_and_netmask" |  cut -d/ -f1)"
        netmask="$(echo "$ip_and_netmask" |  cut -d/ -f2)"

        case $proto in
            inet)
                unset last_ip
                if [ "$_debug" ]; then
                    fping -c1 -t200 $ip && continue
                    [ "$_arping" ] && arping -c1 -I $host_if $ip && continue
                else
                    fping -c1 -t200 $ip 2> /dev/null 1> /dev/null && continue
                    [ "$_arping" ] && arping -c1 -I $host_if $ip 2> /dev/null 1> /dev/null && continue
                fi

                last_ipv4=$(sipcalc $ip_and_netmask | grep 'Usable range' | cut -d ' ' -f5 | sed -e 's/255/254/g')
                i=0
                # while true; do
                while [ "$i" -le "10" ]; do
                    if [ "$_debug" ]; then
                        if ! fping -c1 -t200 $last_ipv4; then
                            if [ "$_arping" ]; then
                                arping -c1 -I $host_if $last_ipv4 || break
                            else
                                break
                            fi
                        fi
                    else
                        if ! fping -c1 -t200 $last_ipv4 2> /dev/null 1> /dev/null; then
                            if [ "$_arping" ]; then
                                arping -c1 -I $host_if $last_ipv4 2> /dev/null 1> /dev/null || break
                            else
                                break
                            fi
                        fi
                    fi
                    last_ipv4=$(_decrement_ipv4 $last_ipv4)
                    i=$(expr $i + 1)
                done
                last_ip="$last_ipv4"
                ;;

            inet6)
                unset last_ip
                if [ "$_debug" ]; then
                    fping6 -c1 -t200 $ip && continue
                    ndisc6 -1 -r1 -w200 $ip $host_if && continue
                else
                    fping6 -c1 -t200 $ip 2> /dev/null 1> /dev/null && continue
                    ndisc6 -1 -r1 -w200 $ip $host_if 2> /dev/null 1> /dev/null && continue
                fi

                last_ipv6=$(sipcalc $ip_and_netmask | grep -A1 'Network range' | tail -1)
                last_ipv6=$(_decrement_ipv6 $last_ipv6)
                i=0
                # while true; do
                while [ "$i" -le "10" ]; do
                    if [ "$_debug" ]; then
                        if ! fping6 -c1 -t200 $last_ipv6; then
                            if ! ndisc6 -1 -r1 -w200 $last_ipv6 $host_if; then
                                break
                            fi
                        fi
                    else
                        if ! fping6 -c1 -t200 $last_ipv6 2> /dev/null 1> /dev/null; then
                            if ! ndisc6 -1 -r1 -w200 $last_ipv6 $host_if 2> /dev/null 1> /dev/null; then
                                break
                            fi
                        fi
                    fi
                    last_ipv6=$(_decrement_ipv6 $last_ipv6)
                    i=$(expr $i + 1)
                done
                last_ip="$last_ipv6"
                ;;
        esac

        if [ "$last_ip" ]; then
            #  generate a unique macvlan interface name for the host route
            # e.g. 'pipework eth1 -i eth2 00aa00bb00cc dhcp' --> macvlan_ifname=12p00aa00bb00cc
            if_nums="$(echo $host_if | tr -d '[:alpha:]')$(echo $cont_if | tr -d '[:alpha:]')"
            macvlan_ifname="${if_nums}p${c12id}"

            # create a new host macvlan interface
            ip link add $macvlan_ifname link $host_if type macvlan mode bridge
            # give it the last available ip address in the container ip's subnet
            ip -f $proto addr add $last_ip/$netmask dev $macvlan_ifname
            # bring up the interface
            ip link set $macvlan_ifname up

            if [ "$_debug" ]; then
                # add a new route to container's ip address
                ip -f $proto route add $ip dev $macvlan_ifname
            else
                # add a new route to container's ip address
                ip -f $proto route add $ip dev $macvlan_ifname 2> /dev/null 1> /dev/null
            fi
        fi
    done

    # Apache 2.0 License, Credit @ jpetazzino
    # https://github.com/jpetazzo/pipework/blob/master/pipework#L294
    [ -f /var/run/netns/$_pid ] && rm -f /var/run/netns/$_pid
}

_process_container ()
{
    c12id="$(echo "$1" | cut -c1-12)" # container_id
    unset $(env | grep -e "^pipework.*" | cut -d= -f1)

    _pipework_vars="$(docker inspect --format '{{range $index, $val := .Config.Env }}{{printf "%s\"\n" $val}}{{end}}' $c12id \
        | grep -e 'pipework_cmd.*=\|^pipework_key=\|pipework_host_route.*='| sed -e 's/^/export "/g')"
    [ "$_pipework_vars" ] || return 0

    _macros="$(echo -e "$_pipework_vars" | grep -o -e '@CONTAINER_NAME@\|@CONTAINER_ID@\|@HOSTNAME@\|@INSTANCE@' | sort | uniq)"
    [ "$_macros" ] && _expand_macros;

    eval $_pipework_vars
    [ "$_pipework_key" ] && [ "$_pipework_key" != "$pipework_key" ] && return 0

    _pipework_cmds="$(env | grep -o -e '[^=]*pipework_cmd[^=]*')"
    [ "$_pipework_cmds" ]  || return 0

    for pipework_cmd_varname in $_pipework_cmds; do
        pipework_cmd="$(eval echo "\$$pipework_cmd_varname")"

        # Run pipework
        if [ "$_debug" ]; then
            $_pipework ${pipework_cmd#pipework }
        else
            $_pipework ${pipework_cmd#pipework } 2> /dev/null 1> /dev/null
        fi

        pipework_host_route_var="$(echo "$pipework_cmd_varname" | sed -e 's/pipework_cmd/pipework_host_route/g')"
        pipework_host_route="$(eval echo "\$$pipework_host_route_varname")"
        [ "$_pipework_host_routes" ] || [ "$pipework_host_routes" ] ||[ "$pipework_host_route" ] &&_create_host_route "$c12id" "${pipework_cmd#pipework }";

    done
}

_batch ()
{
    # process all currently running containers
    _batch_start_time="$(date +%s)"
    container_ids="$( docker ps | grep -v -e "CONTAINER\|${_pipework_image_name}" | cut -d ' ' -f1)"

    for container_id in $container_ids; do
        _process_container $container_id;
    done
}

_daemon ()
{
    [ "$_batch_start_time" ] && _pe_opts="$_pe_opts --since=$_batch_start_time"
    [ "$_pipework_up_time" ] && _pe_opts="$_pe_opts --until='$(expr $(date +%s) + $_pipework_up_time)'"

    if [ "$_pipework_event_filters" ]; then
        IFS=,
        for filter in $_pipework_event_filters; do
            _pe_opts="$_pe_opts --format=\'$filter\'"
        done
        unset IFS
    fi

    # Create docker events log
    _docker_events_log="/tmp/docker-events.log"
    rm -f $_docker_events_log
    touch $_docker_events_log
    chmod 0600 $_docker_events_log

    while true; do
        if read event_line < $_docker_events_log; then
            container_id="$(echo -e " $event_line" | grep -v "from $_pipework_image_name" | tr -s ' ' | cut -d ' ' -f3)"
            [ "$container_id" ] && _process_container ${container_id%:};
        fi
    done &
    _while_read_pid=$!

    # Start to listen for new container start events and pipe them to the events log
    docker events $_pe_opts --filter='event=start' $_pipework_daemon_event_opts > $_docker_events_log &
    _docker_events_pid=$!

    # Wait until 'docker events' command is killed by 'trap _cleanup ...'
    wait $_docker_events_pid
    _cleanup;
}

_manual ()
{
    _pipework_cmds="$(env | grep -o -e '[^=]*pipework_cmd[^=]*')"
    if [ "$_pipework_cmds" ]; then
        for pipework_cmd_varname in $_pipework_cmds; do
            pipework_cmd="$(eval echo "\$$pipework_cmd_varname")"

            # Run pipework
            if [ "$_debug" ]; then
                $_pipework ${pipework_cmd#pipework }
            else
                $_pipework ${pipework_cmd#pipework } 2> /dev/null 1> /dev/null
            fi

            pipework_host_route_var="$(echo "$pipework_cmd_varname" | sed -e 's/pipework_cmd/pipework_host_route/g')"
            pipework_host_route="$(eval echo "\$$pipework_host_route_varname")"

            if [ "$_pipework_host_routes" ] || [ "$pipework_host_route" ]; then

                set ${pipework_cmd#pipework }
                [ "$2" = "-i" ] && container="$4" || container="$3"
                c12id="$($docker inspect --format '{{.Id}}' "$container" | cut -c1-12)"

                _create_host_route "$c12id" "${pipework_cmd#pipework }";
            fi
        done

    else
        if [ "$_debug" ]; then
            $_pipework ${_args#pipework }
        else
            $_pipework ${_args#pipework } 2> /dev/null 1> /dev/null
        fi

        if [ "$_pipework_host_routes" ] || [ "$pipework_host_route" ]; then

            set ${_args#pipework }
            [ "$2" = "-i" ] && container="$4" || container="$3"
            c12id="$($docker inspect --format '{{.Id}}' "$container" | cut -c1-12)"

            _create_host_route "$c12id" "${_args#pipework }";
        fi
    fi
}

_main ()
{
    [ "$_pipework_debug" ] && set -x

    if echo "$_pipework_run_mode" | grep ',' 2> /dev/null 1> /dev/null; then
        # Ensure run_modes are processed in correct order: manual --> batch --> daemon
        _run_modes="$(echo manual batch daemon | \
            grep -o "$(echo "$_pipework_run_mode" | \
                sed -e 's/both/batch,daemon/g' -e 's/all/manual,batch,daemon/g' -e 's/,/\\|/g')")"

        for run_mode in $_run_modes; do
            eval "_${run_mode};"
        done

    elif [ "$_pipework_run_mode" ]; then
        case "$_pipework_run_mode" in
            manual)     _manual ;;
            batch)      _batch ;;
            daemon)     _daemon ;;
            both)       _batch; _daemon ;;
            all)        _manual; _batch; _daemon ;;
        esac
    else
        _manual;
    fi
}

# Begin
_test_docker;
_setup_container_for_host_access;
_main;
