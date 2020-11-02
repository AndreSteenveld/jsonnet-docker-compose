local U = import "../../utilities.libsonnet";
local V = import "../../validate.libsonnet";

local combiner = U.combiner.map({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        parallelism     = null,
        delay           = null,
        failure_action  = null,
        monitor         = null,
        max_failure_ratio = null,
        order           = null

    )
    mixin( mixins, { } 
        +
        {

            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "parallelism", parallelism ),
                V.optional( "delay", delay ),
                V.optional( "failure_action", failure_action ),
                V.optional( "monitor", monitor ),
                V.optional( "max_failure_ratio", max_failure_ratio ),
                V.optional( "order", order )

            ]

        }
    );

{
    new :: new,
    combine :: combine
}