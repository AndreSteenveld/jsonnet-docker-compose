local C = import "../../compose.libsonnet";

local logging = C.Service.new(

    logging = C.Service.Logging.new(
     
        driver  = "syslog",
        options = {
            
            "syslog-address" : "udp://logs.papertrailapp.com:50183",
            "tag"            : "{{.Name}}"

        }

    )

);

C.File.new(

    version = "3.8",

    volumes = {

        "pgdata" : C.Volume.new( ),
        "django-static-files" : C.Volume.new( ),
        "react-static-files" : C.Volume.new( ),
    
    },

    services = { 

        "nginx" : C.Service.new( [ logging ], 
        
            image   = "recipeyak/nginx:latest",
            ports   = [ "80:80" ],
            volumes = [

                C.Service.Volume.mount( "react-static-files", "/var/app/dist" ),
                C.Service.Volume.mount( "django-static-files", "/var/app/django/static" )

            ],

            depends_on = C.Service.depends_on([ "django", "react" ])
        
        ),

        "db" : C.Service.new( [ logging ],

            image   = "postgres:10.1",
            ports   = [ "5432:5432" ],
            volumes = [

                C.Service.Volume.mount( "pgdata", "/var/lib/postgresql/data/" )

            ],

            command =  
                [ "-c" , "shared_preload_libraries=\"pg_stat_statements\""
                , "-c" , "pg_stat_statements.max=10000"
                , "-c" , "pg_stat_statements.track=all"
                ]

        ),

        "react" : C.Service.new( [ logging ], 

            image    = "recipeyak/react:latest",
            env_file = [ ".env-production" ],
            volumes  = [

                C.Service.Volume.mount( "react-static-files", "/var/app/dist" )

            ],

            command = [ "sh bootstrap.sh" ]

        ),

        "django" : C.Service.new( [ logging ],

            image    = "recipeyak/django:latest",
            env_file = [ ".env-production" ],
            command  = [ "sh bootstrap-prod.sh" ],
            volumes  = [

                C.Service.Volume.mount( "django-static-files", "/var/app/static-files" )

            ],

            depends_on = C.Service.depends_on([ "db" ]),
            restart = "always"

        )

    },

)
