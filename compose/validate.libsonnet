{
    optional( k, v ) :: (

        if v == null then [ null, null ] else [ k, v ]

    ),

    required( k, v, m = "Field is required" ) :: (

        assert null != v : m; [ k, v ]

    ),

    validator( o ) :: (

        function( k, v )(

            if o( k, v ) then [ k, v ] else [ null, null ]

        )

    ),

}