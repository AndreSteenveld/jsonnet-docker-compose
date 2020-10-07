local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function( 
        mixins = [ ],
        type,
        source,
        target,
    )
    mixin( mixins, {
        type : type,
        source : source,
        target : target,
    });

{ 
    new :: new,
    combine :: combine,

    bind( source, target ) :: self.new( [ ], "bind", source, target ),
    volume( source, target ) :: self.new( [ ], "volume", source, target ),
    tmpfs( ) :: error "Not implemented",
    npipe( ) :: error "Not implemented"

}
