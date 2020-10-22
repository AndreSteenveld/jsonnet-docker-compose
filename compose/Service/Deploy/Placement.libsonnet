local U = import "../../utilities.libsonnet";
local V = import "../../validate.libsonnet";

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        constraints = null,
        preferences = null,
        max_replicas_per_node = null

    )
    mixin( mixins, { } 
        +
        {
            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "constraints", constraints ),
                V.optional( "preferences", preferences ),
                V.optional( "max_replicas_per_node", max_replicas_per_node )

            ]

        }
    );

{
    new :: new,
    combine :: combine
}