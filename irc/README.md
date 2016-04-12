*This page is best viewed on --->* ***[Github](https://github.com/dreamcat4/docker-images/tree/master/irc).***

*Back to this page on --->* ***[DockerHub](https://hub.docker.com/r/dreamcat4/irc/).***

* This Docker image is based on ubuntu 16.04 base image (xenial xerus).
* **1.4 GB Image size[***](https://github.com/dreamcat4/docker-images/tree/master/irc#pros-and-cons-of-this-docker-image).**

# irc

A collection of pre-configured irc programs and services. Designed to make IRC easy. Everything to come up on container start, all working together.

**Includes [irssi over ssh](http://i.imgur.com/Fk94eHf.png) and [glowing-bear web interface](http://i.imgur.com/bAAPFkS.png), as pictured below.**

...but also: ***SO MUCH MORE!***

![irssi client theme customizations](http://i.imgur.com/Fk94eHf.png "irssi client theme customizations")

![glowing-bear web interface](http://i.imgur.com/bAAPFkS.png "glowing-bear web interface")

## Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
 

- [What's included?](#whats-included)
  - [Pros and Cons of this Docker image](#pros-and-cons-of-this-docker-image)
  - [Connection diagram](#connection-diagram)
  - [Service ports](#service-ports)
- [Quickstart](#quickstart)
    - [Configure local irc server - peer passwords](#configure-local-irc-server---peer-passwords)
  - [Connecting](#connecting)
    - [Over ssh](#over-ssh)
    - [From a web browser](#from-a-web-browser)
- [IRC Servers](#irc-servers)
- [Editing configuration files](#editing-configuration-files)
- [Configuration](#configuration)
  - [ssh](#ssh)
  - [znc](#znc)
  - [weechat](#weechat)
  - [irssi](#irssi)
  - [IRC Data](#irc-data)
  - [Logs](#logs)
  - [URLs](#urls)
  - [Bitlbee](#bitlbee)
  - [tmux](#tmux)
  - [Limnoria (aka supybot)](#limnoria-aka-supybot)
  - [ngircd](#ngircd)
  - [atheme irc services](#atheme-irc-services)
  - [Bitlbee chat protocols](#bitlbee-chat-protocols)
    - [LibPurple](#libpurple)
    - [WhatsApp](#whatsapp)
    - [Skype](#skype)
    - [SIPE](#sipe)
    - [Facebook](#facebook)
    - [Steam Chat](#steam-chat)
    - [Telegram](#telegram)
    - [Torchat](#torchat)
    - [Other chat protocols](#other-chat-protocols)
- [Connecting to the irssi session](#connecting-to-the-irssi-session)
- [Disconnecting from an irssi session](#disconnecting-from-an-irssi-session)
- [Per-user setup](#per-user-setup)
  - [ZNC user configuration](#znc-user-configuration)
  - [Setting up nickserv on znc](#setting-up-nickserv-on-znc)
  - [Per-network Authentication methods](#per-network-authentication-methods)
    - [&bitlbee](#&bitlbee)
    - [dalnet](#dalnet)
    - [efnet](#efnet)
    - [freenode](#freenode)
    - [gnome](#gnome)
    - [ircnet](#ircnet)
    - [mozilla](#mozilla)
    - [oftc](#oftc)
    - [quakenet](#quakenet)
    - [undernet](#undernet)
- [Irssi Scripts](#irssi-scripts)
  - [Tweaked scripts](#tweaked-scripts)
  - [Not met script dependancies](#not-met-script-dependancies)
- [File permissions](#file-permissions)
- [Docker Compose](#docker-compose)
- [Web-browser alternative](#web-browser-alternative)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## What's included?

* IRC clients
  * [irssi](https://irssi.org/)
  * [weechat](https://weechat.org/about/screenshots/), for the [glowing-bear](https://www.glowing-bear.org/) web interface
  * [tmux](https://en.wikipedia.org/wiki/Tmux) and [sshd](http://www.openssh.com/) for terminal services

* IRC services
  * [ZNC bouncer](http://wiki.znc.in/Webadmin)
  * [Bitlbee](https://wiki.bitlbee.org/) (for IM accounts)
  * [ngircd](https://github.com/ngircd/ngircd) - your own local / private IRC server
    * [atheme irc services](https://atheme.github.io/atheme.net/atheme.html) - for nickserv, sasl etc
  * [Limnoria IRC bot](http://doc.supybot.aperio.fr/en/latest/use/index.html) (aka supybot)

### Pros and Cons of this Docker image

**Pros:**

* All of the *best*, most *useful*, and most *practical* IRC services
* Services come preconfigured to work together with each other out-of-the box, often communicating over localhost 127.0.0.1
* Each service runs under its own unpriviledged unix account
* Well organised `/config` folder, with user pre-seeding
  * the is easiest way to manage your irc settings files
  * can diff, merge, version control, and overlay your per-user IRC settings ontop of the pre-configured defaults
* Bitlbee comes 'fully' loaded with support for all of the major chat protocols - no hassles, just go!
* Not resource hungry, can easily run on local modest hardware, or limited remote VPS plan. With ease.

**Cons:**

* Very large image size ~1.4gb, most of which is the bitlbee (IM chat) and limnoria (irc bot) dependancies
* It is less secure than having many isolated individual images
* May include some service you didn't want

***However:***

This image's Dockerfile has been properly organised into isolated sections for each services. And each service is kept in individual separate folders. Therefore this image should be very easily broken down. Want to split it up / remove some un-needed services? Should be a sinch.

***Top tip:***

Bitlbee and limnoria were by far the biggest culprits to image bloat here. The large image size is mostly due to their dependancies. Before adding them the image was 'only a mere ~700mb'. By adding them it fully doubled the image size from previous all estimates. That smarted much. But ah well! What can you do eh? Be left without access to all the most popular IM chat servers in the entire world? Live life without your very own personal IRC bot? Noooooo! :)))

I shall leave it for some other guys to come and break up the party. This one shall remain a masterpiece complete. The complete collection. The full enchilada. So be it. 1.4 GB urrrghhh then. At least everything runs super-fast, and not slow or cacky in any way.

### Connection diagram

General diagram how these programs are connected up:

```sh

atheme <--- ngircd <-\        /- limnoria IRC bot (supybot)
Public IRC Servers <--- ZNC <--- irssi <--- TMUX Session <--- SSH <--- Client computer
           Bitlbee <-/        \- weechat -/
                                    \- weechat relay <--- glowing bear <--- web browser
```

And thanks to TMUX, simultaneous ssh logins are supported. So you can have the same irssi or weechat text-based session open on multiple machines no problem. And multiple glowing-bear instances of the web interface too.

### Service ports

This container runs multiple services on it, and as several different user accounts. They are as follows:

```sh
INTERFACE, TCP_PORT, (PROTOCOL), UNIX_USER, SERVICE, COMMENT

0.0.0.0 (all interfaces), 22, (SSH term), irssi, irssi client in a tmux session, always running

0.0.0.0 (all interfaces), 6697, (SSL HTTPS), znc, znc web interface, for configuring the znc service

0.0.0.0 (all interfaces), 6697, (SSL IRC), znc, znc irc server, for other irc clients / mobile apps etc. can be disabled in znc.conf file, then restart container / znc server

0.0.0.0 (all interfaces), 9001, (SSL weechat relay), weechat, weechat relay port, for glowing-bear web-based IRC interface

localhost, 9997 (SSL IRC), znc, znc irc server, only visible inside container, for client: conatiner's local instance of irssi program

localhost, 6111, (http IRC), bitlbee, bitlbee irc server, only visible inside container, for client: local ZNC server

localhost, 6667, (http IRC), ngircd, ngircd irc server, only visible inside container, for client: local ZNC server
```

The user is intended to access the IRC service primarily as the user `irssi`, on ssh port 22. Via public-private SSH key authentication (no ssh password). The container's irssi program itself is always kept running under a perpetual tmux session named `tmux`. Which supports simultaneous logins from multiple computers.

## Quickstart

For the most part, you just need to set new username & password(s) for your own personal irc accounts. However these same logins are referenced across multiple programs / multiple configuration files.

* After this section is completed, all of your znc bouncer account logins should be updated.

* Some irc networks also require you to identify yourself, or register your nickname with their services. That has not been covered in this quickstart section. As that depends which specific irc servers you actually wish to connect to. There is a seperate section for all the nickserv stuff / per-network registration instructions.

### Configure ZNC

* Create a new container of `dreamcat4/irc` image, with bind:mounted volumes for the `/config` and `/irc` folders
* Start the container

* Point your web browser to `https://CONTAINER_IP:6697`
  * Log into znc web interface with initial username: `znc` and password: `znc`

* Click 'Manage Users'
  * Click 'Clone' button for `znc` user
    * To give your own real nickname, and choose a new password
    * Click 'Clone and Return' button

* After saving new user, click 'Edit' again, and In the 'Flags' section, select 'admin' checkbox to make yourself the admin user
* Logout as user `znc`
* Log back in as your own nickname, with your new password

* Click 'Manage Users' again
  * Delete the initial `znc` user account

  * Click 'Clone' button for `supybot` machine account
    * Again to give your bot its own nickname, and choose a unique password for it
    * Delete the previous `supybot` machine account

* You should be left with 2 znc user accounts. 1 admin status account of `YOUR_IRC_NICKNAME`. Plus 1 machine account of `YOUR_IRC_BOT_NICKNAME`.

* Stop the container
* Navigate to the bind:mounted volume `/config`

Now for some reason (or perhaps a bug in znc), as a side-effect of our user clone operation znc has inserted many redundant duplicate config lines in each network's config block. Which are now incorrectly referring to the previous nicknames we dont wish for: `znc_user`and `supybot`. Therefore, we must now also replace all cruft instances of the `znc_user` and `supybot` strings in the znc config text file, located at:

```sh
/config/znc/configs/znc.conf
```

Just search / replace all occurences of the string with your own personal irc nickname. Or else just delete them. As they are all extraneous config lines being repeated, they are not actually needed.

### Configure irc clients

We now need to replace the znc username:password login credentials, with your new user accounts. The next files to modify are:

```sh
/config/irssi/config
/config/limnoria/supybot.conf
/config/limnoria/conf/users.conf
/config/weechat/irc.conf
/config/weechat/relay.conf
```

#### irssi

**`/config/irssi/config:`**

* For the znc server logins, those instructions are included inside the config file itself.

* You should also change the following irssi's settings to your real IRC nickname / account name:

```perl
settings = {
  core = {
    real_name = "znc user";
    user_name = "znc_user";
    nick = "znc_user";
```

BTW, the following setting:

```perl
ipw_password = "irssi";
```

Is the login access password for 'glowing-bear over irssi'. That would require extra runtime files which is not included in the container. We decided to leave it out because it is simpler to use glowing-bear with weechat instead.

#### limnoria (aka supybot)

**`/config/limnoria/supybot.conf:`**

Find these bot settings, and change them to your bot's new znc name / znc password:

```yaml
supybot.nick: supybot
supybot.ident: supybot
supybot.user: znc_users familiar
```

And for each network login setting, just as we show in the irssi config file, change them to:

```yaml
supybot.networks.NETWORK.password: ZNC_BOT_USERNAME/NETWORK:ZNC_BOT_PASSWORD
```

The lines to find are:

```yaml
supybot.networks.barton.password: supybot/barton:supybot
supybot.networks.bitlbee.password: supybot/bitlbee:supybot
supybot.networks.dalnet.password: supybot/dalnet:supybot
and so on...
```

There are about 12 networks to update.

**`/config/limnoria/conf/users.conf:`**

Replace the bot owner `znc_user` --> `YOUR_IRC_NICKNAME`.

The default initial 'owner password' is also stored here. However in a hashed form. Owner password is used to identify yourself as to the bot as its admin, and take ownership of it. The default owner password is `supybot`. But its encrypted so we cant change it right now. Once logged in over IRC, you first authenticate yourself with that initial owner password `supybot`. Then change it with `/query supybot user set password supybot YOUR_NEW_BOT_OWNER_PASSWORD`.

#### weechat

**`/config/weechat/irc.conf:`**

In this file, you must now update the following options, with the credendials of your new znc user account:

```perl
nicks = "znc_user,znc_user_"
password = "znc"
```

then also for each configured znc network:

```perl
barton.username = "znc/barton"
bitlbee.username = "znc/bitlbee"
dalnet.username = "znc/dalnet"
and so on...
```

There are about 12 networks to update.

**`/config/weechat/relay.conf:`**

This is for your glowing-bear web access / login password. Change the line:

```perl
password = "weechat"
```

### Configure local irc server - peer passwords

We can change the peer connection password, to help secure our own local irc server and its seperated atheme services daemon.

**`/config/atheme/atheme.conf:`**

Find the lines:

```sh
  send_password = "atheme";
  receive_password = "ngircd";
```

**`/config/ngircd/ngircd.conf:`**

Find the lines:

```sh
  MyPassword = atheme
  PeerPassword = ngircd
```

And change the 2 passwords to something un-guessable. Make sure that the `send_password` still matches the `MyPassword` in the other file. And that the `receive_password` = `PeerPassword` in counterpart file.

* That is the quickstart configuration finished!

It is now recommended to copy only these few modified config files, into the overlay folder named `config.custom/` in the docker build context. Which can be checked out from github repo. Then if you ever re-build this docker image yourself, it will automatically include all your unique login / accounts info (as the pre-seeded default /config).

### Connecting

#### Over ssh

For ssh, you can find new ssh private access keys. They are auto-generated on first boot, into the following locations:

```sh
/config/irssi/.ssh/id_rsa
/config/weechat/.ssh/id_rsa
```

Grab the 2 unique `id_rsa` private key files. One is for irssi, and the other one is for weechat. Rename them to something obvious. For example `irssi_rsa` and `weechat_rsa`. Then copy them to your client computers from where you want to login. Then you can ssh something like this:

```sh
ssh -i irssi_rsa irssi@CONTAINER_IP
ssh -i weechat_rsa weechat@CONTAINER_IP
```

Or even better, create ssh aliases, to just `ssh irssi` and `ssh weechat`.

```sh
.ssh/config:

Host irssi
    Hostname YOUR_CONTAINER_IP
    User irssi
  PubKeyAuthentication yes
    IdentityFile ~/.ssh/irssi_rsa

Host weechat
    Hostname YOUR_CONTAINER_IP
    User weechat
  PubKeyAuthentication yes
    IdentityFile ~/.ssh/weechat_rsa
```

#### From a web browser

For glowing-bear web access, over HTTPS SSL/TLS:

Navigate in your web browser to the [glowing bear website](https://www.glowing-bear.org). You should be able to log in with `CONTAINER_IP` and TCP port `9001`. And the weechat relay password you have put into `/config/weechat/relay.conf`. Make sure you have selected the SSL/TLS secure connection option. Since it is not configured for regular (unsecured) http.


## IRC Servers

IRC Networks and channels pre-configured. However they are not all switched on by default. You will need to go into your znc web settings to enable / disable each networks you want to znc to connect to.

#### Public IRC networks

  * barton
    * `#ngircd`
      * public help / support channel

  * dalnet

  * efnet

  * freenode
    * `#atheme`
      * public help / support channel
    * `#irssi`
      * public help / support channel
    * `#limnoria`
      * public help / support channel
    * `#weechat`
      * public help / support channel
    * `#znc`
      * public help / support channel

  * gnome

  * ircnet

  * mozilla

  * oftc
    * `#bitlbee`
      * public help / support channel

  * quakenet

  * undernet


#### Private / localhost services

  * "ngircd"
    * `#local` sandbox channel (for limnoria / "supybot")

  * bitlbee
    * `&bitlbee` - connect using IM chat protocols


## Editing configuration files

The text editor `nano` is included for simple editing of configuration files. e.g. `nano /config/irssi/config`. Be careful to do that under the right unix user instead of `root`.

For example:

```sh
sudo su -l znc [return]
nano /config/znc/configs/znc.conf [return]

# or
sudo su -l irssi [return]
nano /config/irssi/config [return]
```

## Configuration

Pre-seeded Configuration Folder:

All configuration files are held in the working folder `/config`. There are different versions of the config folder. See [`config.default/README.md`](config.default/README.md) and [`config.custom/README.md`](config.custom/README.md) for more information about those.

### ssh

For ssh terminal access you can put your existing ssh public key (e.g. `id_rsa.pub`) into `/config/irssi/.ssh/known_hosts` file. Else a new keypair will be automatically generated per container on first run. And the resultant `id_rsa` private key file can be copied from `/config/irssi/.ssh/id_rsa` of your new running container's mounted `/config` volume.

### znc

Primarily you will want to change the znc admin username and password to something else more secure. And to be your own IRC nickname.

The znc server will be configurable from any standard web browser, available on SSL protocol `https://$your_container_ip:6697`. The default username and password for znc admin user is `znc:znc`. It is recommended to then goto manage users --> Duplicate the default `znc` user with your own IRC nick name.

The `znc.conf` text file can also be edited directly. It is stored in the usual loacation at `/config/znc/configs/znc.conf`

### weechat

Your irc login settings are held in the file `/config/weechat/irc.conf`. The password for glowing-bear web interface is held in `/config/weechat/relay.conf`.

### irssi

Assuming that you have changed the znc username and password, then you must also change those `/server` lines in the irssi config file. To use your new znc nick name and password. This file is located at `/config/irssi/config`.

### Notifications to your i-Devices, android, Desktop, etc.

The recommended notification system to use is znc's [`*push`] module](https://github.com/jreese/znc-push). Which you will need to configure for your target device. Unfortunately ATTO znc push only [supports 1 service at a time](https://github.com/jreese/znc-push/issues/162).

However both irssi and weechat are also kept running all of the time. So in addition to znv `*push`, you can also install any extra notifications addons / scripts for those programs as you wish. 

### IRC Data

Generated data gets written to thedocker volume `/irc`.

Note: An additional docker image, `dreamcat4/nginx` or `dreamcat4/samba` is also useful. To more easily access the contents of this `/irc` data folder on your LAN.

### Logs

By default all IRC channel logs are kept by ZNC and written to the `/irc/znc/logs` folder.

### URLs

The irssi `urlplot` script is pre-configured to write all posted urls to `/irc/irssi/urlplot` folder. In both HTML and CSV format. The generated HTML file can bookmarked in your local web browser for easy access.

There are also URL plugins for znc and weechat, however their generated 'text only' output is not as good as html files created by `urlplot`.

### Bitlbee

Tends to be configured interactively by commands to the `&bitlbee` control channel, all done while running irssi client. Or by hand-editing the config file at `/config/bitlbee/bitlbee.conf`.

### tmux

The config file is located at `/config/irssi/.tmux.conf` (for irssi), and `/config/weechat/.tmux.conf` (for weechat).

This default tmux config does not really need any specific per user configuration. Unless you want to customize the behaviour of tmux more to your liking. For example to hide the `tmux ...` line at the top of the screen, or change the key-bindings etc.

### Limnoria (aka supybot)

NOTE: YOU SHOULD CHANGE YOUR BOT'S NICK FROM `supybot` ---> `YOUR BOT`

* The config file is located at `/config/limnoria/supybot.conf`
* The default owner nickname of this bot is `znc_user`
* The default owner password for this bot is `supybot`
* Connects to the znc user named `supybot` with znc password `supybot` <-- CHANGE THIS IN YOUR ZNC CONFIG TOO
* This bot is pre-configured to only connect join the channel `#local` on your own private `ngircd` IRC server
* Public IRC networks are also pre-configured in `supybot.conf`. They are just all disabled by default except for ngircd

How to identify yourself to the bot as it's owner:

```
@list --unloaded
#. supybot# znc_user: Error: You don't have the owner capability. If you think that you should have this capability, be sure that you are identified before trying again. The 'whoami' command can tell you if you're identified.

@whoami
#. supybot# znc_user: I don't recognize you. You can message me either of these two commands: "user identify <username> <password>" to log in or "user register <username> <password>" to register.

/query supybot user identify znc_user supybot
-supybot(~supybot@localhost)- The operation succeeded.
```

You will need to change the owner in `supybot.conf` to your real nick, if you didnt already do so in the quickstart instructions. This involves stopping the container, and changing the owner name setting in the file `/config/limnoria/conf/users.conf`. Then restart the container.

Now we can login again, and change the owner password to something more secure than `supybot` before taking it online to public irc servers:

```
/query supybot user identify YOUR_IRC_NICKNAME supybot
-supybot(~supybot@localhost)- The operation succeeded.

/query supybot user set password supybot YOUR_NEW_BOT_OWNER_PASSWORD
-supybot(~supybot@localhost)- The operation succeeded.
```

**EXTRA NOTE:**

Going online to public servers with an IRC bot can be considered bad behaviour. Or suspicious due to botnets etc. So using a bot in the wrong way(s) can very quickly get you banned. Either from a specific channel, or IRC network, or even multiple IRC networks! Due to shared global blacklisting mechanisms. So be sure to check any relevant bot policies for those specific network(s) and channel(s) before taking your supybot online to any specific networks or channels. Check with a actual human being, and be asking for clarification / permission to do so where applicable.

### ngircd

Provides the `#local` channel. Which is where znc and the supybot are pre-configured to automatically join to. This is your playground to configure / use the bot before taking it online elsewhere.

* The config file is located at `/config/ngircd/ngircd.conf`
* This irc server is pre-configured to listen only on the localhost `127.0.0.1` network interface.
* Includes pairing passwords for the localhost `atheme` services daemon.

**NOTE:**

This IRC server is minimally configured. But should be safe to use for private localhost use only. To be taking this ngircd instnace public (exposing ports to outside). Then at very least you should change the atheme pairing passwords. In both ngircd config file and atheme's config file.

However its not recommended to use this single fat image for any public of semi-public hosting. As other IRC programs are running in the same image. For better hardening, use seperate sigle-service docker images, each linked together. For example 1 container for ngircd, 1 container for atheme services.

### atheme irc services

* The config file is located at `/config/atheme/atheme.conf`
* These servcies are only minimally configured (enough to work with the ngircd instance)
* The actual services offered (nickserv, chanserv, sasl, etc) are all left at defaults
* The pairing passwords (for connection to this IRC services daemon) are also configured in `ngircd.conf`

### Bitlbee chat protocols

Comes installed with all the necessary 3rd party plugins for all the most popular non-core protocols including WhatsApp, Steam Chat, Telegram, Facebook, Skype (via 'SkypeWeb') and so on.

So for any of the below links, you do not need to install any new pkgs / files, they should already be available inside of Bitlbee. Some IM procotols do requires a specifal setup instructions however. As can be read about in the following pages:

#### LibPurple

  * https://wiki.bitlbee.org/HowtoPurple

#### WhatsApp

  * https://wiki.bitlbee.org/HowtoWhatsapp

#### Skype

  * https://wiki.bitlbee.org/HowtoSkypeWeb

#### SIPE

  * https://wiki.bitlbee.org/HowtoSIPE

#### Facebook

  * https://wiki.bitlbee.org/HowtoFacebookMQTT

#### Steam Chat

  * https://github.com/jgeboski/bitlbee-steam

#### Telegram

  * https://github.com/majn/telegram-purple

#### Torchat

  * https://github.com/prof7bit/TorChat

#### Other chat protocols

**Protcol not listed in &bitlbee?**

Bitlbee's `help purple` command will list all of the available 3rd party plugins *which were installed via libpurple*. However certain other 'native' bitlbee plugins do not appear there. And are not listed elsewhere, eg in `help account add`. Yet they are in fact already installed and fully installed.

**How to check if a protocol is supported:**

To check that a specific protocol is supported, type `account add PROTOCOL username password`. If the answer isn't `unknown protocol`, then that IM protocol is indeed present and supported. For example:

```sh
&bitlbee:
11:44 <@znc_user> account add PROTOCOL username password
11:44 <....@root> Unknown protocol

11:44 <@znc_user> account add steam username password
11:44 <....@root> Account successfully added with tag steam

11:44 <@znc_user> account add facebook username password
11:44 <....@root> Account successfully added with tag facebook
```

**Missed Protocol:**

* tox-prpl - tox API Changed, plugin broken and needs updating
  * https://github.com/jin-eld/tox-prpl/issues/54

**Additional Protocols:**

https://developer.pidgin.im/wiki/ThirdPartyPlugins#AdditionalProtocols

## Connecting to the irssi session

From a remote machine:

Connect via ssh terminal session by logging in as the user `irssi`. For example: `ssh irssi@your_container_ip`. You must have a keyfile which is listed in the container's ssh `known_hosts` file.

From local machine (same docker host):

```sh
docker exec -it CONTAINER_NAME bash [return]
irssi [return]
```

## Disconnecting from an irssi session

In these cases, the irssi program and it's TMUX session will be kept running as normal:

* It is preferred to disconnect with the default TMUX keybinding of `Ctrl-B` then `d`.
* You may also disconnect by killing ssh window in your ssh client. Eg `ctrl+c`

In these cases, the irssi program will exit:

* Quit the irssi program and naturally end the tmux session with `/quit` in irssi
* Kill the irssi program and disconnect by killing the tmux session with `Ctrl-B` then `@`

However in these last 2 cases ^^ a new tmux session and instance of the irssi program will be re-launched within < 3 seconds. So in general your irssi client is always kept running. So long as its docker container is kept running.

The container's ZNC and Bitlbee servers are also kept running too. Like irssi, if they crash or are exited for any reason, then they will be automatically restarted within a few seconds.

## Per-user setup

1. Configure your znc user accounts - already done by following the 'quickstart' guide.
2. Setup nickserv / identify with services - See next sections below.

### ZNC user configuration

This is set your own IRC nickname. It was already covered in the 'quickstart' guide.

* Using a web browser connect to znc's web interface. It is available on HTTPS and port 6697: `https://CONTAINER_IP:6697`
* Log in to znc with username: `znc`, password: `znc`
* Go to "Manage users" page
* Click "Clone" for `znc` user
* Replace all instances of `znc` and `znc_user` (all the various different usernames) with your own IRC nickname, realname etc. 
* Set a new and more secure password for you to login to znc server with.
* Click "Clone and return" at the bottom of page.
* Make sure your new user account still has admin status, and logout / login with it.
* Now you can disable / delete the previous `znc` user account. To stop it trying to log into IRC servers. Or at least change it's password to something more secure.

After changing our username, we now need to also edit the other config files for our irc clients. For example at `/config/irssi/config`and so on. That was all explained in the quickstart section. You can do this inside the container with the cmd `nano /config/irssi/config`. Or from the host, looking inside the location of the mounted `/config` docker volume. Either way just make sure that the file's user ownership remains the same after editin. Which is the container's `irssi` unix user account. And file ownership is not changed to `root` user etc.

* In the irssi/config file, update the username and password login credentials on each server's `password = ` config line. To be the new login for your znc user account. There is only 1 znc user account. But there are multiple `password = ` declarations, one for each unique IRC service (Freenode, EFNet, etc).

Now restart the container with `docker restart` for changes to take effect. Irssi should now be trying to login under your own IRC nickname.

### Setting up nickserv on znc

These instructions explain how to register your nick with nickserv, and then to save that login credention into znc's `*nickserv` module. The proceedure is the the same here for all of the pre-configured networks listed here. Other networks may be slightly different (e.g. quackent undernet), where they may call nickserv service something else.

1. Be sure znc is already setup with your chosen / desired nickname for target server/network (eg freenode or whatever). And that znc has logged you into that server with the right nick you want to use.

2. Just browse onto any channel, which is on the same network where you want to setup nickserv services with. eg:

```
/join -[SERVER] [ANYCHANNEL] # switches you to the target SERVER in irssi
```

3. Open up a new window to the server's real nickserv service. And check you are logged on to the legitimate service:

```
/nickserv help
```

4. Register your nickname / password / email address

```
/nickserv register [YOUR PASSWORD] [YOUR EMAIL]
```

You nickname is implicit, as you are already logged in under your temporary nickname, the thing you wish to make permanment. Go through any extra steps (for example email confirmation etc). Your nickname should now be registered with YOUR PASSWORD.

5.  Open up another window, this time to the `*nickserv` znc module. Again while browsed onto the same target network. Eg:

```
/msg -freenode *nickserv help
```

6. Save your nickserv password into znc for this network:

```
/msg -freenode *nickserv set [YOUR PASSWORD]
```

^^ Notice the `*` at the front of `*nickserv` this time. Which means we are passing the SET message to znc's own local nickserv module. Once this step is done znv should automatically handle all future logging in / nickserv identification all for you.

ZNC Nickserv module documentation: http://wiki.znc.in/Nickserv

### Per-network Authentication methods

At a minimum you should authenticate your IRC username with nickserv on every network that supports it. In addition to that some fewer networks optionally support better authentication methanisms e.g. by SASL or SSL client certificate. At least SASL is very easy to setup.

#### &bitlbee

* register a new access password with the `register` command
  * navigate to the &bitlbee window and type `help register`

* then have znc login to the local bitlbee server with znc's 'perform' module
  * http://wiki.znc.in/Perform#Bitlbee

#### dalnet

* nickserv
  * Register with nickserv using the general method described ^^ earlier

More info: https://www.dal.net/services/servcmd.php?c=9

* then tell znc to log you with the following command for dalnet
  * http://wiki.znc.in/Nickserv#SetCommand

#### efnet

* none really, only 'ident'. which is hardly anything
  * Just be sure that your znc user's 'ident' field is set the same as your nickname

#### freenode

* nickserv
  * Register with nickserv using the general method described ^^ earlier

* sasl
  * https://web.archive.org/web/20150907063721/https://freenode.net/sasl/sasl-znc.shtml

#### gnome

* nickserv
  * Register with nickserv using the general method described ^^ earlier

Further info: https://wiki.gnome.org/Sysadmin/IRC#Registering_your_nickname

#### ircnet

* none really, only 'ident'. which is hardly anything
  * Just be sure that your znc user's 'ident' field is set the same as your nickname

#### mozilla

* nickserv
  * Register with nickserv using the general method described ^^ earlier

Further info: https://wiki.mozilla.org/IRC#Register_your_nickname

#### oftc

* nickserv
  * Register with nickserv using the general method described ^^ earlier

* SSL client certificate
  * http://www.oftc.net/NickServ/CertFP

Further info: http://www.oftc.net/Services/

#### quakenet

* the 'q' service bot
  * https://www.quakenet.org/help/q/how-to-register-an-account-with-q

* when you first run irssi, a `*q` window should appear, where you can specify to znc your quakenet account's username / password

* login with [znc's 'q' module](http://wiki.znc.in/Q) on quakenet config page of znc's webAdmin

#### undernet

* register a new account with undernet
  * https://cservice.undernet.org/live/newuser.php

* login to the 'x' service bot with znc's 'perform' module
  * http://wiki.znc.in/Perform#Identifying_to_services

Further info: http://help.undernet.org/faq.php?what=cservice#03

## Irssi Scripts

The latest irssi scripts are already downloaded into the container with `git`. In fact, every time irssi program is restarted, we run the following command automatically:

```sh
cd /scripts.irssi.org && git pull
```

So no need to worry about using script-assist to manage your scripts for you. There is no need for it. The local copy of the scripts repo always be kept fully up-to-date with every container restart. Or whenever you have manually `/quit` the irssi program.

Most scripts are symlinked from irssi's config folder, into the git repo:

To add a new script just create a symlink into your irssi scripts folder. For example:

```sh
ln -s /scripts.irssi.org/scripts/SCRIPTNAME.pl /config/irssi/scripts/autorun/
```

Linking into the `.../autorun/` subfolder makes the script load automatically on irssi startup. More information at:

https://scripts.irssi.org/

### Tweaked scripts

A few of the scripts had to be modified / tweaked in order to work. So those ones are not symlinks but copied files. Other scripts are not tweaked, but also copy files (not simplinks). Which did not exist at time of writing in irssi's official scripts repo.

### Not met script dependancies

All the included scripts were tested to work properly in the container. However you may want to add other scripts to your config later on. So why isn't / aren't my optional irssi script(s) working then?!!?

Well many optional irssi scripts also require their own specific dependancy(ies). Which are not necessarily come pre-installed. There are 2 kinds of dependancies: APT deps and perl deps.

For perl deps, you can look at the import / include lines  like `use Perlmodule::Name;` at the top of the script. Then use `cpanm Perlmodule::Name` to install them.

## File permissions

There is the main unix account `irssi`. However this container also has unix accounts named `bitlbee` `znc` and `eggdrop` for those other supportive services.

By specifying an alternative uid and gid as a number, this lets you control which folder(s) those specific services have read/write access to. For example, setting these daemons to your own local user account's UID will allow you to access these services IRC `/config` files from outside of the docker session and on the host machine.

The default `uid:gid` of these accounts is named after their TCP port number. Except eggdrop --> `3996`rop, which is leet for `eggd`. As is bitlbee's chosen numeric `6111` leet for `bitl`.

```sh
USER, UID, GID
irssi, 22, 22
znc, 6697, 6697
eggdrop, 3996, 3996
bitlbee, 6111, 6111
```

You can change the unix UIDs and/or GIDs to your liking by setting the following docker env vars:

```sh
irssi_uid=XXX
irssi_gid=YYY

znc_uid=XXX
znc_gid=YYY

eggdrop_uid=XXX
eggdrop_gid=YYY

bitlbee_uid=XXX
bitlbee_gid=YYY
```

## Docker Compose

Sorry there is no example for Docker Compose at this time. But you may do something similar:

```sh
crane.yml:

containers:

  irssi:
    image: dreamcat4/irssi
    run:
      net: none
      volume:
        - /path/to/my/irc/current.config:/config
        - /path/to/my/irc/logs:/logs
      env:
        - irssi_uid=65534
        - irssi_gid=65534
        - pipework_wait=eth0
        - pipework_cmd_eth0=eth0 -i eth0 @CONTAINER_NAME@ 192.168.1.17
      detach: true
```

The `pipework_` variables are used to setup networking with the `dreamcat4/pipework` helper image.


## Web-browser alternative

This is a decent free irc client, for web browser:

https://kiwiirc.com/client

Here is another one, however the free version has a few restrictions:

https://www.irccloud.com

