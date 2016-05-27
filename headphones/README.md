## Headphones

### Configuration

You will use headphone's web interface to specify it's settings. Main settings seem to be written to the file `/config/config.ini`. Which can be backed up / restored by using docker's build context and the `ADD` command.

### Media folders

Headphones may be given read-only access to your top-level media folder. From there, you should grant write access in 2 subfolders of your main `/media` folder:

It may help if the source + destination paths are are inside the same mountpoint. To avoid lots of copying large files across different drives. And that is the reason we mount the parent folder `/media` into a docker volume.

If you have other unrelated folders inside your `/media` folder (music, games etc). Then set the uid/gid and folder permissions to ensure that `headphones` user cannot read or write to the other folders.

### File permissions

By default headphones will run as the `headphones` user and group. With a default `uid:gid` of `8181:8181`. Same as it's web interface TCP port number. So you will never forget.

You can change it's UID and GID to your liking by setting the following docker env vars:

```sh
hp_uid=XXX
hp_gid=YYY
```

By specifying an alternative uid and gid as a number, this lets you control which folder(s) headphones has read/write access to.

#### Add your host user account to the headphones group

If you do not change the headphones gid number to match your other accounts, then you can instead permit your own host account(s) file access to the delueg folders by making the group permissions writable e.g. chmod `0664` and `0775`.

On the host side you will need to create a `headphones` group, adding your own user account to be a member of the same group gid (the default value of the headphones gid is `8181`). Copy-paste these commands:

```sh
sudo groupadd -g 8181 headphones
sudo usermod -a -G headphones $(id -un)
```

### Configuration

This image comes with some vanilla default configuration.

### Docker Compose

Sorry there is no example for Compose at this time. But it is something like this:

```sh
  cp:
    image: dreamcat4/headphones
    run:
      ip: 1.2.3.4
      volume:
        - /my/headphones/config/folder:/config
        - /my/media/top/level/folder:/media
      env:
        # - hp_uid=65534
        # - hp_gid=44
      detach: true
```
