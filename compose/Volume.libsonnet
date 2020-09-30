local U = import "./utilities.libsonnet";
local V = import "./validate.libsonnet";

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function( 
        mixins = [ ],
        
    )
    mixin( mixins, {

    });

{ 
    new :: new,
    combine :: combine
}
