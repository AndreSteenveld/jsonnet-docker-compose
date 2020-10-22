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
## Exporting the registry

```bash
# Assuming the registry was started with the previously mentioned command
$ docker container commit registry dockprom-registry:latest
$ docker image save dockprom-registry:latest --output ./dockprom-registry--latest.tar

docker container commit --change "ENV REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=//root" registry dockprom-registry:latest
```

```bash
# Restoring the registry from a tar file
$ docker image load --input ./dockprom-registry--latest.tar
```

## Building a registry directly from a dockerfile

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

> Big warning here, this is "proper" emphesis on the quoates. For this example to work without to much fussing around the bootstrap registry is still a unsecured registry. Although I think this setup is a good boilerplate to get started rolling your own registries, adding in some basic auth or a token mechanism is fairly straight forward to do. Depending on how you'd like to work with the registry this can also be done after populating it.

> There also seems to be no way around having `docker.io` as _the_ default registry, so to make this work all the images you want to push _must_ be retagged. This unfortunately means that a trivial workflow like: "logging in to your local registry and running a `docker-compose push`" will never work. To work around this the bootstrap-registry has been set up as a passthrough allowing the build to magically fetch everything from the local registry and push it back. Working around this by changing the resolve of `docker.io` looks like a minefield to me personally.

```bash
$ docker-compose --file ./registry.yml run --rm -e "COMPOSE_FILE=./docker-compose.build.yml" registry-builder

# Commit our registry to an image and export it to tar file.
$ docker commit bootstrap-registry dockprom/registry:latest \
    && docker image save dockprom/registry:latest --output ./dockprom-registry--latest.tar

# Cleaning up the images is a little fiddly at this point as the intermediate images (bootstrap-registry:*) can't
# be deleted before the final image is deleted (dockprom/registry:latest). As it has been exported to a file it
# should be fine.
```

# Links I found useful during the building of this example

* [Dockprom](https://github.com/stefanprodan/dockprom)
* [Self contained docker registry](https://gist.github.com/AndreSteenveld/2d11e9361baeb4d931fb5994fe5e0788)
* [Enable TCP port 2375 for external connections to Docker](https://gist.github.com/styblope/dc55e0ad2a9848f2cc3307d4819d819f)
* [Regression in docker login subcommand](https://github.com/docker/compose-cli/issues/712)

The `/etc/docker/daemon.json` I ended up with after getting everything up and running:

```json
{

    "dns" : [ "8.8.8.8", "1.1.1.1" ],
    "allow-nondistributable-artifacts": [
        "localhost:5000",
        "127.0.0.0/8"
    ],
    "insecure-registries": [
        "localhost:5000",
        "127.0.0.0/8"
    ],
    "registry-mirrors": [
        "http://localhost:5000"
    ],
    "hosts": [ "tcp://localhost:2375", "unix:///var/run/docker.sock" ]
}
```