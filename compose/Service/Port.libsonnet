local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = function( left, right ) { };

local combine = U.combine( { }, combiner );
local mixin = U.mixin( combine );

local new = function( 
        mixins = [ ],
        target, 
        published = target,
        protocol  = null,
        mode      = null
    )
    mixin( mixins, { } +
        {
            target : target,
            published : published
        }
        +
        {
        
        [ U.key( kv ) ] : U.value( kv ) for kv in [

            V.optional( "protocol", protocol ),
            V.optional( "mode", mode )

        ]

    });

{ new :: new }