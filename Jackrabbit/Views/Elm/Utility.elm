module Views.Elm.Utility exposing (..)

import Html exposing (text)


{-| Based on https://github.com/elm-lang/core/blob/15622175428772e98b84671c5ec0e98f8de4e2b7/src/List.elm#L418-L428

    unzip [(0, True, "a"), (17, False, "b"), (1337, True, "c")] == ([0,17,1337], [True,False,True], ["a","b","c"])
-}
unzip3 : List ( a, b, c ) -> ( List a, List b, List c )
unzip3 tuples =
    let
        step ( x, y, z ) ( xs, ys, zs ) =
            ( x :: xs, y :: ys, z :: zs )
    in
        List.foldr step ( [], [], [] ) tuples


emptyElement : Html.Html msg
emptyElement =
    text ""
