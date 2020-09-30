# Simple docker-compose file

The docker-compose file specified in the jsonnet file is taken from a similar project (https://github.com/sbdchd/dhall-docker-compose) and adapted to jsonnet. 

To generate the docker-compose file run:

```bash
$ jsonnet --output-file ./docker-compose.yaml ./docker-compose.jsonnet
```

To validate that docker-compose understands the output run:

```bash
$ docker-compose config
```

To create a neatly formatted yaml file run the output from jsonnet through docker-compose.

```bash
$ jsonnet ./docker-compose.jsonnet | docker-compose --file - config > ./docker-compose.yaml
```

