local U = import "./utilities.libsonnet";
local V = import "./validate.libsonnet";

local Service = import "./Service.libsonnet";
local Network = import "./Network.libsonnet";
local Volume  = import "./Volume.libsonnet";
local Secret  = import "./Secret.libsonnet";
local Config  = import "./Config.libsonnet";

local combiner = U.map_combiner({

    //version( l, r ) :: ( l ),
    services :: U.map_combiner({ "*"( l, r, k ) :: Service.combine( l, r ) }),
    networks :: U.map_combiner({ "*"( l, r, k ) :: Network.combine( l, r ) }),
    volumes :: U.map_combiner({ "*"( l, r, k ) :: Volume.combine( l, r ) }),
    secrets :: U.map_combiner({ "*"( l, r, k ) :: Secret.combine( l, r ) }),
    configs :: U.map_combiner({ "*"( l, r, k ) :: Config.combine( l, r ) }),

});

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function( 
        mixins   = [ ],
        version  = null,
        services = null,
        networks = null,
        volumes  = null,
        secrets  = null,
        configs  = null
    )
    mixin( mixins, { }
        + 
        {

            service :: function( name, service = Service.new( ) ) self + std.mergePatch( self, { 

                services : { [ name ] : service }

            }),

            network :: function( name, network = Network.new( ) ) self + std.mergePatch( self, {

                networks : { [ name ] : network }

            }),

            volume :: function( name, volume = Volume.new( ) ) self + std.mergePatch( self, {

                volumes : { [ name ] : volume }

            }),

            secret :: function( name, secret = Secret.new( ) ) self + std.mergePatch( self, {

                secrets : { [ name ] : secret },

            }),

            config :: function( name, config = Config.new( ) ) self + std.mergePatch( self, {

                configs : { [ name ] : config },

            })

        }
        + 
        {

            [ U.key( kv ) ] : U.value( kv ) for kv in [

                V.optional( "version", version ),
                V.optional( "services", services ),
                V.optional( "networks", networks ),
                V.optional( "volumes", volumes ),
                V.optional( "secrets", secrets ),
                V.optional( "configs", configs )

            ]

        }
    );

{ 
    new :: new,
    combine :: combine
}
