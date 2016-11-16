module Views.Elm.Tests.MainUpdateTests exposing (tests)

import Test exposing (..)
import Expect exposing (Expectation)
import Fuzz as Fuzz
import Views.Elm.Tests.TestUtilities exposing (..)
import Views.Elm.File.ParentMsg as ParentMsg exposing (..)
import Views.Elm.Utility exposing (localizeString)
import Views.Elm.Model exposing (..)
import Views.Elm.Update exposing (update, updateFromChild)
import Views.Elm.Msg exposing (..)
import Dict as Dict
import Views.Elm.File.Model as FileModel
import Json.Encode as Json


tests : List Test
tests =
    [ describe "Main Model Update Tests"
        [ describe "updateFromChild Function/ParentMsg"
            [ test "Remove File" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        expectedModel =
                            { model | fileRows = [ (FileRow 1 initialLibraryModel) ] }

                        returnedModel =
                            updateFromChild model ( fakeFileRow, Cmd.none, ParentMsg.RemoveFile )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Error Message" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        expectedModel =
                            { model | errorMessage = (Just "Error") }

                        returnedModel =
                            updateFromChild model ( fakeFileRow, Cmd.none, (ParentMsg.Error "Error") )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Add Temp Form" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        fileRow =
                            FileRow 1 initialFileModel

                        expectedModel =
                            { model | fileRows = fileRow :: model.fileRows }

                        returnedModel =
                            updateFromChild model ( fakeFileRow, Cmd.none, (ParentMsg.AddTempFile initialFileModel) )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Cancel Temp Form" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        newRow =
                            model.lastRowId - 1

                        updateModel =
                            { model | tempFileRow = Just initialFileModel }

                        expectedModel =
                            { initialBaseModel | lastRowId = newRow }

                        returnedModel =
                            updateFromChild model ( (FileRow 1 initialLibraryModel), Cmd.none, ParentMsg.CancelTempForm )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Turn Editing to True" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        expectedModel =
                            { model | editing = True }

                        returnedModel =
                            updateFromChild model ( fakeFileRow, Cmd.none, ParentMsg.Editing )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Turn Editing to False" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        expectedModel =
                            model

                        updatedModel =
                            { model | editing = True }

                        returnedModel =
                            updateFromChild updatedModel ( fakeFileRow, Cmd.none, ParentMsg.Editing )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Test Add Suggested Files" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        expectedModel =
                            { model | suggestedFiles = [] }

                        returnedModel =
                            updateFromChild model ( fakeFileRow, Cmd.none, ParentMsg.AddSuggestion )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Test Remove Suggestion" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        expectedModel =
                            { model | suggestedFiles = [], fileRows = [ (FileRow 1 initialLibraryModel) ] }

                        returnedModel =
                            updateFromChild model ( fakeFileRow, Cmd.none, ParentMsg.RemoveSuggestion )
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            ]
        , describe "Update Functions"
            [ test "Init Model Json" <|
                \() ->
                    let
                        json =
                            Json.object
                                [ ( "files"
                                  , Json.list
                                        [ Json.object
                                            [ ( "FileType", Json.int 1 )
                                            , ( "Id", Json.int 1 )
                                            , ( "PathPrefixName", Json.string "PathName" )
                                            , ( "FilePath", Json.string "~/path/here" )
                                            , ( "Provider", Json.string "DnnFormBottomProvider" )
                                            , ( "Priority", Json.int 100 )
                                            ]
                                        ]
                                  )
                                , ( "httpInfo"
                                  , Json.object
                                        [ ( "baseUrl", Json.string "" )
                                        , ( "headers", Json.list [] )
                                        ]
                                  )
                                , ( "localization"
                                  , Json.object
                                        [ ( "Add.Text", Json.string "Add" )
                                        , ( "Cancel.Text", Json.string "Cancel" )
                                        , ( "Delete.Text", Json.string "Delete" )
                                        ]
                                  )
                                , ( "pathAliases", Json.list [] )
                                ]

                        model =
                            initialModel

                        newLocalization =
                            Dict.fromList [ ( "Add.Text", "Add" ), ( "Cancel.Text", "Cancel" ), ( "Delete.Text", "Delete" ) ]

                        jackrabbitFile =
                            (FileModel.CssFile (FileModel.FileData (Just 1) "PathName" "~/path/here" "DnnFormBottomProvider" 100))

                        newFile =
                            initialFileModel

                        appliedFile =
                            { newFile | localization = newLocalization, file = jackrabbitFile, originalFile = jackrabbitFile, pathList = [] }

                        newFileRow =
                            FileRow 1 appliedFile

                        message =
                            Init json

                        expectedModel =
                            { model | lastRowId = 2, localization = newLocalization, defaultProvider = "DnnFormBottomProvider", defaultFilePath = "", pathAliases = [], defaultPriority = 100, fileRows = [ newFileRow ] }

                        ( returnedModel, command ) =
                            update message model
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Critical Error" <|
                \() ->
                    let
                        json =
                            Json.object
                                [ ( "files"
                                  , Json.list
                                        [ Json.object
                                            [ ( "FileType", Json.int 1 )
                                            , ( "Id", Json.int 1 )
                                            , ( "PathPrefixName", Json.string "PathName" )
                                            , ( "FilePath", Json.string "~/path/here" )
                                            , ( "Provider", Json.string "DnnFormBottomProvider" )
                                            , ( "Priority", Json.int 100 )
                                            ]
                                        ]
                                  )
                                ]

                        model =
                            initialModel

                        expectedModel =
                            { model | criticalError = True }

                        message =
                            Init json

                        ( returnedModel, command ) =
                            update message model
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "AddNewFile Test" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        newFileModel =
                            { initialFileModel | choosingType = True }

                        expectedModel =
                            { model | tempFileRow = (Just (FileRow 2 (emptyFileModel emptyJavaScriptFile))), lastRowId = 2 }

                        ( returnedModel, command ) =
                            update AddNewFile model
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            , test "Dismiss Error" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        errorModel =
                            { model | errorMessage = Nothing }

                        ( returnedModel, command ) =
                            update DismissError model
                    in
                        returnedModel
                            |> Expect.equal errorModel
            , test "Dismiss All" <|
                \() ->
                    let
                        model =
                            initialBaseModel

                        expectedModel =
                            { model | suggestedFiles = [] }

                        ( returnedModel, command ) =
                            update DismissAll model
                    in
                        returnedModel
                            |> Expect.equal expectedModel
            ]
        ]
    ]


fakeFileRow : FileRow
fakeFileRow =
    (FileRow 0 initialFileModel)


fakeListFileRow : List FileRow
fakeListFileRow =
    [ fakeFileRow
    , (FileRow 1 initialLibraryModel)
    ]


initialBaseModel : Model
initialBaseModel =
    { initialModel | lastRowId = 1, fileRows = fakeListFileRow }
