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
            { model | editing = True } ! [] |> withoutParentMsg

        UpdatePrefix prefix ->
            let
                file =
                    model.file

                newFile =
                    { file | pathPrefixName = prefix }
            in
                { model | file = newFile } ! [] |> withoutParentMsg

        UpdatePath path ->
            let
                file =
                    model.file

                newFile =
                    { file | filePath = path }
            in
                { model | file = newFile } ! [] |> withoutParentMsg

        UpdateProvider provider ->
            let
                file =
                    model.file

                newFile =
                    { file | provider = provider }
            in
                { model | file = newFile } ! [] |> withoutParentMsg

        UpdatePriority priority ->
            let
                file =
                    model.file

                newFile =
                    { file | priority = priority }
            in
                { model | file = newFile } ! [] |> withoutParentMsg

        CancelChanges ->
            { model | editing = False, file = model.originalFile } ! [] |> withoutParentMsg

        SaveChanges ->
            let
                verb =
                    if isNothing model.file.id then
                        Post
                    else
                        Put
            in
                model ! [ createAjaxCmd model verb ] |> withoutParentMsg

        DeleteFile ->
            model ! [ createAjaxCmd model Delete ] |> withoutParentMsg

        SaveError errorMessage ->
            model ! [] |> withParentMsg (ParentMsg.SaveError errorMessage)

        RefreshFiles files ->
            model ! [] |> withParentMsg (ParentMsg.RefreshFiles files)


withoutParentMsg : ( Model, Cmd Msg ) -> ( Model, Cmd Msg, ParentMsg )
withoutParentMsg ( model, cmd ) =
    ( model, cmd, ParentMsg.NoOp )


withParentMsg : ParentMsg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg, ParentMsg )
withParentMsg parentMsg ( model, cmd ) =
    ( model, cmd, parentMsg )


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
