local ServiceFileSet = import "./ServiceFileSet.libsonnet";

local file_set = ServiceFileSet.from({

    // Jsonnet doesn't allow computed import statements, so this is the one place where
    // we will just have to bang out some of the paths.
    "./alertmanager/" : import "./alertmanager/docker-compose.jsonnet",
    // "./caddy/"        : import "./caddy/docker-compose.jsonnet",
    // "./cadvisor/"     : import "./cadvisor/docker-compose.jsonnet",
    // "./grafana/"      : import "./grafana/docker-compose.jsonnet",
    // "./nodeexporter/" : import "./nodeexporter/docker-compose.jsonnet",
    // "./prometheus/"   : import "./prometheus/docker-compose.jsonnet",
    // "./pushgateway/"  : import "./pushgateway/docker-compose.jsonnet"

});

ServiceFileSet.manifestFileSet( file_set )
