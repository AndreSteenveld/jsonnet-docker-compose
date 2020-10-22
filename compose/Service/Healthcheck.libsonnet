local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        disable     = null,
        interval    = null,
        retries     = null,
        test        = null, 
        timeout     = null,
        start_period = null

    )
    mixin( mixins, { } 
        +
        {
            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "disable", disable ),
                V.optional( "interval", interval ),
                V.optional( "retries", retries ),
                V.optional( "test", test ),
                V.optional( "timeout", timeout ),
                V.optional( "start_period", start_period )
        
            ]

        }
    );

{
    new :: new,
    combine :: combine
}