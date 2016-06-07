module Views.Elm.Script.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Elm.Script.Model exposing (..)
import Views.Elm.Script.Msg exposing (..)


view : Model -> Html Msg
view model =
    if model.editing then
        editScript model.script
    else
        viewScript model.script


viewScript : ScriptData -> Html Msg
viewScript script =
    tr []
        [ td []
            [ button [ type' "button", onClick EditScript ] [ text "Edit" ]
            , button [ type' "button", onClick DeleteScript ] [ text "Delete" ]
            ]
        , td [] [ text script.pathPrefixName ]
        , td [] [ text script.scriptPath ]
        , td [] [ text script.provider ]
        , td [] [ text (toString script.priority) ]
        ]


editScript : ScriptData -> Html Msg
editScript script =
    tr []
        [ td []
            [ button [ type' "button", onClick SaveChanges ] [ text "Save" ]
            , button [ type' "button", onClick CancelChanges ] [ text "Cancel" ]
            ]
        , td [] [ input [ type' "text", value script.pathPrefixName ] [] ]
        , td [] [ input [ type' "text", value script.scriptPath ] [] ]
        , td [] [ input [ type' "text", value script.provider ] [] ]
        , td [] [ input [ type' "text", value (toString script.priority) ] [] ]
        ]
