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

# Download the dh-trigger cmd with wget or curl
wget -O $HOME/.bin/dh-trigger https://raw.githubusercontent.com/dreamcat4/docker-images/master/tvh/ubuntu.build/dh-trigger/dh-trigger || \
curl https://raw.githubusercontent.com/dreamcat4/docker-images/master/tvh/ubuntu.build/dh-trigger/dh-trigger -o $HOME/.bin/dh-trigger

# Make executable
chmod +x $HOME/.bin/dh-trigger

# Add the bin/ folder to your $PATH if not already
echo "PATH=\"\$PATH:$HOME/.bin\"" >> ~/.profile
echo "PATH=\"\$PATH:$HOME/.bin\"" >> ~/.bashrc
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

We need to specify 2 similar cron lines because of a technical issue regarding daylight savings time.

```sh
# Add a new cron job line to fire off your chosen trigger command
crontab -e    # or 'cru' on some machines
>>>
# Rebuild all image tags (branches) at 03:15am UTC every morning
15 03 * * * [ "$(date +%z)" = "+0000" ] && $HOME/.bin/dh-trigger all dreamcat4/nginx
15 04 * * * [ "$(date +%z)" = "+0100" ] && $HOME/.bin/dh-trigger all dreamcat4/nginx
<<<
```

The trigger command `all` will trigger all the `tags` (branches) of your repo simultaneously. However you may not wish for every one of them to be re-build every time. Then use one of the other trigger commands `dh-trigger --help` for more information.

*It is necessary to make 2 cron lines for each command, as is shown above. To ensure the job will always execute on `UTC` time, irrespective of the 1 hour seasonal shift of your local daylight savings time. This is because even between machines within the same timezone, their can be a number of days when their local offsets are out of sync. Specifically, when one or more of those systems are based on busybox or ulibc. Then the seasonal change date has always been hardcoded and is never guaranteed to be consistent.*

***2nd example:***

If your regular time is `+0500` shift of `UTC`, and your seasonal time is `+0600` shift of `UTC`. Then add `+5` to all of the hours specified in above example. This means being run at `08:15am` and `09:15am` of your local time respectively. So your modified cron lines would then look like this:

```sh
# Add a new cron job line to fire off your chosen trigger command
crontab -e    # or 'cru' on some machines
>>>
# Rebuild all image tags (branches) at 03:15am UTC every morning
15 08 * * * [ "$(date +%z)" = "+0500" ] && $HOME/.bin/dh-trigger all dreamcat4/nginx
15 09 * * * [ "$(date +%z)" = "+0600" ] && $HOME/.bin/dh-trigger all dreamcat4/nginx
<<<
```

***Cron job redundancy:***

But what if your computer does down or has technical problems? Then the scheduled build job will fail to get triggered.

Well since we have solved the time zone problem, we can just repeat the same steps above on other machines. And the same set of cron job(s) will trigger at the same times. Dockerhub will ignore any duplicate build requests. *So long as they are all made within the same 5 minute window. Therefore, in addition to the timezone fix, be sure also that the system time on every machine is being kept in sync with ntpd. Otherwise there is likely to be a significant amount of clock drift.*


