module Views.Elm.File.Update exposing (..)

import Maybe.Extra exposing (isNothing)
import Task
import Views.Elm.Ajax exposing (..)
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.File.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.Utility exposing (localizeString)


update : Msg -> Model -> ( Model, Cmd Msg, ParentMsg )
update msg model =
    case msg of
        EditFile ->
            ( { model | editing = True }, Cmd.none, ParentMsg.NoOp )

        UpdatePrefix prefix ->
            let
                newFile =
                    model.file
                        |> updateFile (\file -> { file | pathPrefixName = prefix })
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        UpdatePath path ->
            let
                newFile =
                    model.file
                        |> updateFile (\file -> { file | filePath = path })
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        UpdateProvider provider ->
            let
                newFile =
                    model.file
                        |> updateFile (\file -> { file | provider = provider })
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        UpdatePriority priority ->
            let
                newFile =
                    model.file
                        |> updateFile (\file -> { file | priority = priority })
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        UpdateLibraryName libraryName ->
            let
                libFile =
                    model.file
                        |> getLibrary

                library =
                    model.file
                        |> updateLibrary (\libFile -> { libFile | libraryName = libraryName })
            in
                ( { model | file = library }, Cmd.none, ParentMsg.NoOp )

        UpdateVersion version ->
            let
                libFile =
                    model.file
                        |> getLibrary

                library =
                    model.file
                        |> updateLibrary (\libFile -> { libFile | version = version })
            in
                ( { model | file = library }, Cmd.none, ParentMsg.NoOp )

        UpdateVersionSpecificity specificity ->
            let
                libFile =
                    model.file
                        |> getLibrary

                newSpecificity =
                    case specificity of
                        "Exact" ->
                            Exact

                        "LatestMinor" ->
                            LatestMinor

                        "LatestMajor" ->
                            LatestMajor

                        "Latest" ->
                            Latest

                        _ ->
                            Exact

                library =
                    model.file
                        |> updateLibrary (\libFile -> { libFile | versionSpecificity = newSpecificity })
            in
                ( { model | file = library }, Cmd.none, ParentMsg.NoOp )

        CancelChanges ->
            if isNothing (getFile model.file).id then
                ( model, Cmd.none, ParentMsg.RemoveFile )
            else
                ( { model | editing = False, file = model.originalFile }, Cmd.none, ParentMsg.NoOp )

        SaveChanges ->
            let
                verb =
                    if isNothing (getFile model.file).id then
                        Post
                    else
                        Put
            in
                ( model, createAjaxCmd model verb, ParentMsg.NoOp )

        SaveTempForm ->
            let
                verb =
                    if isNothing (getFile model.file).id then
                        Post
                    else
                        Put
            in
                ( model, createAjaxCmd model verb, ParentMsg.AddTempFile model )

        CancelTempForm ->
            ( model, Cmd.none, ParentMsg.CancelTempForm )

        DeleteFile ->
            ( model, createAjaxCmd model Delete, ParentMsg.NoOp )

        Error errorMessage ->
            ( model, Cmd.none, ParentMsg.Error errorMessage )

        RefreshFiles files ->
            ( model, Cmd.none, ParentMsg.RefreshFiles files )

        SetFileType string file ->
            let
                fileData =
                    getFile file
            in
                case string of
                    "JavaScript" ->
                        ( { model | file = JavaScriptFile fileData }, Cmd.none, ParentMsg.NoOp )

                    "Css" ->
                        ( { model | file = CssFile fileData }, Cmd.none, ParentMsg.NoOp )

                    _ ->
                        ( model, Cmd.none, ParentMsg.Error (localizeString "Invalid File Type" model.localization) )

        SetLibrary file ->
            let
                fileData =
                    getFile file

                libData =
                    LibraryData "" "" Exact
            in
                ( { model | file = JavaScriptLib fileData libData }, Cmd.none, ParentMsg.NoOp )


createAjaxCmd : Model -> HttpVerb -> Cmd Msg
createAjaxCmd model verb =
    let
        fileData =
            getFile model.file

        path =
            case fileData.id of
                Just id ->
                    "?id=" ++ (toString id)

                Nothing ->
                    ""

        requestInfo =
            AjaxRequestInfo verb path (encodeFile model.file) listFileDecoder
    in
        sendAjax model.httpInfo requestInfo
            |> Task.perform Error RefreshFiles
