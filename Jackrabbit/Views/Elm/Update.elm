module Views.Elm.Update exposing (update)

import Dict exposing (Dict)
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.File.Model as File exposing (listFileDecoder, initialAutocomplete)
import Views.Elm.File.Msg as File
import Views.Elm.File.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.File.Update as File
import Views.Elm.Utility exposing (createLocalizationDict, localizeString)
import List.Extra exposing (..)
import Maybe.Extra exposing (..)
import Json.Decode as Decode exposing (decodeValue)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init initialDataJson ->
            let
                initializedModel =
                    case (Decode.decodeValue intialDataDecoder initialDataJson) of
                        Err omg ->
                            Debug.crash "HALP"

                        Ok initialData ->
                            let
                                httpInfo =
                                    HttpInfo initialData.httpInfo.baseUrl initialData.httpInfo.headers (localizeString "HTTP Error" localization)

                                localization =
                                    initialData.localization

                                ( fileRows, lastRowId ) =
                                    initialData.files
                                        |> makeFileRows model.lastRowId httpInfo model.providers localization File.initialAutocomplete
                            in
                                Model fileRows
                                    initialData.defaultPathPrefix
                                    initialData.defaultFilePath
                                    initialData.defaultProvider
                                    initialData.defaultPriority
                                    model.providers
                                    lastRowId
                                    Nothing
                                    httpInfo
                                    localization
                                    Nothing
                                    False
            in
                ( initializedModel, Cmd.none )

        AddNewFile ->
            let
                nextRowId =
                    model.lastRowId + 1

                newFile =
                    File.init File.Default
                        Nothing
                        model.defaultPathPrefix
                        model.defaultFilePath
                        model.defaultProvider
                        model.defaultPriority
                        False
                        model.httpInfo
                        model.localization

                newFileRow =
                    FileRow nextRowId newFile
            in
                ( { model | tempFileRow = Just newFileRow, lastRowId = nextRowId }, Cmd.none )

        DismissError ->
            ( { model | errorMessage = Nothing }, Cmd.none )

        FileMsg rowId msg ->
            let
                matchingFileRow =
                    model.files
                        |> List.Extra.find (findRow rowId)

                fileRow =
                    Maybe.oneOf [ matchingFileRow, model.tempFileRow ]

                fileUpdate =
                    fileRow
                        |> Maybe.map (updateFile rowId msg)

                cmd =
                    fileUpdate
                        |> Maybe.map (\( file, cmd, parentMsg ) -> cmd)
                        |> Maybe.withDefault Cmd.none

                file =
                    fileUpdate
                        |> Maybe.map (\( file, cmd, parentMsg ) -> file)

                updatedModel =
                    case file of
                        Nothing ->
                            { model | errorMessage = Just "Error: Impossible State" }

                        Just f ->
                            if Maybe.Extra.isNothing matchingFileRow then
                                { model | tempFileRow = Just f }
                            else
                                { model | files = List.Extra.replaceIf (\fr -> fr.rowId == rowId) f model.files }

                modelWithParentMsgs =
                    fileUpdate
                        |> Maybe.map (updateFromChild updatedModel)
                        |> Maybe.withDefault model
            in
                ( modelWithParentMsgs, cmd )


findRow : Int -> FileRow -> Bool
findRow rowId fileRow =
    if fileRow.rowId == rowId then
        True
    else
        False


updateFromChild : Model -> ( FileRow, Cmd msg, ParentMsg ) -> Model
updateFromChild model ( fileRow, _, parentMsg ) =
    case parentMsg of
        ParentMsg.NoOp ->
            model

        ParentMsg.RemoveFile ->
            let
                updatedFiles =
                    model.files
                        |> List.filter (\s -> s.rowId /= fileRow.rowId)
            in
                { model | files = updatedFiles }

        ParentMsg.Error errorMessage ->
            { model | errorMessage = Just errorMessage }

        ParentMsg.RefreshFiles files ->
            let
                ( fileRows, lastRowId ) =
                    files
                        |> makeFileRows model.lastRowId model.httpInfo model.providers model.localization File.initialAutocomplete
            in
                { model | files = fileRows, lastRowId = lastRowId }

        ParentMsg.AddTempFile file ->
            let
                newFileRow =
                    { rowId = model.lastRowId, file = file }
            in
                { model | files = newFileRow :: model.files, tempFileRow = Nothing }

        ParentMsg.CancelTempForm ->
            let
                newLastRow =
                    model.lastRowId - 1
            in
                { model | lastRowId = newLastRow, tempFileRow = Nothing }

        ParentMsg.EditLib ->
            case model.editing of
                False ->
                    { model | editing = True }

                True ->
                    { model | editing = False }


updateFile : Int -> File.Msg -> FileRow -> ( FileRow, Cmd Msg, ParentMsg )
updateFile targetRowId msg fileRow =
    if targetRowId /= fileRow.rowId then
        ( fileRow, Cmd.none, ParentMsg.NoOp )
    else
        let
            ( updatedRow, cmd, parentMsg ) =
                File.update msg fileRow.file
        in
            ( FileRow fileRow.rowId updatedRow, Cmd.map (FileMsg fileRow.rowId) cmd, parentMsg )


makeFileRows : Int -> HttpInfo -> Dict String Int -> Dict String String -> File.Autocomplete -> List File.JackRabbitFile -> ( List FileRow, Int )
makeFileRows lastRowId httpInfo providers localization autocomplete files =
    let
        nextRowId =
            lastRowId + 1
    in
        case files of
            [] ->
                ( [], nextRowId )

            file :: otherFiles ->
                let
                    fileModel =
                        File.fromJRFile file
                            False
                            httpInfo
                            localization
                            autocomplete

                    fileRow =
                        FileRow nextRowId fileModel

                    ( otherFileRows, lastRowId ) =
                        otherFiles
                            |> makeFileRows nextRowId httpInfo providers localization File.initialAutocomplete

                    sortedFileRows =
                        fileRow
                            :: otherFileRows
                            |> List.sortWith (compareFileRows providers)
                in
                    ( sortedFileRows, lastRowId )


compareFileRows : Dict String Int -> FileRow -> FileRow -> Basics.Order
compareFileRows providers first second =
    File.compareModels providers first.file second.file


intialDataDecoder : Decode.Decoder InitialData
intialDataDecoder =
    decode InitialData
        |> required "files" listFileDecoder
        |> required "defaultPathPrefix" Decode.string
        |> required "defaultFilePath" Decode.string
        |> required "defaultProvider" Decode.string
        |> required "defaultPriority" Decode.int
        |> required "httpInfo" httpDecoder
        |> required "localization" decodeLocalization


decodeLocalization : Decode.Decoder (Dict String String)
decodeLocalization =
    Decode.dict Decode.string


decodeHttpHeaders : Decode.Decoder (List ( String, String ))
decodeHttpHeaders =
    Decode.list stringTupleDecoder


stringTupleDecoder : Decode.Decoder ( String, String )
stringTupleDecoder =
    Decode.tuple2 (,) Decode.string Decode.string


httpDecoder : Decode.Decoder InitialHttpInfo
httpDecoder =
    decode InitialHttpInfo
        |> required "baseUrl" Decode.string
        |> required "headers" decodeHttpHeaders



--JavaScriptLibrary library file -> file
