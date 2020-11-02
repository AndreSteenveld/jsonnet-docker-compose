local U = import "../../utilities.libsonnet";
local V = import "../../validate.libsonnet";

local combiner = U.combiner.map({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        condition   = null,
        delay       = null,
        max_attemtps = null,
        window      = null

    )
    mixin( mixins, { } 
        +
        {
            
            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "condition", condition ), 
                V.optional( "delay", delay ), 
                V.optional( "max_attemtps", max_attemtps ), 
                V.optional( "window", window )

            ]

        }
    );

{
    new :: new,
    combine :: combine
}