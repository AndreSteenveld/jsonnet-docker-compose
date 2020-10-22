local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        config  = null,
        file    = null,
        registry = null

    )
    mixin( mixins, { } 
        +
        {
            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "config", config ),
                V.optional( "file", file ),
                V.optional( "registry", registry )

            ]

        }
    );

{
    new :: new,
    combine :: combine
}