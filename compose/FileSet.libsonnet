local U = import "./utilities.libsonnet";

local File = import "./File.libsonnet";
local Service = import "./Service.libsonnet";

local compose_file( base_path, output, mixin, file_name = "docker-compose.yml" ) = (
    
    local left  = U.get( output, file_name, File.new( ) );
    local right = U.get( mixin, file_name, File.new( ) );

    { name : file_name, content : File.combine( left, right ) }

);

local override_file( base_path, output, mixin, file_name = "docker-compose.override.yml" ) = (
    
    local left  = U.get( output, file_name, File.new( ) );
    local right = U.get( mixin, file_name, File.new( ) );

    //
    // Make sure to prefix the bindings with the appropiate base_path as well. With this
    // override we know the volumes here _should_ only be the files specified in the #service( ... )
    // constructor.
    //
    local nested_service_volumes = U.setMap( 
        function( name, service )(

            local volumes = std.map( 
                function( volume )(

                         if std.isString( volume ) then volume
                    else if volume.type != "bind"  then volume
                    else                                volume + { source : base_path + volume.source }

                ),
                service.volumes
            );

            [ name, { volumes : volumes } ]
        ),
        right.services
    );

    local nested = std.mergePatch( right, { services : U.to_object( nested_service_volumes ) } );

    { name : file_name, content : File.combine( left,  nested ) }

);

local build_file( base_path, output, mixin, file_name = "docker-compose.build.yml" ) = (
    
    local left  = U.get( output, file_name, File.new( ) );
    local right = U.get( mixin, file_name, File.new( ) );

    local service_name = mixin.service_name;
    local service = right.services[ service_name ];

    { 
        name : file_name,
    
        content : File.new( [ left ],
            version = "3.8",
            services = {

                [ service_name ] : Service.new( [ service ],

                    build = {
                        context    : base_path + U.get( service.build, "context", "." ),
                        //dockerfile : base_path + U.get( service.build, "dockerfile", "Dockerfile" ),
                        target     : service_name
                    },

                )

            },

        )

    }

);

local merge_service_file_sets( kv, output ) = (

    local base_path = U.key( kv );

    output 
        + { [ base_path + "Dockerfile" ] : U.value( kv )[ "Dockerfile" ] }
        + {
            
            [ file.name ] : file.content for file in [

                compose_file( base_path, output, U.value( kv ) ),
                override_file( base_path, output, U.value( kv ) ),
                build_file( base_path, output, U.value( kv ) )

            ]
        }

);

{
    manifestFileSet :: function( file_set )(

        local serialize = function( key, value )(
            if std.isFunction( value ) then 
                
                "%s( ... )" % key 
            
            else if std.isString( value ) then 
            
                value

            else
            
                std.manifestJson( value )

        );

        local serialized = std.map(
            function( kv ) (
                local key = U.key( kv );
                local value = U.value( kv );  
                
                [ key, serialize( key, value ) ]
            ),
            U.entries( file_set )
        );

        U.to_object( serialized )
        
    ),

    from :: function( mapping )(

        std.foldr( 
            merge_service_file_sets,
            U.entries( mapping ),
            {
                "docker-compose.yml" : File.new( ),
                "docker-compose.override.yml" : File.new( ),
                "docker-compose.build.yml" : File.new( )
            }
        )

    ),

    new :: function(
        
        version = null,

        build    = File.new( version = version ),
        compose  = File.new( version = version ),
        override = File.new( version = version )

    )({

        "docker-compose.build.yml"    : build,
        "docker-compose.yml"          : compose,
        "docker-compose.override.yml" : override,

        service :: function( 
            service_name, image,
            name        = image,
            files       = { },
            service     = Service.new( ),
            development = Service.new( ),
            builder     = Service.new( ),
            dockerfile  = |||
                FROM %(image)s AS %(service_name)s
                %(files)s
            |||
        )( 

            local build = self[ "docker-compose.build.yml" ]
                .service( service_name, Service.new( [ builder ], 

                    container_name = "%s__builder" % service_name ,
                    image = "${REGISTRY:-docker.io/}%s/%s:%s" % name,
                    build = { context : "." },

                ));
                

            local compose = self[ "docker-compose.yml" ]
                .service( service_name, Service.new( [ service ], 
                
                    container_name = service_name,
                    image = "${REGISTRY:-docker.io/}%s/%s:%s" % name 
                    
                ));

            local override = self[ "docker-compose.override.yml" ]
                .service( service_name, Service.new( [ development ], 
            
                    volumes = U.setMap( Service.Volume.bind, files )

                ));

            { } + self + {
            
                service_name :: service_name,

                "docker-compose.build.yml"    : build,
                "docker-compose.yml"          : compose,
                "docker-compose.override.yml" : override,

                "Dockerfile" : dockerfile % {

                    service_name : service_name,

                    image : "%s/%s:%s" % image,
                    name  : "%s/%s:%s" % name,

                    files : std.lines(
                    
                        U.setMap( 
                            function( source, target ) "COPY %s %s" % [ source, target ],
                            files
                        )
                    
                    )

                }

            }

        )

    })

}