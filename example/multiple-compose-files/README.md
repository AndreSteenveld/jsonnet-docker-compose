# Outputting multiple docker-compose files

Sometimes we want to output multiple docker-compose files, for example when generating a single docker-compose.yml and a docker-compose.override.yml file. This example is based on (dockprom)[] and we'll generate a separate "build", "runtime" and "development" docker-compose file.

# Running the example

```bash
$ jsonnet --string --multi . ./docker-compose.jsonnet
```

# Building a quick and dirty registry

When all the files, images and other artifacts are built these can be redistributed published to a repository. This example creates a local repository and exports it for air-gapped deployments.

```bash
# Make sure you have repository container running (Taken from the registry docs at: https://docs.docker.com/registry/deploying/)
$ docker run            \
    --name registry     \
    --publish 5000:5000 \
    --env "REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=//root" registry:2

# Build and push to repository 
$ env REGISTRY="localhost:5000/" docker-compose --file ./docker-compose.build.yml build
$ env REGISTRY="localhost:5000/" docker-compose --file ./docker-compose.build.yml push
```

Now that the everything has been pushed to the repository we can export create an image of the repository and export it.

```bash
# The ENTRYPOINT and CMD were taken from copied from the registry dockerfile: 
#     https://github.com/docker/distribution-library-image/blob/ab00e8dae12d4515ed259015eab771ec92e92dd4/amd64/Dockerfile
$ docker commit                                                     \
    --change 'ENV REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=//root' \
    --change 'ENTRYPOINT ["/entrypoint.sh"]'                        \
    --change 'CMD ["/etc/docker/registry/config.yml"]'              \
    registry dockprom/registry:latest

# Save our new repo to a tar file
docker image save dockprom/registry:latest --output ./dockprom-registry--latest.tar
```

To validate that this actually worked we can clean our docker host of all containers, images and other things and re-import our repository from the tar archive.

```bash
# Feel free to do something less drastic...
$ docker system prune --all --volumes --force

# Import the repository from the tar file
$ docker image load --input ./dockprom-registry--latest.tar

# Now we've imported our image listing the available images should look something like this;
$ docker image ls --filter=reference="dockprom/*"
```

With our repository image available on our docker host we can proceed with pulling and running the images.

```bash
# Run our registry locally
$ docker run                 \
    --detach                 \
    --name registry          \
    --publish 5000:5000      \
    dockprom/registry

$ env REGISTRY="localhost:5000/" docker-compose pull

# Now that we have all our images available we can stop the registry and proceed with running our stack
$ docker kill registry
$ env REGISTRY="localhost:5000/" docker-compose up
```

The images we've pulled from the repository are tagged with the repository URL prefixed to them. If when running something in a development setup we oftern won't push to a repository so the `REGISTRY` enviroment variable can be omitted. If you'd want to re-tag the images so they are available without the repository URL you could run:

```bash
$ ( 
    export REGISTRY="localhost:5000/";
    docker image ls \
        --filter=reference="${REGISTRY}dockprom/*" \
        --format "docker image tag {{.ID}} {{.Repository}}:{{.Tag}}" \
    | sed "s|${REGISTRY}||" \
    | xargs --replace='{}' bash -xc '{}'
)
```
## Exporting the repository

```bash
# Assuming the registry was started with the previously mentioned command
$ docker container commit registry dockprom-registry:latest
$ docker image save dockprom-registry:latest --output ./dockprom-registry--latest.tar

docker container commit --change "ENV REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=//root" registry dockprom-registry:latest
```

```bash
# Restoring the registry from a tar file
$ docker image load --input ./dockprom-registryt--latest.tar
```

## Building a repository directly from a dockerfile

To be honest this was more an experiment than anything else, but it is possible to build a registry image with the images you need from a plain docker file. The command below only works if the docker daemon is exposed on the host machine which isn't great for a production setup either. Although I haven't tested this I guess it would also be possible to mount the docker socket in to the intermediate container as well, and/or share a ssh-key to access the docker daemon over ssh.

```bash
$ (
    export DOCKER_BUILDKIT=true;
    export COMPOSE_FILE="./docker-compose.build.yml";
    export DOCKER_TAG="dockprom/registry:latest";

    envsubst < ./registry.dockerfile       \
        | docker build                     \
            --rm --network host --file -   \
            --tag "$DOCKER_TAG"            \
            .                              \
        && docker image save $DOCKER_TAG --output ./dockprom-registry--latest.tar
)
```

# Building our own "proper" registry

Although creating a quick and dirty registry will do in a pinch it requires that the image attributes in the docker-compose file are prefixed with the registry we want to push the images to. Although this works for this example it might not be what you'd really want for a real world situation. To create something more like what you'd do in the real world we're going to build our own registry from scratch and populate it with the necessary images.

> Keep in mind that the security mechanism here is `silly`, which is not secure. The lowest hanging fruit security mechanism (I think) here would be `htpasswd` as this is still completely self contained but does require the end-user to know a username/password combination before pulling all the images.


```bash
$ docker-compose --file ./docker-compose.build.yml build
$ docker-compose --file ./docker-compose.registry.yml up

$ docker login localhost.:5000                                  \
    && docker-compose --file ./docker-compose.build.yml push    \
    ; docker logout localhost.:5000 

$ docker commit bootstrap-registry dockprom/registry:latest \
    && docker image save dockprom/registry:latest --output ./dockprom-registry--latest.tar

$ docker-compose --file ./docker-compose.registry.yml down

```