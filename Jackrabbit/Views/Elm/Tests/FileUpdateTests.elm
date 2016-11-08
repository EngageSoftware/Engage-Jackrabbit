module Views.Elm.Tests.FileUpdateTests exposing (tests)

import Test exposing (..)
import Expect exposing (Expectation)
import Views.Elm.File.Model exposing (..)
import Fuzz as Fuzz
import Views.Elm.Tests.TestUtilities exposing (..)
import Views.Elm.File.Update exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.File.ParentMsg as ParentMsg exposing (..)
import Views.Elm.Utility exposing (localizeString)
import Autocomplete exposing (State)


tests : List Test
tests =
    [ describe "File Model Update Tests"
        [ describe "Update Model Functions"
            [ fuzz Fuzz.string "Update Prefix" <|
                \newPrefix ->
                    let
                        model =
                            initialFileModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (UpdatePrefix newPrefix) model
                    in
                        updatedModel.file
                            |> getFile
                            |> .pathPrefixName
                            |> Expect.equal newPrefix
            , fuzz Fuzz.string "Update Path" <|
                \newPath ->
                    let
                        model =
                            initialFileModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (UpdatePath newPath) model
                    in
                        updatedModel.file
                            |> getFile
                            |> .filePath
                            |> Expect.equal newPath
            , fuzz Fuzz.string "Update Provider" <|
                \newProvider ->
                    let
                        model =
                            initialFileModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (UpdateProvider newProvider) model
                    in
                        updatedModel.file
                            |> getFile
                            |> .provider
                            |> Expect.equal newProvider
            , fuzz (Fuzz.intRange -10000 10000) "Update Priority" <|
                \newPriority ->
                    let
                        model =
                            initialFileModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (UpdatePriority newPriority) model
                    in
                        updatedModel.file
                            |> getFile
                            |> .priority
                            |> Expect.equal newPriority
            , fuzz Fuzz.string "Update LibraryName" <|
                \newLibName ->
                    let
                        model =
                            initialLibraryModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (UpdateLibraryName newLibName) model
                    in
                        updatedModel.file
                            |> getLibrary
                            |> .libraryName
                            |> Expect.equal newLibName
            , fuzz versionFuzzer "Update Version" <|
                \newVersion ->
                    let
                        model =
                            initialLibraryModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (UpdateVersion newVersion) model
                    in
                        updatedModel.file
                            |> getLibrary
                            |> .version
                            |> Expect.equal newVersion
            , fuzz (Fuzz.intRange 0 3) "Update Provider" <|
                \number ->
                    let
                        newSpecificity =
                            case number of
                                0 ->
                                    "Latest"

                                1 ->
                                    "LatestMajor"

                                2 ->
                                    "LatestMinor"

                                3 ->
                                    "Exact"

                                _ ->
                                    "The fuzzer broke!"

                        model =
                            initialLibraryModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (UpdateSpecificity newSpecificity) model
                    in
                        updatedModel.file
                            |> getLibrary
                            |> .specificity
                            |> toString
                            |> Expect.equal newSpecificity
            ]
        , describe "Cancel Changes"
            [ test "can Cancel Temp Form" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        fileData =
                            getFile model.file

                        file =
                            model.file

                        noFileId =
                            { fileData | id = Nothing }

                        missingjackrabbit =
                            JavaScriptFile noFileId

                        finalModel =
                            { model | file = missingjackrabbit }

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update CancelChanges finalModel
                    in
                        parentMsg
                            |> Expect.equal ParentMsg.CancelTempForm
            , test "can Remove File" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        fileData =
                            getFile model.file

                        file =
                            model.file

                        noFileId =
                            { fileData | id = Nothing }

                        missingjackrabbit =
                            JavaScriptFile noFileId

                        finalModel =
                            { model | file = missingjackrabbit, editing = True }

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update CancelChanges finalModel
                    in
                        parentMsg
                            |> Expect.equal ParentMsg.RemoveFile
            , test "can Edit Lib" <|
                \() ->
                    let
                        model =
                            initialLibraryModel

                        editingModel =
                            { model | editing = True }

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update CancelChanges editingModel

                        editing =
                            updatedModel.editing

                        originalFileData =
                            getFile updatedModel.originalFile
                    in
                        ( editing, parentMsg, originalFileData )
                            |> Expect.equal ( False, ParentMsg.Editing, (getFile model.file) )
            ]
        , describe "can SaveChanges"
            [ test "can Add TempFile" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        fileData =
                            getFile model.file

                        file =
                            model.file

                        noFileId =
                            { fileData | id = Nothing }

                        missingjackrabbit =
                            JavaScriptFile noFileId

                        finalModel =
                            { model | file = missingjackrabbit }

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update SaveFileChanges finalModel
                    in
                        parentMsg
                            |> Expect.equal (ParentMsg.AddTempFile finalModel)
            , test "can Editing" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        fileData =
                            getFile model.file

                        file =
                            model.file

                        noFileId =
                            { fileData | id = Nothing }

                        missingjackrabbit =
                            JavaScriptFile noFileId

                        finalModel =
                            { model | editing = True }

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update SaveFileChanges finalModel
                    in
                        parentMsg
                            |> Expect.equal ParentMsg.Editing
            ]
        , describe "can SaveLibraryChanges"
            [ test "can Add TempFile" <|
                \() ->
                    let
                        model =
                            initialLibraryModel

                        fileData =
                            getFile model.file

                        file =
                            model.file

                        libData =
                            getLibrary model.file

                        noFileId =
                            { fileData | id = Nothing }

                        missingjackrabbit =
                            JavaScriptLib noFileId libData

                        finalModel =
                            { model | file = missingjackrabbit }

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update SaveLibraryChanges finalModel
                    in
                        parentMsg
                            |> Expect.equal (ParentMsg.AddTempFile finalModel)
            , test "can Editing" <|
                \() ->
                    let
                        model =
                            initialLibraryModel

                        fileData =
                            getFile model.file

                        file =
                            model.file

                        noFileId =
                            { fileData | id = Nothing }

                        missingjackrabbit =
                            JavaScriptLib noFileId

                        finalModel =
                            { model | editing = True }

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update SaveLibraryChanges finalModel
                    in
                        parentMsg
                            |> Expect.equal ParentMsg.Editing
            ]
        , describe "Delete File"
            [ test "can Delete" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update DeleteFile model
                    in
                        parentMsg
                            |> Expect.equal ParentMsg.NoOp
            ]
        , describe "Error Msg"
            [ test "Error's out" <|
                \() ->
                    let
                        modelError =
                            Views.Elm.File.Msg.Error "There was an error"

                        model =
                            initialFileModel

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update modelError model
                    in
                        parentMsg
                            |> Expect.equal (ParentMsg.Error "There was an error")
            ]
        , describe "Refresh Files"
            [ test "Refreshes Files" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        listFiles =
                            []

                        refreshFiles =
                            Views.Elm.File.Msg.RefreshFiles listFiles

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update refreshFiles model
                    in
                        parentMsg
                            |> Expect.equal (ParentMsg.RefreshFiles listFiles)
            ]
        , describe "File type tests"
            [ fuzz (Fuzz.intRange 0 1) "Set File success" <|
                \number ->
                    let
                        model =
                            initialFileModel

                        newType =
                            case number of
                                0 ->
                                    "JavaScript"

                                1 ->
                                    "Css"

                                _ ->
                                    "The fuzzer broke"

                        file =
                            model.file

                        fileData =
                            getFile file

                        cssFileData =
                            { fileData | provider = "DnnPageHeaderProvider" }

                        message =
                            SetFileType newType file

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update message model

                        expectedFile =
                            case number of
                                0 ->
                                    (JavaScriptFile (fileData))

                                1 ->
                                    (CssFile (cssFileData))

                                _ ->
                                    (Default (fileData))
                    in
                        updatedModel.file
                            |> Expect.equal expectedFile
            , test "Set Type crash" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        string =
                            "Failure!"

                        file =
                            model.file

                        message =
                            SetFileType string file

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update message model

                        errorMessage =
                            (localizeString "Invalid File Type" model.localization)
                    in
                        parentMsg
                            |> Expect.equal (ParentMsg.Error errorMessage)
            , test "Set Library" <|
                \() ->
                    let
                        model =
                            initialFileModel

                        file =
                            model.file

                        fileData =
                            getFile file

                        expectedLibrary =
                            JavaScriptLib (fileData) (LibraryData "" "" Exact)

                        ( updatedModel, cmdMsg, parentMsg ) =
                            update (SetLibrary file) model
                    in
                        updatedModel.file
                            |> Expect.equal expectedLibrary
            ]
        ]
    , describe "Autocomplete functionality Messages"
        [ test "Requesting Libraries" <|
            \() ->
                let
                    model =
                        initialFileModel

                    listLibraries =
                        []

                    requestLibraries =
                        RequestLibraries listLibraries

                    ( updatedModel, cmdMsg, parentMsg ) =
                        update requestLibraries model
                in
                    updatedModel.autocomplete
                        |> .libraries
                        |> Expect.equal listLibraries
        , test "No Operation" <|
            \() ->
                let
                    model =
                        initialFileModel

                    message =
                        Views.Elm.File.Msg.NoOp

                    ( updatedModel, cmdMsg, parentMsg ) =
                        update message model
                in
                    ( updatedModel, parentMsg )
                        |> Expect.equal ( model, ParentMsg.NoOp )
        , test "On Focus" <|
            \() ->
                let
                    model =
                        initialFileModel

                    message =
                        Views.Elm.File.Msg.OnFocus

                    ( updatedModel, cmdMsg, parentMsg ) =
                        update message model
                in
                    ( updatedModel, parentMsg )
                        |> Expect.equal ( model, ParentMsg.NoOp )
        , test "Preview Library" <|
            \() ->
                let
                    model =
                        initialFileModel

                    listLibrary =
                        basicListOfLibraries

                    autocomplete =
                        model.autocomplete

                    updatedAutocomplete =
                        { autocomplete | libraries = basicListOfLibraries }

                    realModel =
                        { model | autocomplete = updatedAutocomplete }

                    expectedAutocomplete =
                        { updatedAutocomplete | selectedLibrary = Just (Library "Test3" "3.3.3" "Test3 3.3.3") }

                    message =
                        PreviewLibrary "Test3 3.3.3"

                    ( updatedModel, cmdMsg, parentMsg ) =
                        update message realModel
                in
                    updatedModel.autocomplete
                        |> Expect.equal expectedAutocomplete
        , test "Select Library at Mouse" <|
            \() ->
                let
                    model =
                        initialLibraryModel

                    listLibrary =
                        basicListOfLibraries

                    autocomplete =
                        model.autocomplete

                    updatedAutocomplete =
                        { autocomplete | libraries = basicListOfLibraries }

                    realModel =
                        { model | autocomplete = updatedAutocomplete }

                    expectedAutocomplete =
                        { updatedAutocomplete | selectedLibrary = Just (Library "Test3" "3.3.3" "Test3 3.3.3"), query = "Test3 3.3.3" }

                    message =
                        SelectLibraryMouse "Test3 3.3.3"

                    ( updatedModel, cmdMsg, parentMsg ) =
                        update message realModel
                in
                    updatedModel.autocomplete
                        |> Expect.equal expectedAutocomplete
        , test "Select Library Keyboard" <|
            \() ->
                let
                    model =
                        initialLibraryModel

                    listLibrary =
                        basicListOfLibraries

                    autocomplete =
                        model.autocomplete

                    updatedAutocomplete =
                        { autocomplete | libraries = basicListOfLibraries }

                    realModel =
                        { model | autocomplete = updatedAutocomplete }

                    expectedAutocomplete =
                        { updatedAutocomplete | selectedLibrary = Just (Library "Test3" "3.3.3" "Test3 3.3.3"), query = "Test3 3.3.3" }

                    message =
                        SelectLibraryKeyboard "Test3 3.3.3"

                    ( updatedModel, cmdMsg, parentMsg ) =
                        update message realModel
                in
                    updatedModel.autocomplete
                        |> Expect.equal expectedAutocomplete
        , test "Reset autocomplete" <|
            \() ->
                let
                    model =
                        initialLibraryModel

                    autocomplete =
                        model.autocomplete

                    testAutocomplete =
                        { autocomplete | autoState = Autocomplete.reset updateConfig autocomplete.autoState, selectedLibrary = Nothing }

                    ( finalModel, cmdMsgmsg, parentMsg ) =
                        update Reset model
                in
                    finalModel.autocomplete
                        |> Expect.equal testAutocomplete
        , test "Testing Wrap" <|
            \() ->
                let
                    model =
                        initialLibraryModel

                    autocomplete =
                        model.autocomplete

                    tempAutocomplete =
                        { autocomplete | selectedLibrary = Just (Library "Knockout 1.1.1" "1.1.1" "Knockout") }

                    tempModel =
                        { model | autocomplete = tempAutocomplete }

                    ( newModel, cmdMsg, parentMsg ) =
                        update (Wrap True) tempModel

                    newModelAutocomplete =
                        newModel.autocomplete
                in
                    newModelAutocomplete
                        |> Expect.equal autocomplete
        , test "Test Handle Escape - no selected Library" <|
            \() ->
                let
                    model =
                        initialFileModel

                    fileAuto =
                        model.autocomplete

                    tempAutoWithLibs =
                        { fileAuto | libraries = basicListOfLibraries }

                    modelWithLibraries =
                        { model | autocomplete = tempAutoWithLibs }

                    expectedAutocomplete =
                        tempAutoWithLibs

                    ( returnedModel, cmdMsg, parentMsg ) =
                        update HandleEscape modelWithLibraries
                in
                    returnedModel.autocomplete
                        |> Expect.equal expectedAutocomplete
        , test "Test Handle Escape - selected Library == query" <|
            \() ->
                let
                    model =
                        initialFileModel

                    fileAuto =
                        model.autocomplete

                    tempAutoWithLibs =
                        { fileAuto | libraries = basicListOfLibraries, selectedLibrary = (Just (Library "Test1" "1.1.1" "Test1 1.1.1")), query = "Test1 " }

                    modelWithLibraries =
                        { model | autocomplete = tempAutoWithLibs }

                    expectedAutocomplete =
                        { tempAutoWithLibs | selectedLibrary = Nothing }

                    ( returnedModel, cmdMsg, parentMsg ) =
                        update HandleEscape modelWithLibraries
                in
                    returnedModel.autocomplete
                        |> Expect.equal expectedAutocomplete
        , test "Test Handle Escape - selected Library =/= query" <|
            \() ->
                let
                    model =
                        initialFileModel

                    fileAuto =
                        model.autocomplete

                    tempAutoWithLibs =
                        { fileAuto | libraries = basicListOfLibraries, selectedLibrary = (Just (Library "Test1" "1.1.1" "Test1 1.1.1")), query = "Test5" }

                    modelWithLibraries =
                        { model | autocomplete = tempAutoWithLibs }

                    expectedAutocomplete =
                        { tempAutoWithLibs | selectedLibrary = Nothing, query = "" }

                    ( returnedModel, cmdMsg, parentMsg ) =
                        update HandleEscape modelWithLibraries
                in
                    returnedModel.autocomplete
                        |> Expect.equal expectedAutocomplete
        , test "Set Query" <|
            \() ->
                let
                    model =
                        initialLibraryModel

                    query =
                        "Test1"

                    auto =
                        model.autocomplete

                    updatedAutocomplete =
                        { auto | libraries = basicListOfLibraries }

                    expectedAuto =
                        { auto | query = "Test1", libraries = basicListOfLibraries, showMenu = True }

                    updatedModel =
                        { model | autocomplete = updatedAutocomplete }

                    ( returnedModel, cmdMsg, parentMsg ) =
                        update (SetQuery query) updatedModel
                in
                    returnedModel.autocomplete
                        |> Expect.equal expectedAuto
        ]
    ]
