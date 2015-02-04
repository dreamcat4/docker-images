## Pipework

A docker image for [jpetazzo/pipework](https://github.com/jpetazzo/pipework). So that you can now run pipework as a docker container.

This method allows us to specify an environment variable `pipework_cmd=` for each container to give it an external IP address, or DHCP lease etc. See [Usage](#usage) for more information.

### Status

DOES NOT WORK (YET):

Finding app containers by linking them to the pipework container. Because the combination of `--net=host` and `--link ...` cannot be specified together. Docker does not support such a combination of options. And perhaps never will.

Which means that both Crane and Fig don't work yet...

### Miniumum Requirements

* Docker 1.5

To run in a container, the pipework command needs to see the host pid namespace. Which requires the `--pid` flag be implemented in docker and hence `docker-lxc-1.5.0`.

* Crane

You can run pipework in [Crane](https://github.com/michaelsauter/crane). Providing you have installed both `lxc-docker-1.5.0`, and have also have a recent build of crane which includes [crane PR #144](https://github.com/michaelsauter/crane/pull/144).

See [Installing pre-release dependancies](#installing_deps), for how to download them / get them.

* This image also needs to be run with `--privileged` mode (or else `--cap-add` modes). So that pipework can access host networking stack, modify other containers, etc. It has been tested on ubuntu-14.10 host. 

### What's not ready yet

* Pipework does not work in fig yet. The `--pid` option needs to be implemented in the docker python API first, and can be subsequently added to fig also.

[docker-py issue 471](https://github.com/docker/docker-py/issues/471)

* As we cannot use docker links. Then instead we must come up with a different approach. We need to loop around and wait for docker start events. When an event is catched, the container must be inspected for it's `pipework_cmd=` and then the pipework script should be launched at that time.

<a name="usage"/>
### Usage

#### Environment variables

On the pipework container, you can set the following environment variables:

Not implemented yet.

#### Cmd line (single usage / single invocation)

Works.

Full documentation on the pipework script can be found at [jpetazzo/pipework](https://github.com/jpetazzo/pipework).

Cmdline Usage (docker run):

    docker run -v /var/run/docker.sock:/docker.sock --pid=host --net=host --privileged=true dreamcat4/pipework --help

#### Fig / Docker Compose

Does not work yet.

To see how to use pipework in fig, take a look at the file [example-fig.yml](https://github.com/dreamcat4/pipework/blob/master/example-fig.yml).

* Start the master pipework container with `-e daemon=true` on the command line. Do this before `fig up`.

* Set the environment variable `pipework_cmd=` on each app container which you need to pipework to be run for.

#### Crane

Does not work yet.

To see how to use pipework in crane, take a look at the file [example-crane.yml](https://github.com/dreamcat4/pipework/blob/master/example-crane.yml).

<a name="install_deps"/>
### Installing pre-release dependancies

* Until docker-1.5 is officially released, it can be installed from docker's ubuntu testing repo with the following commands:

	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 740B314AE3941731B942C66ADF4FD13717AAD7D6
	sudo add-apt-repository -y "deb https://test.docker.com/ubuntu docker main"
	sudo apt-get install lxc-docker

* You will need to build a master (head) version of crane, until [crane PR #144](https://github.com/michaelsauter/crane/pull/144) gets released in binary form. You can build a local copy of crane by running the following commands:

	# Set up your go environment. You should want to add `GOPATH` and `GOBIN` to your `.profile`
	sudo apt-get install gccgo-go
	[ "$GOPATH" ] || export GOPATH=$HOME/go   && mkkdir -p $GOPATH
	[ "$GOBIN" ]  || export GOBIN=$GOPATH/bin && mkkdir -p $GOBIN && export PATH="$GOBIN:$PATH"

	# Build crane and install the `crane` binary into `GOBIN`
	cd $GOPATH && mkdir -p src/github.com/michaelsauter
	cd src/github.com/michaelsauter
	git clone https://github.com/michaelsauter/crane.git
	cd crane && go get

#### Other notes

* The `--cap-add=` flag will be available in Fig 1.1.0- [pull 623](https://github.com/docker/fig/pull/623) (merged).

* Specifying each capabilities individually with `--cap-add=` may avoid some of `--privileged`. But it messier on the command line. Not sure precisely which ones are required for pipework.

### If --pid flag is not enabled

If you try to run pipework cmd without `--pid` flag, pipework will exit with the following error msg:

    RTNETLINK answers: No such process

