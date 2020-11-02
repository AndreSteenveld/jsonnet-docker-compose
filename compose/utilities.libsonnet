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

local combiner_union( combiner ) = (

    function( left, right )(

        local combined = std.foldr( 

            function( tuple, _ )(

                local tkey   = key( tuple );
                local tleft  = tuple[ 1 ];
                local tright = tuple[ 2 ];

                _ + { [ tkey ] : combiner( tleft, tright, tkey ) }
            
            ),

            unzip_objects( left, right ),

            empty( )

        );

        combined

    )

);

local combiner_map( mapping ) = combiner_union( function( l, r, k )(

    local left_exists = std.isArray( l );
    local right_exists = std.isArray( r );
    
    if left_exists && right_exists && std.objectHasAll( mapping, k ) then
                        
        mapping[ k ]( 
            if left_exists then value( l ) else null, 
            if right_exists then value( r ) else null
        ) 
                        
    else if left_exists && right_exists && std.objectHasAll( mapping, "*" ) then 
        
        mapping[ "*" ]( 
            if left_exists then value( l ) else null, 
            if right_exists then value( r ) else null, 
            k 
        ) 

    else if right_exists then

        value( r )

    else if left_exists then

        value( l )

    else 

        null

));

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

    combiner : {
        
        merge( l, r ) :: ( l + r ),

        append( l, r )  :: ( l + r ),
        prepend( l, r ) :: ( r + l ),
        replace( l, r ) :: ( r ),

        unique( o, key = function( v ) v ) :: function( l, r ) std.set( o( l, r ), key ),

        map :: combiner_map,
        union :: combiner_union

    },

}