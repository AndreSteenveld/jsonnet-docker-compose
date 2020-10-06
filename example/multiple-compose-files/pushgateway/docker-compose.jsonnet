local C = import "../../../compose.libsonnet";
local common = import "../common.libsonnet";
local FileSet = import "../FileSet.libsonnet";

FileSet
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

        service = C.Service.new( [ common.restart_policy, common.networks, common.labels ],
        
            expose = [ 9091 ]

        )

    )
