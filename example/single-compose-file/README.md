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

