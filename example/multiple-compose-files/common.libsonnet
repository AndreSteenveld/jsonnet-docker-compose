local C = import "../../compose.libsonnet";

{
    // The base files
    file: {
        
        build: C.File.new( version = "3.8" ),
        
        compose: C.File.new( 
            
            version = "3.8",
            networks = { 
                
                "monitor-net" : C.Network.new( driver = "bridge" ) 
                
            }
            
        ),

        override: C.File.new( version = "3.8" )

    },

    // Our common service mixins
    restart_policy : C.Service.new( restart = "unless-stopped" ),
    networks : C.Service.new( networks = [ "monitor-net" ] ),
    labels   : C.Service.new( labels = { "org.label-schema.group" : "monitoring" } )
}