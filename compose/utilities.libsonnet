{

    empty( ) :: { },

    key( kv ) :: ( kv[ 0 ] ),
    value( kv ) :: ( kv [ 1 ] ),

    map_combiner( handlers ) :: (

        local combine( tuple ) = (

            local key   = tuple[ 0 ];
            local left  = tuple[ 1 ];
            local right = tuple[ 2 ];

                 if std.objectHasAll( handlers, key ) then handlers[ key ]( left, right )
            else if std.objectHasAll( handlers, "*" ) then handlers[ "*" ]( left, right, key )
            else right

        );

        function( left, right )(

            local unzipped = self.unzip_objects( left, right );
            local merged = std.map( combine, unzipped );

            self.zip_kv( merged )

        )

    ),

    combine( default, combiner ) :: 
        function( left, right ) default( ) + left + right + combiner( left, right ),

    mixin( combiner ) ::
        function( mixins, target ) std.foldr( combiner, mixins, target ),

    unzip_objects( left, right ) :: (

        local pick( key ) = ([ key, left[ key ], right[ key ] ]);

        local keys = std.setUnion(
            std.objectFields( left ),
            std.objectFields( right )
        );

        std.map( pick, keys )

    ),

    zip_kv( pairs ) :: ({ 

        [ self.key( kv ) ] : self.value( kv ) for kv in pairs

    }),

}