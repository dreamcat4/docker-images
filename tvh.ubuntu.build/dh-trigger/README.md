## dh-trigger

A simple program to trigger dockerhub's automated builds. This is performed by enabling 'build triggers' on the setting of the target dockerhub repo, and obtaining it's 'trigger token'. Once you have the trigger token (an api key), then you can input into the `dh-trigger` program.

Trigger tokens are secured as `chmod 0600` files sitting inside of a `chmod 0700` subdirectory of the user's home folder. In the `~/.dh-trigger/` configuration folder.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
 

- [Installation](#installation)
- [Cmdline Usage](#cmdline-usage)
- [Add a trigger](#add-a-trigger)
- [Running a build trigger](#running-a-build-trigger)
- [Setting up a cron job](#setting-up-a-cron-job)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Installation

```sh
# Choose a location on your $PATH where to save the 'dh-trigger' script
mkdir -p $HOME/.bin

# Download the dh-trigger cmd with curl
curl https://raw.githubusercontent.com/dreamcat4/docker-images/master/tvh.ubuntu.build/dh-trigger -o $HOME/.bin/dh-trigger/dh-trigger

# Or with wget
wget -O $HOME/.bin/dh-trigger https://raw.githubusercontent.com/dreamcat4/docker-images/master/tvh.ubuntu.build/dh-trigger/dh-trigger

# Add the bin/ folder to your $PATH if not already
echo "PATH=\"$PATH:$HOME/.bin\"" >> ~/.profile
echo "PATH=\"$PATH:$HOME/.bin\"" >> ~/.bashrc
```

### Cmdline Usage

Use `dh-trigger --help` to print the cmdline usage:

```sh
 dh-trigger:
      Dockerhub trigger tool. Build new docker images (build triggers).

 Usage:
      $ dht <cmd> <user>/<repo> [args]

 Configure:
      add        - Add a new build trigger & trigger token
      remove     - Remove a build trigger
      list       - List available build triggers

 Build Triggers:
      all        - Trigger a new build of all dockerhub tags
      tag        - Trigger a new build on the specified dockerhub tag
      git-branch - Trigger a new build on all tags matching src git branch
      git-tag    - Trigger a new build on all tags matching src git tag

 Examples:

      dh-trigger add dreamcat4/nginx "$trigger_token"
      dh-trigger list
      dh-trigger all dreamcat4/nginx
      dh-trigger tag dreamcat4/nginx "latest"
      dh-trigger git-branch dreamcat4/nginx "master"
      dh-trigger git-tag dreamcat4/nginx "v4.0.1.0"
      dh-trigger remove dreamcat4/nginx

 Options:
      -v,--version   - Print the current version of drb and exit.
      -h,--help      - Display this message and exit.

 Version:
      1.0.0
```

### Add a trigger

First get your trigger token from dockerhub config pages ('build triggers' link). Then add it like this:

```sh
# Put here your REAL build trigger key, and write it to file
trigger_token="YOUR-IMAGE's-TRIGGER-TOKEN"

# Save your trigger key to a chmod 600 file in the ~/.dh-trigger/ folder
dh-trigger add "dreamcat4/nginx" "$trigger_token"
```

### Running a build trigger

Run this command & go check the dockerhub 'Build details' page.

```sh
dh-trigger all dreamcat4/nginx
```

### Setting up a cron job

```sh
# Add a new cron job line to fire off your chosen trigger command
crontab -e
>>>
# Set the $PATH to 'dh-trigger' cmd here in your crontab, e.g. if 'root' user, then
PATH="$PATH:/root/.bin"

# OR: as regular user 'bob', then
PATH="$PATH:/home/bob/.bin"


# Rebuild all image tags (branches) at 03:17am every morning
17 3 * * * dh-trigger all dreamcat4/nginx
<<<
```

The trigger command `all` will trigger all the `tags` (branches) of your repo simultaneously. However you may not wish for every one of them to be re-build every time. Then use one of the other trigger commands `dh-trigger --help` for more information.

