# Outputting multiple docker-compose files

Sometimes we want to output multiple docker-compose files, for example when generating a single docker-compose.yml and a docker-compose.override.yml file. This example is based on (dockprom)[] and we'll generate a separate "build", "runtime" and "development" docker-compose file.

# Running the example

```bash
$ jsonnet --string --multi . ./docker-compose.jsonnet

# 
```