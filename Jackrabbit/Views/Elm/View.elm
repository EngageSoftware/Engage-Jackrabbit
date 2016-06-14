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
            , table [ class "dnnTableDisplay" ]
                [ thead []
                    [ tr []
                        [ th [ class "jackrabbit--actions" ] []
                        , th [ class "jackrabbit--prefix" ] [ text "Path Prefix" ]
                        , th [ class "jackrabbit--path" ] [ text "Script Path" ]
                        , th [ class "jackrabbit--provider" ] [ text "Provider" ]
                        , th [ class "jackrabbit--priority" ] [ text "Priority" ]
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
