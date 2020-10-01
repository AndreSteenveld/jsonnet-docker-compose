local U = import "../compose/utilities.libsonnet";

local test( name, test ) = ( 
    if test( ) 
    then "[ Success ] :: " + name
    else "[ Failure ] :: " + name 
);

[

    test( "utilities#empty", function( ) (
    
        assert std.isFunction( U.empty ) : "utilities#empty is not a function";
        assert { } == U.empty( ) : "Resulting empty object is not empty";
        
        true
    
    )),

    test( "utilities#key", function( ) (

        assert std.isFunction( U.key ) : "utilities#key is not a function";
        assert "key" == U.key([ "key", "value" ]) : "utilities#key did not return key";

        true

    )),

    test( "utilities#value", function( ) (

        assert std.isFunction( U.value ) : "utilities#value is not a function";
        assert "value" == U.value([ "key", "value" ]) : "utilities#value did niot return value";

        true 

    )),

    test( "utilities#entries", function( )(

        assert std.isFunction( U.entries ) : "utilities#entries is not a function";
        assert [ ] == U.entries({ }) : "utilities#entried did not convert an empty object to an empty list";

        local kv_pairs = std.sort(
            [
                [ "first", "first" ],
                [ "second", "second" ],
                [ "third", "third" ],
            ],
            U.key
        );

        local object = {
            "first"  : "first",
            "second" : "second",
            "third"  : "third"
        };

        assert kv_pairs == std.sort( U.entries( object ), U.key ) : "utilities#entries did not convert object to kv list";

        true 

    )),

    test( "utilities#to_object", function( )(

        assert std.isFunction( U.to_object ) : "utilities#to_object is not a function";
        assert { } == U.to_object([ ]) : "utilities#to_object did not convert an empty list to an empty object";

        local kv_pairs = [
            [ "first", "first" ],
            [ "second", "second" ],
            [ "third", "third" ],
        ];

        local object = {
            "first"  : "first",
            "second" : "second",
            "third"  : "third"
        };

        assert object == U.to_object( kv_pairs ) : "utilities#to_object did not convert kv list to object";

        true

    )),

    test( "utilities#to_object - create empty object", function( )(

        local kv_pairs = [[ null, null ]];
        local object = { };

        assert object == U.to_object( kv_pairs ) : "utilities#to_object doesn't create empty object for empty KVs";

        true

    )),

    test( "utilities#to_object - deduplicate keys", function( )(

        local kv_pairs = [
            [ "key", "first" ],
            [ "key", "second" ],
            [ "key", "third" ],
        ];

        local object = { key : "third" };

        assert object == U.to_object( kv_pairs ) : "utilities#to_object doesn't deduplicate lists of KVs appropiatly";

        true

    )),

    test( "utilities#get", function( )(

        assert null == U.get({ }, "doesn't exist" ) : "Does not return nothing for non-existing fields";
        assert "default" == U.get({ }, "doesn't exist", "default" ) : "Doesn't return default for non-existing fields";
        assert null == U.get({ exists : null }, "exists" ) : "Doesn't return existing field";
        assert true == U.get({ exists : true }, "exists" ) : "Doesn't return existing field";

        true

    )),

    test( "utilities#unzip_objects", function( )(

        local left = { 
            left : "left",
            shared : "left",
        };

        local right = { 
            right : "right",
            shared : "right"
        };

        local unzipped = std.sort(
            [
                [ "left", [ "left", "left" ], null ],
                [ "right", null, [ "right", "right" ] ],
                [ "shared", [ "shared", "left" ], [ "shared", "right" ] ],
            ]
            , U.key 
        );

        assert std.isFunction( U.unzip_objects ) : "utilities#unzip_objects is not a function";
        assert [ ] == U.unzip_objects({ }, { }) : "Unzipping empty object didn't yiled empty KVV tuple";
        assert unzipped == std.sort( U.unzip_objects( left, right ), U.key ) : "Unzipping didn't yield expexted result";

        true

    )),

    test( "utilities#map_combiner - without handlers", function( ) (

        local handlers = { };

        local left = {
            left : "left",
            shared : "left"
        };

        local right = { 
            right : "right",
            shared : "right"
        };

        local combined = {
            left : "left",
            shared : "right",
            right : "right"
        };

        local combine = U.map_combiner( handlers );

        assert std.isFunction( combine ) : "combine is not a function";
        assert { } == combine( { }, { } ) : "combining empty object did not yield an empty object";
        assert combined == combine( left, right ) : "Combination of left and right yielded unexpected result";

        true

    )),

    test( "utilities#map_combiner - with catch all", function( ) (

        local handlers = {

            "*"( left, right, key ) :: (

                [ key, left, right ]

            )

        };

        local left = {
            left : "left",
            shared : "left"
        };

        local right = { 
            right : "right",
            shared : "right"
        };

        local combined = {
            left   : "left",
            shared : [ "shared", "left", "right" ],
            right  : "right"
        };

        local combine = U.map_combiner( handlers );

        assert combined == combine( left, right ) : "Combination of left and right yielded unexpected result";

        true

    )),

    test( "utilities#map_combiner - with specific handler", function( ) (

        local handlers = {

            "shared"( left, right ) :: (

                [ "shared", left, right ]

            )

        };

        local left = {
            left : "left",
            shared : "left"
        };

        local right = { 
            right : "right",
            shared : "right"
        };

        local combined = {
            left   : "left",
            shared : [ "shared", "left", "right" ],
            right  : "right"
        };

        local combine = U.map_combiner( handlers );

        assert combined == combine( left, right ) : "Combination of left and right yielded unexpected result";

        true

    ))
]