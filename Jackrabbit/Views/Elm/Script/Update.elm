module Views.Elm.Script.Update exposing (..)

import Maybe.Extra exposing (isNothing)
import Task
import Views.Elm.Ajax exposing (..)
import Views.Elm.Script.Model exposing (..)
import Views.Elm.Script.Msg exposing (..)
import Views.Elm.Script.ParentMsg as ParentMsg exposing (ParentMsg)


update : Msg -> Model -> ( Model, Cmd Msg, ParentMsg )
update msg model =
    case msg of
        EditScript ->
            ( { model | editing = True }, Cmd.none, ParentMsg.NoOp )

        UpdatePrefix prefix ->
            let
                script =
                    model.script

                newScript =
                    { script | pathPrefixName = prefix }
            in
                ( { model | script = newScript }, Cmd.none, ParentMsg.NoOp )

        UpdatePath path ->
            let
                script =
                    model.script

                newScript =
                    { script | scriptPath = path }
            in
                ( { model | script = newScript }, Cmd.none, ParentMsg.NoOp )

        UpdateProvider provider ->
            let
                script =
                    model.script

                newScript =
                    { script | provider = provider }
            in
                ( { model | script = newScript }, Cmd.none, ParentMsg.NoOp )

        UpdatePriority priority ->
            let
                script =
                    model.script

                newScript =
                    { script | priority = priority }
            in
                ( { model | script = newScript }, Cmd.none, ParentMsg.NoOp )

        CancelChanges ->
            ( { model | editing = False, script = model.originalScript }, Cmd.none, ParentMsg.NoOp )

        SaveChanges ->
            let
                verb =
                    if isNothing model.script.id then
                        Post
                    else
                        Put
            in
                ( model, createAjaxCmd model verb, ParentMsg.NoOp )

        DeleteScript ->
            ( model, createAjaxCmd model Delete, ParentMsg.NoOp )

        SaveError errorMessage ->
            ( model, Cmd.none, ParentMsg.SaveError errorMessage )

        RefreshScripts scripts ->
            ( model, Cmd.none, ParentMsg.RefreshScripts scripts )


createAjaxCmd : Model -> HttpVerb -> Cmd Msg
createAjaxCmd model verb =
    let
        path =
            case model.script.id of
                Just id ->
                    "?id=" ++ (toString id)

                Nothing ->
                    ""

        requestInfo =
            AjaxRequestInfo verb path (encodeScript model.script) listScriptDecoder
    in
        sendAjax model.httpInfo requestInfo
            |> Task.perform SaveError RefreshScripts
