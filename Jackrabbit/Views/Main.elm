module Views.Main exposing (..)

import Html
import Views.Elm.Model exposing (..)
import Views.Elm.Msg as Msg exposing (..)
import Views.Elm.View exposing (view)
import Views.Elm.Update exposing (update)
import Json.Encode as Encode


main : Program Encode.Value Model Msg
main =
    Html.programWithFlags
        { init = (\flags -> update (Init flags) initialModel)
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
