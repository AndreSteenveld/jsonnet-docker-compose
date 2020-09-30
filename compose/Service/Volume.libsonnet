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

    mount( source, target ) :: self.new( [ ], "mount", source, target ),
    bind( source, target ) :: self.new( [ ], "bind", source, target ),

}
