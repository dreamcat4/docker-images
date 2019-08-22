#!/bin/bash -x
#===============================================================================
#          FILE: samba.sh
#
#         USAGE: ./samba.sh
#
#   DESCRIPTION: Entrypoint for samba docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#       CREATOR: David Personette (dperson@gmail.com),
#    MAINTAINER: Dreamcat4 (dreamcat4@gmail.com),
#  ORGANIZATION:
#       CREATED: 09/28/2014 12:11
#       UPDATED: 07/08/2015 21:11
#      REVISION: 2.0.0
#===============================================================================


if [ "$pipework_wait" ]; then
    echo "Waiting for pipework to bring up $pipework_wait..."
    pipework --wait -i $pipework_wait
fi


### share: Add share
# Arguments:
#   share) share name
#   path) path to share
#   browseable) 'yes' or 'no'
#   readonly) 'yes' or 'no'
#   guest) 'yes' or 'no'
#   users) list of allowed users
# Return: result
share() { local share="$1" path="$2" browse=${3:-yes} ro=${4:-yes}\
                guest=${5:-yes} users=${6:-""} file=/etc/samba/smb.conf
    sed -i "/\\[$share\\]/,/^\$/d" $file
    echo "[$share]" >> $file
    echo "   path = $path" >> $file
    echo "   browseable = $browse" >> $file
    echo "   read only = $ro" >> $file
    echo "   guest ok = $guest" >> $file
    [[ ${users:-""} ]] &&
        echo "   valid users = $(tr ',' ' ' <<< $users)" >> $file
    echo -e "" >> $file
}

### timezone: Set the timezone for the container
# Arguments:
#   timezone) for example EST5EDT
# Return: the correct zoneinfo file will be symlinked into place
timezone() { local timezone="${1:-EST5EDT}"
    [[ -e /usr/share/zoneinfo/$timezone ]] || {
        echo "ERROR: invalid timezone specified" >&2
        return
    }

    ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
}

### user: add a user
# Arguments:
#   name) for user
#   password) for user
#   uid) uid for user
#   group) primary group or gid for user (group must exist)
#   extra_groups) supplemental groups or gids for user (groups must exist)
# Return: user added to container
user() { local name="${1}" passwd="${2}" uid="${3:-}" gid="${4:-}" extra_groups="${5:-}"
    local ua_args=""
    [ "$uid" ] && ua_args="$ua_args -o -u $uid"
    [ "$gid" ] && ua_args="$ua_args -g $gid"
    [ "$extra_groups" ] && ua_args="$ua_args --groups $extra_groups"

    useradd "$name" -M $ua_args || usermod $ua_args "$name"
    [ "$passwd" ] && echo "$passwd
$passwd" | smbpasswd -s -a "$name"
}

### group: add a group
# Arguments:
#   name) for group
#   gid) gid for group
# Return: group added to container
group() { local name="${1}" gid="${2:-}"
    local ua_args=""
    [ "$gid" ] && ua_args="$ua_args -o -g $gid"
    groupadd "$name" $ua_args || groupmod $ua_args "$name"
}

### export: export a smbpasswd file
# Outputs to stdout the hased lines for import later on
export_() {
    pdbedit --list --smbpasswd-style
    exit $?
}

### import: import a smbpasswd file
# Arguments:
#   file) file to import
# Return: user(s) added to container
import() { local name uid file="${1}"
    while read name uid; do
        [ "$(id -u "$name" 2> /dev/null)" ] || useradd "$name" -M -u "$uid"
    done < <(cut -d: -f1,2 --output-delimiter=' ' $file)
    pdbedit -i smbpasswd:$file
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() { local RC=${1:-0}
    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
    -h          This help
    -s \"<name;/path>[;browse;readonly;guest;users]\" Configure a share
                required arg: \"<name>;<comment>;</path>\"
                <name> is how it's called for clients
                <path> path to share
                [browseable] default:'yes' or 'no'
                [readonly] default:'yes' or 'no'
                [guest] allowed default:'yes' or 'no'
                [users] allowed default:'all' or list of allowed users
    -t \"\"       Configure timezone
                possible arg: \"[timezone]\" - zoneinfo timezone for container
    -u \"<username;password>[;uid;group;extra_groups]\" Add a user
                required arg: \"<username>;<passwd>\"
                <username> for user
                <password> for user
    -g \"<groupname>[;gid]\" Add a group
    -e          Export smbpasswd file to stdout
    -i \"<path>\" Import smbpasswd
                required arg: \"<path>\" - full file path in container to import

The 'command' (if provided and valid) will be run instead of samba
" >&2
    exit $RC
}

cd /tmp

while getopts ":hs:t:u:g:ei:" opt; do
    case "$opt" in
        h) usage ;;
        s) eval share $(sed 's/^\|$/"/g; s/;/" "/g' <<< $OPTARG) ;;
        t) timezone "$OPTARG" ;;
        u) eval user  $(sed 's/^\|$/"/g; s/;/" "/g' <<< $OPTARG) ;;
        g) eval group $(sed 's/^\|$/"/g; s/;/" "/g' <<< $OPTARG) ;;
        e) export_ ;;
        i) import   "$OPTARG" ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

[[ "${TIMEZONE:-""}" ]] && timezone "$TIMEZONE"

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 13
elif ps -ef | egrep -v grep | grep -q smbd; then
    echo "Service already running, please restart container to apply changes"
else
    if [ "$disable_nmbd" ]; then
        exec ionice -c 3 smbd -FS </dev/null
    else
        ionice -c 3 nmbd -D
        exec ionice -c 3 smbd -FS </dev/null
    fi
fi
