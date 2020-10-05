/*
alertmanager:
    image: prom/alertmanager:v0.21.0
    container_name: alertmanager
    volumes:
      - ./alertmanager:/etc/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
      - '--storage.path=/alertmanager'
    restart: unless-stopped
    expose:
      - 9093
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

*/

local C = import "../../../compose.libsonnet";

local common = import "../common.libsonnet";
local ServiceFileSet = import "../ServiceFileSet.libsonnet";

ServiceFileSet.new( 
    
    "alertmanager", 
    
    image = [ "prom", "alertmanager", "v0.21.0" ],
    name  = [ "dockprom", "alertmanager", "0.21.0" ],
    
    files = {
        "./alertmanager" : "/etc/alertmanager"
    },
    
    service = C.Service.new( [ common.restart_policy, common.networks, common.labels ], 
    
        command = [
            "--config.file=/etc/alertmanager/config.yml",
            "--storage.path=/alertmanager"
        ],

        expose = [ 9093 ]
    
    )

)

/*

local build = C.Service.new( [ ], 

    image = "dockprom/prometheus:v0.21.0",
    build = {

    },

);

local dockerfile = "";

local development = C.Service.new( [ ], 

    volumes = [ ],

);

local service = C.Service.new( [ common.restart_policy, common.networks, common.labels ], 
    container_name = "alertmanager",
    command = [
        "--config.file=/etc/alertmanager/config.yml",
        "--storage.path=/alertmanager"
    ],
    expose = [ 9093 ]
);

{
    "./docker-compose.yml"          : C.File.new([ common.file.compose ]),
    "./docker-compose.override.yml" : C.File.new([ common.file.development ])
    "./docker-compose.build.yml"    : build,
    "./Dockerfile" : |||

        # This is where the dockerfile goes

    |||

},
*/