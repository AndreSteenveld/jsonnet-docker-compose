local C = import "../../compose.libsonnet";

local logging = C.Service + {

    logging ::: C.Service.logging({
     
        driver  : "syslog",
        options ::: C.Service.Logging.options({
            
            "syslog-address" : "udp://logs.papertrailapp.com:50183",
            "tag"            : "{{.Name}}"

        })

    })

};

local docker_compose = C.File + {

    version : "3.8",

    volumes ::: C.File.volumes({

        "pgdata" : C.Volume + { },
        "django-static-files" : C.Volume + { },
        "react-static-files" : C.Volume + { },
    
    }),

    services ::: C.File.services({ 

        "nginx" : C.Service.mixin( [ logging ], {
        
            image   : "recipeyak/nginx:latest",
            ports   ::: C.Service.ports.mapping([ "80:80" ]),
            volumes ::: C.Service.volumes([

                C.Service.Volume.mount( "react-static-files", "/var/app/dist" ),
                C.Service.Volume.mount( "django-static-files", "/var/app/django/static" )

            ]),

            depends_on ::: C.Service.depends_on([ "django", "react" ])
        
        }),

        db : C.Service.mixin( [ logging ], {

            image   : "postgres:10.1",
            ports   ::: C.Service.ports.mapping([ "5432:5432" ]),
            volumes ::: C.Service.volumes([

                C.Service.Volume.mount( "pgdata", "/var/lib/postgresql/data/" )

            ]),

            command :  
                [ "-c" , "shared_preload_libraries=\"pg_stat_statements\""
                , "-c" , "pg_stat_statements.max=10000"
                , "-c" , "pg_stat_statements.track=all"
                ]

        }),

        react : C.Service.mixin( [ logging ], {

            image    : "recipeyak/react:latest",
            env_file : [ ".env-production" ],
            volumes  ::: C.Service.volumes([

                C.Service.Volume.mount( "react-static-files", "/var/app/dist" )

            ]),

            command : [ "sh bootstrap.sh" ]

        }),

        django : C.Service.mixin( [ logging ], {

            image    : "recipeyak/django:latest",
            env_file : [ ".env-production" ],
            command  : [ "sh bootstrap-prod.sh" ],
            volumes  ::: C.Service.volumes([

                C.Service.Volume.mount( "django-static-files", "/var/app/static-files" )

            ]),

            depends_on ::: C.Service.depends_on([ "db" ]),
            restart : "always"

        })

    }),

};

// Although it is possible to output the resulting object as a yaml document
// the YAML documents generated by jsonnet don't really "look" good to start
// with AND it seems to be outputed as a escaped double quoted string. I am
// not sure why but the lowest hanging fruit for now just seems to be to just
// output the JSON and feed that to docker compose.
//
// std.manifestYamlDoc( docker_compose )
//
//
// std.manifestJson( docker_compose )
//
// Scratch all of that, it seems that the std.manifest*(...) functions just
// generate a string and output that quotes and all. This is to much of a
// hassle to deal with if you ask me. Just output the document...
//

docker_compose
