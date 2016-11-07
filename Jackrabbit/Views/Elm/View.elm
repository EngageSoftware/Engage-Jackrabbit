module Views.Elm.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Views.Elm.Model exposing (..)
import Views.Elm.File.View as File
import Views.Elm.Msg exposing (..)
import Dict exposing (Dict)
import Views.Elm.Utility exposing (emptyElement, localizeString)
import Views.Elm.File.Model exposing (getFile)


view : Model -> Html Msg
view model =
    let
        itemRows provider =
            model.files
                |> List.filter (\fileRow -> (getFile fileRow.file.file).provider == provider)
                |> List.map viewFileRow

        itemSection ( provider, fileRows ) =
            let
                labelRow =
                    tr [ class "jackrabbit--item-section--label" ] [ td [ colspan 5 ] [ text provider ] ]
            in
                tbody
                    [ class ("jackrabbit--item-section jackrabbit--item-section__" ++ provider)
                    ]
                    (labelRow :: fileRows)

        itemSections =
            model.providers
                |> Dict.keys
                |> List.sortBy (\provider -> Dict.get provider model.providers |> Maybe.withDefault 0)
                |> List.map (\provider -> ( provider, itemRows provider ))
                |> List.filter (\( provider, rows ) -> List.isEmpty rows == False)
                |> List.map itemSection

        editLibForm =
            model.files
                |> List.map addEditForm

        addFile =
            showAddFile model model.tempFileRow

        tableHeader =
            thead
                []
                [ tr []
                    [ th [ class "jackrabbit--actions" ] []
                    , th [ class "jackrabbit--prefix" ] [ text (localizeString "Path Prefix Name.Header" model.localization) ]
                    , th [ class "jackrabbit--path" ] [ text (localizeString "File Path.Header" model.localization) ]
                    , th [ class "jackrabbit--provider" ] [ text (localizeString "Provider.Header" model.localization) ]
                    , th [ class "jackrabbit--priority" ] [ text (localizeString "Priority.Header" model.localization) ]
                    ]
                ]
    in
        div []
            [ viewErrorMessage model.errorMessage model.localization
            , addFile
            , div []
                editLibForm
            , table [ class "dnnTableDisplay" ]
                (tableHeader :: itemSections)
            ]


viewFileRow : FileRow -> Html Msg
viewFileRow { rowId, file } =
    let
        fileData =
            getFile (file.file)
    in
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


viewErrorMessage : Maybe String -> Dict String String -> Html Msg
viewErrorMessage errorMessage localization =
    case errorMessage of
        Nothing ->
            emptyElement

        Just message ->
            div [ class "dnnFormMessage dnnFormValidationSummary" ] [ text message, button [ type' "button", onClick DismissError ] [ text (localizeString "Dismiss Error" localization) ] ]
