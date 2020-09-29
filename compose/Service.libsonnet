local utilities = import "./utilities.libsonnet";

{
    create( ) :: { },
    default( ) :: { },

    combine :: utilities.combine(
        self.default, 
        function( left, right ) { }
    ),

    mixin :: utilities.mixin( self.combine ),
    
    //BlockIOConfig :: import "./Service/BlockIOConfig.libsonnet",
    //Build         :: import "./Service/Build.libsonnet",
    //Deploy        :: import "./Service/Deploy.libsonnet",
    //CredentialSpec :: import "./Service/CredentialSpec.libsonnet",
    //Healthcheck   :: import "./Service/Healthcheck.libsonnet",
    //ULimits       :: import "./Service/ULimits.libsonnet, 

    //Logging :: import "./Service/Logging.libsonnet",
    logging( logging ) :: logging,

    //Config :: import "./Service/Config.libsonnet",
    configs( configs ) :: configs,

    //Secret :: import "./Service/Secret.libsonnet",
    secrets( secrets ) :: secrets,

    //Extends :: import "./Service/Extends.libsonnet",
    extends( service ) :: service,
    
    //DependsOn :: import "./Service/DependsOn.libsonnet,
    depends_on( services ) :: services,

    //Port :: import "./Service/Port.libsonnet",
    ports :: {
        mapping ( mappings ) :: mappings,
        list ( ports ) :: ports,
    },

    //Network :: import "./Service/Network.libsonnet",
    networks( networks ) :: networks,

    Volume :: /* ( import "./Service/Volume.libsonnet" ) + */{

        mount( source, target ) :: { type : "mount",  source : source , target : target },
        bind( source, target ) :: { type : "bind", source : source, target : target }

    },
    volumes( volumes ) :: volumes

}