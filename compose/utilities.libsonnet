{

    combine( default, combiner ) :: 
        function( left, right ) default( ) + left + right + combiner( left, right ),

    mixin( combiner ) ::
        function( mixins, target ) std.foldr( combiner, mixins, target ),

}