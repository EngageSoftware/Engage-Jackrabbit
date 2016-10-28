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

        editLibForm =
            model.files
                |> List.map addEditForm

        addFile =
            showAddFile model model.tempFileRow
    in
        div []
            [ viewErrorMessage model.errorMessage
            , addFile
            , div []
                editLibForm
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


addEditForm : FileRow -> Html Msg
addEditForm { rowId, file } =
    App.map (FileMsg rowId) (File.editLib file)


showAddFile : Model -> Maybe FileRow -> Html Msg
showAddFile model tempFile =
    case tempFile of
        Nothing ->
            case model.editing of
                False ->
                    button [ type' "button", onClick AddNewFile ] [ text (localizeString "Add" model.localization) ]

                True ->
                    emptyElement

        Just { rowId, file } ->
            App.map (FileMsg rowId) (File.viewAddForm file)


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage errorMessage =
    case errorMessage of
        Nothing ->
            emptyElement

        Just message ->
            div [ class "dnnFormMessage dnnFormValidationSummary" ] [ text message, button [ type' "button", onClick DismissError ] [ text "Dismiss Error" ] ]
