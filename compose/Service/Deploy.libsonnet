local U = import "../utilities.libsonnet";

local combiner = function( left, right ) { };

local combine = U.combine( { }, combiner );
local mixin = U.mixin( combine );

local new = function( 
        
        mixins = [ ],

        mode            = null,
        endpoint_mode   = null,
        replicas        = null,
        labels          = null,
        rollback_config = null,
        update_config   = null,
        resources       = null,
        restart_policy  = null,
        placement       = null
    
    )
    mixin( mixins, { }
        +
        {

            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "mode", mode ),
                V.optional( "endpoint_mode", endpoint_mode ),
                V.optional( "replicas", replicas ),
                V.optional( "labels", labels ),
                V.optional( "rollback_config", rollback_config ),
                V.optional( "update_config", update_config ),
                V.optional( "resources", resources ),
                V.optional( "restart_policy", restart_policy ),
                V.optional( "placement", placement )

            ]

        }
    );

{ new :: new }