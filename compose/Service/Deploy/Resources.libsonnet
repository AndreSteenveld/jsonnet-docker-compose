local U = import "../../utilities.libsonnet";
local V = import "../../validate.libsonnet";

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        limits = null,
        reservations = null

    )
    mixin( mixins, { } 
        +
        {
            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "limits", limits ),
                V.optional( "reservations", reservations )

            ]
        }
    
    );

{
    new :: new,
    combine :: combine
}