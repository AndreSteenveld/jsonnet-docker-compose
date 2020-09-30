local utilities = import "../utilities.libsonnet";

local combiner = function( left, right ) { };

local combine = utilities.combine( { }, combiner );
local mixin = utilities.mixin( combine );

local new = function( 
        
        mixins = [ ]
    
    )
    mixin( mixins, {
        
    });

{ new :: new }