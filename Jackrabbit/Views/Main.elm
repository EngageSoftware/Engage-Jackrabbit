module Views.Main exposing (..)

import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.View exposing (view)
import Views.Elm.Update exposing (update)
import Html.App as App


main : Program InitialData
main =
    App.programWithFlags
        { init = (\flags -> update (Init flags) initialModel)
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
