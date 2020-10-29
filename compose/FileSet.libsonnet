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

    local services = std.foldr( 
        function( kv, output )(

            local key     = U.key( kv );
            local service = U.value( kv );

            local patch = {
                build : {
                    context : base_path + U.get( service.build, "context", "." ),
                },
            };

            output + {
                
                [ key ] : std.mergePatch( service, patch )

            }

        ),
        U.entries( U.get( right, "services", { } ) ),
        U.empty( )
    );

    { name : file_name, content : File.new( [ left, right ], services = services ) }

);

local dockerfiles( base_path, mixin ) = (

    local filter( kv ) = ( 
        
        local file_name = U.key( kv );
        local content = U.value( kv );

        std.isString( content ) 
            && file_name != "docker-compose.yml"
            && file_name != "docker-compose.override.yml"
            && file_name != "docker-compose.build.yml"

    );

    local map( kv ) = ({ name : base_path + U.key( kv ), content : U.value( kv ) }); 

    std.filterMap( filter, map, U.entries( mixin ) )

);

local merge_service_file_sets( kv, output ) = (

    local base_path = U.key( kv );
    local file_set  = U.value( kv );

    output + {
        
        [ file.name ] : file.content for file in dockerfiles( base_path, file_set ) + [

            build_file( base_path, output, file_set ),
            compose_file( base_path, output, file_set ),
            override_file( base_path, output, file_set ),

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
                "docker-compose.build.yml" : File.new( ),
                "docker-compose.yml" : File.new( ),
                "docker-compose.override.yml" : File.new( )
            }
        )

    ),

    new :: function(
        
        version = null,

        build    = File.new( version = version ),
        compose  = File.new( version = version ),
        override = File.new( version = version )

    )(
        
        local build_file    = "docker-compose.build.yml";
        local compose_file  = "docker-compose.yml";
        local override_file = "docker-compose.override.yml";

        {

            [ build_file ]    : build,
            [ compose_file ]  : compose,
            [ override_file ] : override,

            service :: function( 
                service_name, image,
                name        = image,
                files       = { },
                service     = Service.new( ),
                development = Service.new( ),
                builder     = Service.new( ),
                dockerfile  = "Dockerfile",
                template    = |||
                    FROM %(image)s AS %(service_name)s
                    %(files)s
                |||
            )( 

                local build = if null == builder 
                    then self[ build_file ] 
                    else self[ build_file ]
                        .service( service_name, Service.new( [ builder ], 

                            container_name = "%s__builder" % service_name ,
                            image = "${REGISTRY:-docker.io/}%s/%s:%s" % name,
                            build = { 
                                context : ".",
                                dockerfile : dockerfile
                            },

                        ));

                local compose = if null == service
                    then self[ compose_file ]
                    else self[ compose_file ]
                        .service( service_name, Service.new( [ service ], 
                        
                            container_name = service_name,
                            image = "${REGISTRY:-docker.io/}%s/%s:%s" % name 
                            
                        ));

                local override = if null == development
                    then self[ override_file ]
                    else self[ override_file ]
                        .service( service_name, Service.new( [ development ], 
                
                            // Copy these over for the "development"-only type of services, seems like
                            // the cleanest solution.
                            container_name = service_name,
                            image = "${REGISTRY:-docker.io/}%s/%s:%s" % name,

                            volumes = U.setMap( Service.Volume.bind, files )

                        ));

                { } + self + {

                    [ build_file ]    : build,
                    [ compose_file ]  : compose,
                    [ override_file ] : override,

                    [ dockerfile ] : template % {

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

        }
    
    )

}