module Views.Elm.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Views.Elm.Model exposing (..)
import Views.Elm.Script.View as ScriptView
import Views.Elm.Msg exposing (..)
import Views.Elm.Utility exposing (emptyElement)


view : Model -> Html Msg
view model =
    let
        scriptRows =
            model.scripts
                |> List.map viewScriptRow
    in
        div []
            [ viewErrorMessage model.errorMessage
            , button [ type' "button", onClick AddNewScript ] [ text "Add" ]
            , table []
                [ thead []
                    [ tr []
                        [ th [] []
                        , th [] [ text "Path Prefix" ]
                        , th [] [ text "Script Path" ]
                        , th [] [ text "Provider" ]
                        , th [] [ text "Priority" ]
                        ]
                    ]
                , tbody []
                    scriptRows
                ]
            ]


viewScriptRow : ScriptRow -> Html Msg
viewScriptRow { rowId, script } =
    App.map (ScriptMsg rowId) (ScriptView.view script)


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage errorMessage =
    case errorMessage of
        Nothing ->
            emptyElement

        Just message ->
            div [ class "dnnFormMessage dnnFormValidationSummary" ] [ text message ]
