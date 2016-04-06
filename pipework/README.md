
## Docker-Pipework
**_A docker image of jpetazzo's pipework_**

![dependencies docker-1.6.0](https://img.shields.io/badge/dependencies-docker--1.6.0-green.svg)

![dependencies docker-compose-1.3.0](https://img.shields.io/badge/dependencies-docker--compose--1.3.0-green.svg)

For documentation ---> [here](https://github.com/dreamcat4/docker-images/blob/master/pipework/0.%20Introduction.md).

Page on DockerHub ---> [here](https://registry.hub.docker.com/u/dreamcat4/pipework/).

For older [Docker v1.7.1 compatibility](https://github.com/dreamcat4/docker-images/issues/19), please use Larry's fork over here ---> [larrycai/pipework:1.7.1](https://hub.docker.com/r/larrycai/pipework/tags/).

### Status

This project is now somewhat deprecated, in favor of newer L2 networking features of docker v1.10.x. Basically if you want L2 Bridge networking (like VMWare 'Bridged' networking mode), then it can be achieved with core docker features instead now. And that is better ways, less buggy.

There are also other new networking features since docker v1.10.x, which replace other parts of the pipework feature set.

Otherwise if you need some more specialized networking setups which still cant be achieved with newer Docker networking API, maybe continue to use pipework and its features. In which case, this docker image is in need of new maintainer, to continue forwards. As have already stopped using it myself.

### Requirements

* Requires Docker 1.8.1
* Requires Docker Compose 1.3.0
* Needs to be run in privileged mode etc.

### Credit

* [Pipework](https://github.com/jpetazzo/pipework) - Jerome Petazzoni
* Inspiration for the `host_routes` feature came from [this Article](http://blog.oddbit.com/2014/08/11/four-ways-to-connect-a-docker/), by Lars Kellogg-Stedman
* [This Docker Image](https://github.com/dreamcat4/docker-images/tree/master/pipework), a wrapper for Pipework - Dreamcat4
