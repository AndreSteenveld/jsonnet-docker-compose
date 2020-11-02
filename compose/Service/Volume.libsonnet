local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = U.combiner.map({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function( 
        mixins = [ ],
        type,
        source,
        target,

        read_only   = null,
        consistency = null,
        bind        = null,
        volume      = null,
        tmpfs       = null

    )
    mixin( mixins, 
        {
            type : type,
            source : source,
            target : target,
        }
        +
        {

            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "read_only", read_only ),
                V.optional( "consistency", consistency ),
                V.optional( "bind", bind ),
                V.optional( "volume", volume ),
                V.optional( "tmpfs", tmpfs )

            ]

        }
    );

{ 
    new :: new,
    combine :: combine,

    bind( source, target ) :: self.new( [ ], "bind", source, target ),
    volume( source, target ) :: self.new( [ ], "volume", source, target ),
    tmpfs( ) :: error "Not implemented",
    npipe( ) :: error "Not implemented"

}
