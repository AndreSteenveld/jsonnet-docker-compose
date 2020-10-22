local C = import "../../../compose.libsonnet";
local common = import "../common.libsonnet";

C.FileSet
    .new( 
        build    = common.file.build,
        compose  = common.file.compose,
        override = common.file.override
     )
    .service(
        
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