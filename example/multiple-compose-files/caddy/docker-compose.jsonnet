local C = import "../../compose.libsonnet";

local common = import "../common.libsonnet";
local FileSet = import "../FileSet.libsonnet";

FileSet
    .new(
        build    = common.file.build,
        compose  = common.file.compose,
        override = common.file.override
    )
    .service(

        "caddy",

        image = [ "stefanprodan", "caddy", "latest" ],
        name  = [ "dockprom", "caddy", "latest" ],

        files = {
            "./caddy" : "/etc/caddy"
        },

        service = C.Service.new( [ common.restart_policy, common.network, common.labels ],
        
            ports = C.Service.ports.mapping({
                "3000" : "3000",
                "9090" : "9090",
                "9093" : "9093",
                "9091" : "9091"
            }),

            environment = {
                "ADMIN_USER" : "${ADMIN_USER:-admin}",
                "ADMIN_PASSWORD" : "${ADMIN_PASSWORD:-admin}"
            },

        )

    )
