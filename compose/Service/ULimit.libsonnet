local U = import "../utilities.libsonnet";
local V = import "../validate.libsonnet";

local combiner = U.combiner.map({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(

        mixins = [ ],

        hard, soft = hard

    )
    mixin( mixins, { 

        hard : hard,
        soft : soft

    });

{
    new :: new,
    combine :: combine
}