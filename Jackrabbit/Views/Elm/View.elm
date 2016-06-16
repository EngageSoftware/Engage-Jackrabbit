module Views.Elm.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Views.Elm.Model exposing (..)
import Views.Elm.Script.View as Script
import Views.Elm.Msg exposing (..)
import Views.Elm.Utility exposing (emptyElement, localizeString)


view : Model -> Html Msg
view model =
    let
        scriptRows =
            model.scripts
                |> List.map viewScriptRow
    in
        div []
            [ viewErrorMessage model.errorMessage
            , button [ type' "button", onClick AddNewScript ] [ text (localizeString "Add" model.localization) ]
            , table [ class "dnnTableDisplay" ]
                [ thead []
                    [ tr []
                        [ th [ class "jackrabbit--actions" ] []
                        , th [ class "jackrabbit--prefix" ] [ text (localizeString "Path Prefix Name.Header" model.localization) ]
                        , th [ class "jackrabbit--path" ] [ text (localizeString "Script Path.Header" model.localization) ]
                        , th [ class "jackrabbit--provider" ] [ text (localizeString "Provider.Header" model.localization) ]
                        , th [ class "jackrabbit--priority" ] [ text (localizeString "Priority.Header" model.localization) ]
                        ]
                    ]
                , tbody []
                    scriptRows
                ]
            ]


viewScriptRow : ScriptRow -> Html Msg
viewScriptRow { rowId, script } =
    App.map (ScriptMsg rowId) (Script.view script)


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage errorMessage =
    case errorMessage of
        Nothing ->
            emptyElement

        Just message ->
            div [ class "dnnFormMessage dnnFormValidationSummary" ] [ text message ]
