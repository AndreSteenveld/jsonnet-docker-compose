local U = import "./utilities.libsonnet";
local V = import "./validate.libsonnet";

//
// File.Network.Ipam.Config
//
local config_combiner = U.map_combiner({ });

local config_combine = U.combine( U.empty, config_combiner );
local config_mixin = U.mixin( config_combine );

local config_new = function( 
        mixins = [ ],
        
    )
    config_mixin( mixins, {

    });

//
// File.Network.Ipam
//
local ipam_combiner = U.map_combiner({ });

local ipam_combine = U.combine( U.empty, ipam_combiner );
local ipam_mixin = U.mixin( ipam_combine );

local ipam_new = function( 
        mixins = [ ],
        driver = null,
        config = null,
    )
    ipam_mixin( mixins, {

    });

//
// File.Network
//
local network_combiner = U.map_combiner({ });

local network_combine = U.combine( U.empty, network_combiner );
local network_mixin = U.mixin( network_combine );

local network_new = function( 
        mixins = [ ],
        
        name        = null,
        driver      = null,
        driver_opts = null,
        ipam        = null,
        external    = null,
        internal    = null,
        attachable  = null,
        labels      = null

    )
    network_mixin( mixins, { }
        +
        {

            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "name", name ),
                V.optional( "driver", driver ),
                V.optional( "driver_opts", driver_opts ),
                V.optional( "ipam", ipam ),
                V.optional( "external", external ),
                V.optional( "internal", internal ),
                V.optional( "attachable", attachable ),
                V.optional( "labels", labels )

            ]

        }
    );

{
    new :: network_new,
    combine :: network_combine,

    Ipam :: {

        new :: ipam_new,
        combine :: ipam_combine,

        Config :: {
            
            new :: config_new,
            combine :: config_combine

        },
    
    },
    
}