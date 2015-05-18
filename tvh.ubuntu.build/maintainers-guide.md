## Builder Setup Guide

Apt package builders for tvheadend on ubuntu.

### For Tvheadend developers only

This guide is expressly for members of tvheadend project only. If you are not involved with officially distributing tvheadend software, there is no reason to go to this trouble of building apt packages of tvheadend. You should instead just download and enjoy the official pre-built tvheadend APT packages. Available from:

https://tvheadend.org/projects/tvheadend/wiki/AptRepository

It is not necessary, and a greate waste of resources to create duplicate additional server loads which build exaclty the same packages as are already being officially provided by the tvheadend project.

### Requirements

You will need:

* A Github Account (https://github.com/)
* A Bitbucket account (https://bitbucket.org/)
* A Docker Hub account (https://hub.docker.com/)
* A Bintray account (https://bintray.com/)
* A cron job to trigger builds with your docker hub API key*.

Note:

* User accounts should all be registered under your own regular username. e.g. `dreamcat4`, `negge`, `perexg`, `proyaffle`, etc.

* An understanding of Git and Docker will be needed for managing this build process.

* The cron job (last step) should be run from a secure computer that you yourself control. As it requires access to your docker hub API key in plain text. The cron job does not build anything locally. It just triggers the remote server(s) to start a new build run.

### Overview

The basic steps are as follows:

* Create public docker image of tvheadend's build dependancies (optional)
  * On Github
    * Create git repo of build files for the `tvh.ubuntu.build.deps` docker image
  * On Dockerhub
    * Create new public repo named `tvh.ubuntu.build.deps`
      * As automated build
      * Enter your Github Repo
      * Enter the folder path to `tvh.ubuntu.build/deps` subfolder.
      * Click the `Start Build` Button.

* On Bitbucket
  * Create private repo for docker private images
    * Copy `tvh.ubuntu.master` and `tvh.ubuntu.stable` build files into it


### Step 1 `tvh.ubuntu.build.deps`

This step is optional.

As things stand, we just use `FROM: dreamcat4/tvh.ubuntu.build.deps` as the firt line in your `Dockerfiles`. Which points to my own build of this image. We only need to update this base image's `Dockerfile` very infrequently. To modify the pkg list in order to add new build dependancies (e.g. newly added HdHomeRun support). Or to remove deprecated or broken ones (e.g. `libiconv`).

There are 2 choices:

* Option 1: Fork your own copy of `tvh.ubuntu.build.deps` files, modify it, and create your own public Docker hub automated build of `tvh.ubuntu.build.deps`. And setup a weekly or monthly cron job.

* Option 2: Open a new issue or submit a pull request to `dreamcat4/docker-images` asking for such modification to be merged on my original repo.

Here we document the Option 1:

* Login to Github
  * Fork the build files of the `tvh.ubuntu.build.deps` docker image
    * Go to https://github.com/dreamcat4/docker-images and click the 'Fork' button.

* Login to Dockerhub
  * Create new public repo named `tvh.ubuntu.build.deps`
    * As an automated build

![Dockerhub - Add Repository - Automated Build](_img/dh-add-repo-auto-build.png)

* Selected the forked Github Repo where `tvh.ubuntu.build/deps/Dockerfile` now exists. e.g. `yourGithubUsername/docker-images`

![Dockerhub - Automated Build - Select Github Repo](_img/dh-ab-select-github-repo.png)

* Enter the folder path to `tvh.ubuntu.build/deps` subfolder.
* Click the `Start Build` Button.




##### Schedule a regular rebuild

We do not need to rebuild the apt dependancies as often as tvheadend itself. Just once in a while, for example if ffmpeg gets updated etc. I recommend a once-weekly or once-monthly build trigger.


