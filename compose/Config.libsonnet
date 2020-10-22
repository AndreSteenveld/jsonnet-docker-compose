local U = import "./utilities.libsonnet";
local V = import "./validate.libsonnet";

local combiner = function( left, right ) { };

local combine = U.combine( { }, combiner );
local mixin = U.mixin( combine );

local new = function( 
        
        mixins = [ ],

        name            = null,
        file            = null,
        external        = null,
        labels          = null,
        template_driver = null,
    
    )
    mixin( mixins, { }
        +
        {

            [ U.key( kv ) ] : U.value( kv ) for kv in [
                
                V.optional( "name", name ),
                V.optional( "file", file ),
                V.optional( "external", external ),
                V.optional( "labels", labels ),
                V.optional( "template_driver", template_driver )

            ]

        }
    );

{ 
    new :: new,
    combine :: combine 
}