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

        "cadvisor",

        image = [ "gcr.io", "cadvisor/cadvisor", "v0.37.0" ],
        name  = [ "dockprom", "cadvisor", "v0.37.0" ],

        files = { },

        service = C.Service.new( [ common.restart_policy, common.networks, common.labels ],
        
            volumes = [
                C.Service.Volume.bind( "/", "/rootfs" ),
                C.Service.Volume.bind( "/var/run", "/var/run" ),
                C.Service.Volume.bind( "/sys", "/sys" ),
                C.Service.Volume.bind( "/var/lib/docker", "/var/lib/docker" )
                // Doesn't work on MacOS only for Linux
                // C.Service.Volume.bind( "/cgroup", "/cgroup" ),
            ],

            ports = C.Service.ports.mappings({
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
