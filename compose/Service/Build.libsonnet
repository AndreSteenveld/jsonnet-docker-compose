local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = U.combiner.map({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        context     = null,
        dockerfile  = null,
        labels      = null,
        cache_from  = null,
        network     = null,
        target      = null,
        shm_size    = null

    )
    mixin( mixins, { } 
        +
        {
            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "context", context ),
                V.optional( "dockerfile", dockerfile ),
                V.optional( "labels", labels ),
                V.optional( "cache_from", cache_from ),
                V.optional( "network", network ),
                V.optional( "target", target ),
                V.optional( "shm_size", shm_size )

            ]

        }
    );

{
    new :: new,
    combine :: combine
}