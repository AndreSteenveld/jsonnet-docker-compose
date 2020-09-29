local utilities = import "./utilities.libsonnet";

local Config = {

    create( ) :: { },
    default( ) :: { },

    combine :: utilities.combine(
        self.default, 
        function( left, right ) { }
    ),

    mixin :: utilities.mixin( self.combine )
    
};

local Ipam = {
    create( ) :: { },
    default( ) :: { },

    combine :: utilities.combine(
        self.default, 
        function( left, right ) { }
    ),

    mixin :: utilities.mixin( self.combine ),
    
    Config :: Config

};

{
    create( ) :: { },
    default( ) :: { },

    combine :: utilities.combine(
        self.default, 
        function( left, right ) { }
    ),

    mixin :: utilities.mixin( self.combine ),
    
    Ipam :: Ipam 
}