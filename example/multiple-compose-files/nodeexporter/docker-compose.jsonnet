local C = import "../../../compose.libsonnet";
local common = import "../common.libsonnet";

C.FileSet
    .new(
        build    = common.file.build,
        compose  = common.file.compose,
        override = common.file.override
    )
    .service(

        "nodeexporter",

        image = [ "prom", "node-exporter", "v1.0.1" ],
        name  = [ "dockprom", "node-exporter", "v1.0.1" ],

        files = { },

        service = C.Service.new( [ common.restart_policy, common.networks, common.labels ],
        
            volumes = [
                C.Service.Volume.bind( "/proc", "/host/proc" ),
                C.Service.Volume.bind( "/sys", "/host/sys" ),
                C.Service.Volume.bind( "/", "/rootfs" )
            ],

            command = [
                "--path.procfs=/host/proc",
                "--path.rootfs=/rootfs",
                "--path.sysfs=/host/sys",
                "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)"
            ],

            expose = [ 9100 ]

        )

    )
