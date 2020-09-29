local utilities = import "./utilities.libsonnet";

{
    create( ) :: { },
    default( ) :: { },

    combine :: utilities.combine(
        self.default, 
        function( left, right ) { }
    ),

    mixin :: utilities.mixin( self.combine ),

    services( services ) :: services,
    networks( networks ) :: networks,
    volumes( volumes ) :: volumes,
    configs( configs ) :: configs,
    secrets( secrets ) :: secrets

}