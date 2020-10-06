local C = import "../../../compose.libsonnet";
local common = import "../common.libsonnet";
local FileSet = import "../FileSet.libsonnet";

FileSet
    .new(
        build    = common.file.build,
        // Although this works I am not really sold on it, it feels a lot like "Ah just set a global varible, it will 
        // be fine". On the otherhand I don't really have any real alternatives on hand how to do this any cleaner.
        // And then there is the other part of networks, the current "monitor-net" is mixed in to the service but not
        // gloablly defined, it feels disjoint.
        compose  = common.file.compose.volume( "grafana_data" ),
        override = common.file.override
    )
    .service(

        "grafana",

        image = [ "grafana", "grafana", "7.2.0" ],
        name  = [ "dockprom", "grafana", "7.2.0" ],

        files = { 

            "./grafana/provisioning" : "/etc/grafana/provisioning"

        },

        service = C.Service.new( [ common.restart_policy, common.networks, common.labels ],
        
            expose = [ "3000" ],

            volumes = [
              
                C.Service.Volume.mount( "grafana_data", "/var/lib/grafana" )

            ],

            environment = {
                "GF_SECURITY_ADMIN_USER" : "${ADMIN_USER:-admin}",
                "GF_SECURITY_ADMIN_PASSWORD" : "${ADMIN_PASSWORD:-admin}",
                "GF_USERS_ALLOW_SIGN_UP" : "false",
            },

        )

    )
