local U = import "./utilities.libsonnet";
local V = import "./validate.libsonnet";

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function( 
        mixins = [ ],
        
        name        = null,
        driver      = null,
        driver_opts = null,
        external    = null,
        labels      = null
    )
    mixin( mixins, { }
        +
        {
            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "name", name ),
                V.optional( "driver", driver ),
                V.optional( "driver_opts", driver_opts ),
                V.optional( "external", external ),
                V.optional( "labels", labels )

            ]
        }
    );

{ 
    new :: new,
    combine :: combine
}
