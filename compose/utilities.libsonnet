local empty( ) = ({ });

local key( kv ) = ( kv[ 0 ] );
local value( kv ) = ( kv [ 1 ] );

local get( o, k, d = null ) = (

    if std.objectHas( o, k )
    then o[ k ]
    else d 

);

local entries( o ) = ( 

    std.map( 
        function( key )([ key, o[ key ] ]),
        std.objectFields( o )
    )

);

local keys( o ) = (

    std.objectFields( o )

);

local values( o ) = (

    std.map( 
        function( k )( o [ k ] ),
        std.objectFields( o )
    )

);

local setMap( f, o ) = (

    std.map(
        function ( kv ) f( key( kv ), value( kv ) ),
        entries( o )
    )

);

local to_object( pairs ) = ({

    [ key( kv ) ] : value( kv ) for kv in std.set( std.reverse( std.filter( std.isArray, pairs ) ), key )

});

local combine( default, combiner ) = 
    function( left, right ) default( ) + left + right + combiner( left, right );

local mixin( combiner ) =
    function( mixins, target ) std.foldr( combiner, mixins, target );

local unzip_objects( left, right ) = (

    local pick( key ) = ([ 
        key, 
        if std.objectHas( left, key ) then [ key, left[ key ] ] else null,
        if std.objectHas( right, key ) then [ key, right[ key ] ] else null,
    ]);

    local keys = std.setUnion(
        std.objectFields( left ),
        std.objectFields( right )
    );

    std.map( pick, keys )

);

local map_combiner( handlers ) = (

    function( left, right )(
        
        local combined = std.foldr(

            function( tuple, _ )(

                local tkey   = key( tuple );
                local tleft  = if null == tuple[ 1 ] then [ null, null ] else tuple[ 1 ];
                local tright = if null == tuple[ 2 ] then [ null, null ] else tuple[ 2 ];

                local left_has_entry = null != key( tleft );
                local right_has_entry = null != key( tright ); 

                local handler = 
                    if std.objectHasAll( handlers, tkey ) 
                    then function( l, r, k )( 
                        
                        handlers[ tkey ]( value( l ), value( r ) ) 
                        
                    )
                    else 
                        if std.objectHasAll( handlers, "*" )
                        then function( l, r, k )( 
                            
                            handlers[ "*" ]( value( l ), value( r ), k ) 
                            
                        )
                        else function( l, r, k )(

                            get( to_object([ l, r ]), k )

                        )
                ;

                _ + { 
                
                    [ tkey ] : 
                        if left_has_entry && right_has_entry 
                        then handler( tleft, tright, tkey )
                        else 
                            if right_has_entry 
                            then value( tright )
                            else value( tleft ) 
                    
                }
              
            ),

            unzip_objects( left, right ),

            empty( )
        
        );

        combined
        
    )

);

{
    empty :: empty,

    key :: key,
    value :: value, 

    get :: get,

    entries :: entries,

    keys :: keys,
    values :: values,

    setMap :: setMap,

    to_object :: to_object,
    
    combine :: combine,
    mixin :: mixin,

    unzip_objects :: unzip_objects,

    map_combiner :: map_combiner,

}