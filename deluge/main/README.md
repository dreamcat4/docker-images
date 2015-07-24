# Deluge

### File permissions

The container has a user and a group each named `debian-deluged`. With a `uid:gid` of `101:103`. This can be verified on the cmdline:

```sh
$ docker exec deluge sh -c "cat /etc/passwd | grep debian-deluged ; cat /etc/group | grep debian-deluged"
debian-deluged:x:101:103::/config:/bin/sh
debian-deluged:x:103:
```

Since the deluge daemon is always being launched as that process user & group. Then the simplest solution is to keep the container's user as `debian-deluged`. And just permit yourself file access using the group level writable permissions bits e.g. chmod `0664` and `0775`.

On host side you will need to create a group named `debian-deluged`. Adding your own user account to be a member of the same group gid (`103`). Just copy-paste these commands:

```sh
sudo groupadd -g 103 debian-deluged
sudo usermod -a -G debian-deluged $(id -un)
```

