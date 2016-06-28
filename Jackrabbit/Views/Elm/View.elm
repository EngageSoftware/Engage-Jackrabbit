module Views.Elm.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Views.Elm.Model exposing (..)
import Views.Elm.File.View as File
import Views.Elm.Msg exposing (..)
import Views.Elm.Utility exposing (emptyElement, localizeString)


view : Model -> Html Msg
view model =
    let
        fileRows =
            model.files
                |> List.map viewFileRow
    in
        div []
            [ viewErrorMessage model.errorMessage
            , button [ type' "button", onClick AddNewFile ] [ text (localizeString "Add" model.localization) ]
            , table [ class "dnnTableDisplay" ]
                [ thead []
                    [ tr []
                        [ th [ class "jackrabbit--actions" ] []
                        , th [ class "jackrabbit--prefix" ] [ text (localizeString "Path Prefix Name.Header" model.localization) ]
                        , th [ class "jackrabbit--path" ] [ text (localizeString "File Path.Header" model.localization) ]
                        , th [ class "jackrabbit--provider" ] [ text (localizeString "Provider.Header" model.localization) ]
                        , th [ class "jackrabbit--priority" ] [ text (localizeString "Priority.Header" model.localization) ]
                        ]
                    ]
                , tbody []
                    fileRows
                ]
            ]


viewFileRow : FileRow -> Html Msg
viewFileRow { rowId, file } =
    App.map (FileMsg rowId) (File.view file)


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage errorMessage =
    case errorMessage of
        Nothing ->
            emptyElement

        Just message ->
            div [ class "dnnFormMessage dnnFormValidationSummary" ] [ text message ]
