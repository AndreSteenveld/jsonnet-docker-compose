/*
pushgateway:
    image: prom/pushgateway:v1.2.0
    container_name: pushgateway
    restart: unless-stopped
    expose:
      - 9091
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"
*/

local C = import "../../compose.libsonnet";

local common = import "../common.libsonnet";
local ServiceFileSet = import "../ServiceFileSet.libsonnet";

ServiceFileSet
    .new(
        build    = common.file.build,
        compose  = common.file.compose,
        override = common.file.override
    )
    .service(

        "pushgateway",

        image = [ "prom", "pushgateway", "v1.2.0" ],
        name  = [ "dockprom", "pushgateway", "v1.2.0" ],

        files = { },

        service = C.Service.new( [ common.restart_policy, common.network, common.labels ],
        
            expose = [ 9091 ]

        )

    )
