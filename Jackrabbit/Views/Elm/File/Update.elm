module Views.Elm.File.Update exposing (..)

import Maybe.Extra exposing (isNothing)
import Task
import Autocomplete
import Views.Elm.Ajax exposing (..)
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.File.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.Utility exposing (localizeString)
import Dom
import String


update : Msg -> Model -> ( Model, Cmd Msg, ParentMsg )
update msg model =
    case msg of
        EditFile ->
            case model.file of
                JavaScriptLib fileData libFile ->
                    ( { model | editing = True }, Cmd.none, ParentMsg.EditLib )

                _ ->
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

        UpdateSpecificity specificity ->
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
                        |> updateLibrary (\libFile -> { libFile | specificity = newSpecificity })
            in
                ( { model | file = library }, Cmd.none, ParentMsg.NoOp )

        CancelChanges ->
            if isNothing (getFile model.file).id then
                case model.editing of
                    False ->
                        ( model, Cmd.none, ParentMsg.CancelTempForm )

                    True ->
                        ( model, Cmd.none, ParentMsg.RemoveFile )
            else
                case model.file of
                    JavaScriptLib _ _ ->
                        ( { model | editing = False, file = model.originalFile }, Cmd.none, ParentMsg.EditLib )

                    _ ->
                        ( { model | editing = False, file = model.originalFile }, Cmd.none, ParentMsg.NoOp )

        SaveChanges ->
            let
                verb =
                    if isNothing (getFile model.file).id then
                        Post
                    else
                        Put
            in
                case model.editing of
                    False ->
                        ( model, createAjaxCmd model verb "file", ParentMsg.AddTempFile model )

                    True ->
                        case model.file of
                            JavaScriptLib fileData libData ->
                                ( model, createAjaxCmd model verb "file", ParentMsg.EditLib )

                            _ ->
                                ( model, createAjaxCmd model verb "file", ParentMsg.NoOp )

        DeleteFile ->
            ( model, createAjaxCmd model Delete "file", ParentMsg.NoOp )

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

        SetQuery newQuery ->
            let
                autocomplete =
                    model.autocomplete

                showMenu =
                    not << List.isEmpty <| (acceptableLibraries newQuery autocomplete.libraries)

                updatedAutocomplete =
                    { autocomplete | query = newQuery, showMenu = showMenu, selectedLibrary = Nothing }

                newModel =
                    updateLibraryName newQuery model
            in
                ( { newModel | autocomplete = updatedAutocomplete }, Cmd.none, ParentMsg.NoOp )

        SetAutoState autoMsg ->
            let
                autocomplete =
                    model.autocomplete

                ( newState, maybeMsg ) =
                    Autocomplete.update updateConfig autoMsg autocomplete.howManyToShow autocomplete.autoState (acceptableLibraries autocomplete.query autocomplete.libraries)

                newAutocomplete =
                    { autocomplete | autoState = newState }
            in
                case maybeMsg of
                    Nothing ->
                        ( { model | autocomplete = newAutocomplete }, Cmd.none, ParentMsg.NoOp )

                    Just updateMsg ->
                        update updateMsg { model | autocomplete = newAutocomplete }

        HandleEscape ->
            let
                autocomplete =
                    model.autocomplete

                validOptions =
                    not <| List.isEmpty (acceptableLibraries autocomplete.query autocomplete.libraries)

                handleEscape =
                    if validOptions then
                        autocomplete
                            |> removeSelection
                            |> resetMenu
                    else
                        { autocomplete | query = "" }
                            |> removeSelection
                            |> resetMenu

                escapedModel =
                    case autocomplete.selectedLibrary of
                        Just library ->
                            if autocomplete.query == library.name then
                                autocomplete
                                    |> resetInput
                            else
                                handleEscape

                        Nothing ->
                            handleEscape
            in
                ( { model | autocomplete = escapedModel }, Cmd.none, ParentMsg.NoOp )

        Wrap toTop ->
            let
                autocomplete =
                    model.autocomplete
            in
                case autocomplete.selectedLibrary of
                    Just library ->
                        update Reset model

                    Nothing ->
                        if toTop then
                            let
                                newAutoComplete =
                                    { autocomplete
                                        | autoState = Autocomplete.resetToLastItem updateConfig (acceptableLibraries autocomplete.query autocomplete.libraries) autocomplete.howManyToShow autocomplete.autoState
                                        , selectedLibrary = List.head <| List.reverse <| List.take autocomplete.howManyToShow <| (acceptableLibraries autocomplete.query autocomplete.libraries)
                                    }
                            in
                                ( { model | autocomplete = newAutoComplete }, Cmd.none, ParentMsg.NoOp )
                        else
                            let
                                newAutoComplete =
                                    { autocomplete
                                        | autoState = Autocomplete.resetToFirstItem updateConfig (acceptableLibraries autocomplete.query autocomplete.libraries) autocomplete.howManyToShow autocomplete.autoState
                                        , selectedLibrary = List.head <| List.take autocomplete.howManyToShow <| (acceptableLibraries autocomplete.query autocomplete.libraries)
                                    }
                            in
                                ( { model | autocomplete = newAutoComplete }, Cmd.none, ParentMsg.NoOp )

        Reset ->
            let
                autocomplete =
                    model.autocomplete

                newAutocomplete =
                    { autocomplete | autoState = Autocomplete.reset updateConfig autocomplete.autoState, selectedLibrary = Nothing }
            in
                ( { model | autocomplete = newAutocomplete }, Cmd.none, ParentMsg.NoOp )

        SelectLibraryKeyboard id ->
            let
                autocomplete =
                    model.autocomplete

                newAutocomplete =
                    setQuery autocomplete id
                        |> resetMenu

                libraryToUpdate =
                    getLibraryAtId autocomplete.libraries id

                newModel =
                    model
                        |> updateLibraryName libraryToUpdate.libName
                        |> updateLibraryVersion libraryToUpdate
            in
                ( { newModel | autocomplete = newAutocomplete }, Cmd.none, ParentMsg.NoOp )

        SelectLibraryMouse id ->
            let
                autocomplete =
                    model.autocomplete

                newAutocomplete =
                    setQuery autocomplete id
                        |> resetMenu

                libraryToUpdate =
                    getLibraryAtId autocomplete.libraries id

                newModel =
                    model
                        |> updateLibraryName libraryToUpdate.libName
                        |> updateLibraryVersion libraryToUpdate
            in
                ( { newModel | autocomplete = newAutocomplete }, Task.perform (\err -> NoOp) (\_ -> NoOp) (Dom.focus "library-input"), ParentMsg.NoOp )

        PreviewLibrary name ->
            let
                autocomplete =
                    model.autocomplete

                newAutocomplete =
                    { autocomplete | selectedLibrary = Just <| getLibraryAtId autocomplete.libraries name }
            in
                ( { model | autocomplete = newAutocomplete }, Cmd.none, ParentMsg.NoOp )

        OnFocus ->
            ( model, Cmd.none, ParentMsg.NoOp )

        NoOp ->
            ( model, Cmd.none, ParentMsg.NoOp )


updateLibraryName : String -> Model -> Model
updateLibraryName libraryName model =
    let
        libFile =
            model.file
                |> getLibrary

        library =
            model.file
                |> updateLibrary (\libFile -> { libFile | libraryName = libraryName })
    in
        { model | file = library }


updateLibraryVersion : Library -> Model -> Model
updateLibraryVersion libraryByName model =
    let
        libFile =
            model.file
                |> getLibrary

        version =
            libraryByName.version

        library =
            model.file
                |> updateLibrary (\libFile -> { libFile | version = version })
    in
        { model | file = library }


resetInput : Autocomplete -> Autocomplete
resetInput autocomplete =
    { autocomplete | query = "" }
        |> removeSelection
        |> resetMenu


removeSelection : Autocomplete -> Autocomplete
removeSelection autocomplete =
    { autocomplete | selectedLibrary = Nothing }


setQuery : Autocomplete -> String -> Autocomplete
setQuery autocomplete id =
    { autocomplete
        | query = .name <| getLibraryAtId autocomplete.libraries id
        , selectedLibrary = Just <| getLibraryAtId autocomplete.libraries id
    }


resetMenu : Autocomplete -> Autocomplete
resetMenu autocomplete =
    { autocomplete
        | autoState = Autocomplete.empty
        , showMenu = False
    }


getLibraryAtId : List Library -> String -> Library
getLibraryAtId libraries id =
    List.filter (\library -> library.name == id) libraries
        |> List.head
        |> Maybe.withDefault (Library "" "" "" 0)


acceptableLibraries : String -> List Library -> List Library
acceptableLibraries query libraries =
    let
        lowerQuery =
            String.toLower query
    in
        List.filter (String.contains lowerQuery << String.toLower << .name) libraries


updateConfig : Autocomplete.UpdateConfig Msg Library
updateConfig =
    Autocomplete.updateConfig
        { toId = .name
        , onKeyDown =
            \code maybeId ->
                if code == 38 || code == 40 then
                    Maybe.map PreviewLibrary maybeId
                else if code == 13 then
                    Maybe.map SelectLibraryKeyboard maybeId
                else
                    Just <| Reset
        , onTooLow = Just <| Wrap False
        , onTooHigh = Just <| Wrap True
        , onMouseEnter = \id -> Just <| PreviewLibrary id
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just <| SelectLibraryMouse id
        , separateSelections = False
        }


createAjaxCmd : Model -> HttpVerb -> String -> Cmd Msg
createAjaxCmd model verb requestType =
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
            AjaxRequestInfo verb path (encodeFile model.file) listFileDecoder requestType
    in
        sendAjax model.httpInfo requestInfo
            |> Task.perform Error RefreshFiles
