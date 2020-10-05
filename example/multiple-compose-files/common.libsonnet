local C = import "../../compose.libsonnet";

local build_file       = C.File([ ], version = "3.8" );
local compose_file     = C.File([ ], version = "3.8" );
local development_file = C.File([ compose_file ], version = "3.8" );

{
    // The base files
    file: {
        build       : build_file,
        compose     : compose_file,
        development : development_file
    },

    // Our common service mixins
    restart_policy : C.Service.new( [ ], restart = "unless-stopped" ),
    networks : C.Service.new( [ ], networks = [ "monitoring" ] ),
    labels   : C.Service.new( [ ], labels = { "org.label-schema.group" : "monitoring" } )
}