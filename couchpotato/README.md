## Couchpotato

### Configuration

You will use couchpotato's web interface to specify it's settings. Main settings seem to be written to the file `/config/settings.conf`. Which can be backed up / restored by usig docker's build context and the `ADD` command.

### Map your Media folder to the /downloads volume

couchpotato may be given read-only access to your top-level media folder. It should be bind:mounted to `/downloads`. You may selectively grant write access in subfolders of that folder. Depending upon your configuration.

It may help effeciency if the source + destination paths are are inside the same mountpoint. To avoid lots of copying large files across different drives. And that is the reason we mount the parent folder `/media` into a docker volume.

If you have other unrelated folders inside your `/media` folder (music, games etc). Then set the uid/gid and folder permissions to ensure that `couchpotato` user cannot read or write to the other folders.

### File permissions

By default couchpotato will run as the `couchpotato` user and group. With a default `uid:gid` of `5050:5050`. Same as it's web interface TCP port number. So you will never forget.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
cp_uid=XXX
cp_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) couchpotato has read/write access to.

#### Add your host user account to the couchpotato group

If you do not change couchpotato's gid number to match your other accounts, then you can instead permit your own host account(s) file access to the delueg folders by making the group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will need to create a `couchpotato` group, adding your own user account to be a member of the same group gid (the default value of couchpotato's gid is `5050`). Copy-paste these commands:

```sh
sudo groupadd -g 103 couchpotato
sudo usermod -a -G couchpotato $(id -un)
```

### Docker Compose

Sorry there is no example for Compose at this time. But it is something like this:

```sh
  cp:
    image: dreamcat4/couchpotato
    run:
      ip: 1.2.3.4
      volume:
        - /my/couchpotato/config/folder:/config
        - /my/media/folder:/downloads
      env:
        # - cp_uid=65534
        # - cp_gid=44
      detach: true
```


