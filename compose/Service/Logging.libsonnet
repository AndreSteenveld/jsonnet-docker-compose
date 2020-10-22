local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = function( left, right ) { };

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function( 
        mixins = [ ],
        driver  = null,
        options = null
    )
    mixin( mixins, { 

        [ U.key( kv ) ] : U.value( kv ) for kv in [

            V.optional( "driver", driver ),
            V.optional( "options", options ),

        ]

    });

{ 
    new :: new,
    combine :: combine
}