module Views.Elm.File.Update exposing (..)

import Maybe.Extra exposing (isNothing)
import Task
import Views.Elm.Ajax exposing (..)
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.File.ParentMsg as ParentMsg exposing (ParentMsg)


update : Msg -> Model -> ( Model, Cmd Msg, ParentMsg )
update msg model =
    case msg of
        EditFile ->
            ( { model | editing = True }, Cmd.none, ParentMsg.NoOp )

        UpdatePrefix prefix ->
            let
                file =
                    model.file

                newFile =
                    { file | pathPrefixName = prefix }
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        UpdatePath path ->
            let
                file =
                    model.file

                newFile =
                    { file | filePath = path }
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        UpdateProvider provider ->
            let
                file =
                    model.file

                newFile =
                    { file | provider = provider }
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        UpdatePriority priority ->
            let
                file =
                    model.file

                newFile =
                    { file | priority = priority }
            in
                ( { model | file = newFile }, Cmd.none, ParentMsg.NoOp )

        CancelChanges ->
            if isNothing model.file.id then
                ( model, Cmd.none, ParentMsg.RemoveFile )
            else
                ( { model | editing = False, file = model.originalFile }, Cmd.none, ParentMsg.NoOp )

        SaveChanges ->
            let
                verb =
                    if isNothing model.file.id then
                        Post
                    else
                        Put
            in
                ( model, createAjaxCmd model verb, ParentMsg.NoOp )

        DeleteFile ->
            ( model, createAjaxCmd model Delete, ParentMsg.NoOp )

        SaveError errorMessage ->
            ( model, Cmd.none, ParentMsg.SaveError errorMessage )

        RefreshFiles files ->
            ( model, Cmd.none, ParentMsg.RefreshFiles files )


createAjaxCmd : Model -> HttpVerb -> Cmd Msg
createAjaxCmd model verb =
    let
        path =
            case model.file.id of
                Just id ->
                    "?id=" ++ (toString id)

                Nothing ->
                    ""

        requestInfo =
            AjaxRequestInfo verb path (encodeFile model.file) listFileDecoder
    in
        sendAjax model.httpInfo requestInfo
            |> Task.perform SaveError RefreshFiles
