//
// This file feels like it should be part of the general "jsonnet-docker-compose" source and not
// specific to this example. Move it after the example is done?
//
local C = import "../../compose.libsonnet";
local U = import "../../compose/utilities.libsonnet";

local compose_file( base_path, output, mixin, file_name = "docker-compose.yml" ) = (
    
    local left  = U.get( output, file_name, C.File.new( ) );
    local right = U.get( mixin, file_name, C.File.new( ) );

    { name : file_name, content : C.File.combine( left, right ) }

);

local override_file( base_path, output, mixin, file_name = "docker-compose.override.yml" ) = (
    
    local left  = U.get( output, file_name, C.File.new( ) );
    local right = U.get( mixin, file_name, C.File.new( ) );

    //
    // Patchup the file path so the source points to the correct base path
    //

    { name : file_name, content : C.File.combine( left,  right ) }

);

local build_file( base_path, output, mixin, file_name = "docker-compose.build.yml" ) = (
    
    local left  = U.get( output, file_name, C.File.new( ) );
    local right = U.get( mixin, file_name, C.File.new( ) );

    local service_name = mixin.service_name;
    local service = right.services[ service_name ];

    { 
        name : file_name,
    
        content : C.File.new( [ left ],
            version = "3.8",
            services = {

                [ service_name ] : C.Service.new( [ service ],

                    build = {
                        context    : base_path + U.get( service.build, "context", "." ),
                        dockerfile : base_path + U.get( service.build, "dockerfile", "Dockerfile" ),
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
                "docker-compose.yml" : C.File.new( ),
                "docker-compose.override.yml" : C.File.new( ),
                "docker-compose.build.yml" : C.File.new( )
            }
        )

    ),

    new :: function(
        
        version = null,

        build    = C.File.new( version = version ),
        compose  = C.File.new( version = version ),
        override = C.File.new( version = version )

    )({

        "docker-compose.build.yml"    : build,
        "docker-compose.yml"          : compose,
        "docker-compose.override.yml" : override,

        service :: function( 
            service_name, image,
            name        = image,
            files       = { },
            service     = C.Service.new( ),
            development = C.Service.new( ),
            builder     = C.Service.new( ),
            dockerfile  = |||
                FROM %(image)s AS %(service_name)s
                %(files)s
            |||
        )( 

            local build = self[ "docker-compose.build.yml" ]
                .service( service_name, C.Service.new( [ builder ], 

                    image = "%s/%s:%s" % name,
                    build = { context : "." },

                ));
                

            local compose = self[ "docker-compose.yml" ]
                .service( service_name, C.Service.new( [ service ], 
                
                    image = "%s/%s:%s" % name 
                    
                ));

            local override = self[ "docker-compose.override.yml" ]
                .service( service_name, C.Service.new( [ development ], 
            
                    volumes = U.setMap( C.Service.Volume.bind, files )

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