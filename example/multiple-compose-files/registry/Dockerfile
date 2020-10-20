FROM docker/compose:debian-1.27.4 as registry-builder

WORKDIR /tmp/context

CMD bash -xc '                                                                                          \
    export REGISTRY="localhost:5000/";                                                                  \
    export DOCKER_USERNAME=${DOCKER_USERNAME:--};                                                       \
    export DOCKER_PASSWORD=${DOCKER_PASSWORD:--};                                                       \
                                                                                                        \
    env BUILD_PHASE="pull-through" docker-compose --file ./registry.yml run                             \
        --service-ports --detach -T                                                                     \
        --name bootstrap-registry                                                                       \
        -e "REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io"                                      \
        bootstrap-registry ;                                                                            \
                                                                                                        \
    docker-compose build                                                                                \
        && docker stop bootstrap-registry                                                               \
        && docker commit bootstrap-registry bootstrap-registry:local-push                               \
        && docker rm bootstrap-registry ;                                                               \
                                                                                                        \
    env BUILD_PHASE="local-push" docker-compose --file ./registry.yml run                               \
        --service-ports --detach -T                                                                     \
        --name bootstrap-registry                                                                       \
        -e "REGISTRY_PROXY_REMOTEURL="                                                                  \
        bootstrap-registry ;                                                                            \
                                                                                                        \
    docker login --username "${DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}" "http://$REGISTRY"     \
        && docker-compose push ;                                                                        \
                                                                                                        \
    docker logout "http://$REGISTRY" ;                                                                  \
'

FROM registry:2.7.1 as docker-registry
FROM alpine:3.8 as bootstrap-registry

RUN set -ex \
    && apk add --no-cache ca-certificates apache2-utils 

COPY --from=docker-registry /bin/registry /bin/registry
COPY --from=docker-registry /entrypoint.sh /entrypoint.sh

COPY ./config.yml /etc/docker/registry/config.yml

EXPOSE 5000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/etc/docker/registry/config.yml" ]
