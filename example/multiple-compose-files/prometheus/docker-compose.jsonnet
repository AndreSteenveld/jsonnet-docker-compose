local C = import "../../../compose.libsonnet";
local common = import "../common.libsonnet";
local FileSet = import "../FileSet.libsonnet";

FileSet
    .new(
        build    = common.file.build,
        compose  = common.file.compose.volume( "prometheus_data" ),
        override = common.file.override
    )
    .service(

        "prometheus",

        image = [ "prom", "prometheus", "v2.21.0" ],
        name  = [ "dockprom", "prometheus", "v2.21.0" ],

        files = { "./prometheus" : "/etc/prometheus" },

        service = C.Service.new( [ common.restart_policy, common.networks, common.labels ],
        
            volumes = [

                C.Service.Volume.mount( "prometheus_data", "/prometheus" ),

            ],

            command = [
                "--config.file=/etc/prometheus/prometheus.yml",
                "--storage.tsdb.path=/prometheus",
                "--web.console.libraries=/etc/prometheus/console_libraries",
                "--web.console.templates=/etc/prometheus/consoles",
                "--storage.tsdb.retention.time=200h",
                "--web.enable-lifecycle"
            ],

            expose = [ 9090 ]

        )

    )
