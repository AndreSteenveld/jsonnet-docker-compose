# syntax = docker/dockerfile:experimental

#
# A self contained docker registry
#
# Why? - I needed a way to transport multiple images and some tooling between different machines 
# which would all have a docker daemon running on them. Packaging everything in to a single
# registry gives me a convinent package while also minimising my interactions with the target machine.
#
# How? - In a nutshell what is happening is that we start with a bootstrap registry in which we will
# push all the images we would like to retain. This is done using docker-compose as it is an convient
# way of working with multiple containers/images. With all the images pushed we copy everything over
# from out bootstrapped image to our actual registry.
#
# There is a caveat though, to make this work the container needs access to a docker daemon. The easiest
# way of doing this is exposing the daemon you already have to the local host. This can be done by
# configuring the deamon to bind to the localhost as well as well as the file system. How to do this is
# described in this gist: https://gist.github.com/styblope/dc55e0ad2a9848f2cc3307d4819d819f
#
# Although I am convinced this would also be possible via ssh I personally haven't explored that path yet.
# It is not possible (or I couldn't find anything relevant) to do this using the --volume flag as docker
# needs to be available during the build and not during the run.
#
# These examples are from https://github.com/AndreSteenveld/jsonnet-docker-compose/tree/develop/example/multiple-compose-files
#
#    (
#        export DOCKER_BUILDKIT=true;
#        export COMPOSE_FILE="./docker-compose.build.yml";
#        export DOCKER_TAG="dockprom/registry:latest";
#
#        envsubst < ./registry.dockerfile       \
#            | docker build                     \
#                --rm --network host --file -   \
#                --tag "$DOCKER_TAG"            \
#                .                              \
#            && docker image save $DOCKER_TAG --output ./dockprom-registry--latest.tar
#    )
#
# License? - "Self contained docker registry" by Andre Steenveld is licensed under CC0 1.0. 
# To view a copy of this license, visit https://creativecommons.org/publicdomain/zero/1.0 
#
# https://gist.github.com/AndreSteenveld/2d11e9361baeb4d931fb5994fe5e0788
#
# But do feel free to give me or this gist a shout-out :)
#

FROM docker/compose:1.27.4 as docker-compose

FROM registry:2.7.1 as bootstrap-registry

COPY --from=docker-compose /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker-compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose

ARG COMPOSE_FILE="$COMPOSE_FILE"
ENV COMPOSE_FILE="${COMPOSE_FILE:-}"

ENV DOCKER_HOST=http://localhost:2375
ENV REPOSITORY=localhost:5000/

ENV REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/tmp/registry

RUN mkdir -p /tmp/context /tmp/registry

WORKDIR /tmp/context

RUN --mount=target=/tmp/context,type=bind,source=/ \
    (&>/dev/null registry serve /etc/docker/registry/config.yml &) ; \
    docker-compose build && docker-compose push

#
# This image is clearly based on the orginal registry which can be found here:
#   https://github.com/docker/distribution-library-image/blob/registry-2.7.1/amd64/Dockerfile
#
FROM alpine:3.8

RUN set -ex && apk add --no-cache ca-certificates apache2-utils

COPY --from=bootstrap-registry /bin/registry /bin/registry
COPY --from=bootstrap-registry /etc/docker/registry/config.yml /etc/docker/registry/config.yml
COPY --from=bootstrap-registry /entrypoint.sh /entrypoint.sh
COPY --from=bootstrap-registry /tmp/registry /var/lib/registry

EXPOSE 5000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/etc/docker/registry/config.yml" ]
