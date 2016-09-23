***Source: [dperson/samba](https://github.com/dperson/samba)***

[![logo](http://www.samba.org/samba/style/2010/grey/headerPrint.jpg)](https://www.samba.org)

# Samba

A docker image of Samba v4.1.6+. [DockerHub Page](https://registry.hub.docker.com/u/dreamcat4/samba/).

# What is Samba?

Since 1992, Samba has provided secure, stable and fast file and print services
for all clients using the SMB/CIFS protocol, such as all versions of DOS and
Windows, OS/2, Linux and many others.

# How to use this image

By default there are no shares configured, additional ones can be added.

## Hosting a Samba instance

    docker run -p 139:139 -p 445:445 -d dreamcat4/samba

OR set local storage:

    docker run --name samba -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d dreamcat4/samba

## Configuration

    docker run -it --rm dreamcat4/samba -h

    Usage: samba.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -s "<name;/path>[;browse;readonly;guest;users]" Configure a share
                    required arg: "<name>;<comment>;</path>"
                    <name> is how it's called for clients
                    <path> path to share
                    [browseable] default:'yes' or 'no'
                    [readonly] default:'yes' or 'no'
                    [guest] allowed default:'yes' or 'no'
                    [users] allowed default:'all' or list of allowed users
        -t ""       Configure timezone
                    possible arg: "[timezone]" - zoneinfo timezone for container
        -u "<username;password>[;uid;group;extra_groups]" Add a user
                    required arg: "<username>;<passwd>"
                    <username> for user
                    <password> for user
        -g "<groupname>[;gid]" Add a group
        -e          Export smbpasswd file to stdout
        -i "<path>" Import smbpassword
                    required arg: "<path>" - full file path in container to import


    The 'command' (if provided and valid) will be run instead of samba

ENVIROMENT VARIABLES (only available with `docker run`)

 * `TIMEZONE` - As above, set a zoneinfo timezone, IE `EST5EDT`

## Examples

### Start an instance and set the timezone:

Any of the commands can be run at creation with `docker run` or later with
`docker exec samba.sh` (as of version 1.3 of docker).

    docker run -p 139:139 -p 445:445 -d dreamcat4/samba -t EST5EDT

Will get you the same settings as

    docker run --name samba -p 139:139 -p 445:445 -d dreamcat4/samba
    docker exec samba samba.sh -t EST5EDT ls -AlF /etc/localtime
    docker restart samba

### Start an instance creating users and shares:

    docker run  -p 139:139 -p 445:445 -d dreamcat4/samba \
                -g "group2;130" \
                -u "user1;badpass1" \
                -u "user2;badpass2;1002;;group2" \
                -s "public;/share" \
                -s "users;/srv;no;no;no;user1,user2" \
                -s "user1 private;/user1;no;no;no;user1" \
                -s "user2 private;/user2;no;no;no;user2"

### Export - Import smbpasswd file

This will avoid plaintext passwords.

Generate new smbpasswd file:

    smbpasswd_file="$HOME/.smb/smbpasswd.container1"
    install -d -m 0700 "$HOME/.smb"
    install -m 0600 /dev/null "$smbpasswd_file"
    cont_id="$(docker run  --net=none -p 139:139 -p 445:445 -d dreamcat4/samba \
                    -u "user1;badpass1" -u "user2;badpass2" -e)"
    sleep 2
    docker logs $cont_id 2>&1 | grep XXXXXXXX >> $smbpasswd_file
    docker stop $cont_id
    docker rm   $cont_id

Import smbpasswd file:

    docker run  -p 139:139 -p 445:445 -d \
                -v $smbpasswd_file:/root/.smbpasswd \
                dreamcat4/samba -u "user1" -u "user2" -i "/root/.smbpasswd"

## Docker compose

Sorry there isn't an example specifically for compose. However you can adapt from this `crane.yml` file which is very similar:

    containers:

      smb.plaintext.password:
        image: dreamcat4/samba
        run:
          net: none
          cmd: -t "Europe/London" -u "sambauser1;password;1000;users;operator" -s "samba_sharename1;/share/mount;yes;no;no;sambauser1"
          volume:
            - /my_hdd/sambauser1/s/share/folder:/share/mount
          detach: true
          env:
            - pipework_wait=eth0
            - pipework_cmd=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.101

      smb.with.mounted.smbpasswd.file:
        image: dreamcat4/samba
        run:
          net: none
          cmd: -t "Europe/London" -u "smbuserB;password;1000;;root" -s "samba_sharenameB;/share/mount;yes;no;no;smbuserB" -i "/root/.smbpasswd"
          volume:
            - /my_hdd/smbuserB/s/share/folder:/share/mount
            - /my_hdd/smbuserB/s/.smbpasswd:/root/.smbpasswd
          detach: true
          memory: 500m
          memory-swap: 600m
          env:
            - pipework_wait=eth0
            - pipework_cmd=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.101

The extra `pipework_` env variables are for setting up alternative networking with the `dreamcat4/pipework` helper image. They are not needed if you are using docker's build in networking.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dreamcat4/docker-images/issues).

