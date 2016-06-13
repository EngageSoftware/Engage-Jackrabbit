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
            { model | editing = True } ! [] |> withoutParentMsg

        UpdatePrefix prefix ->
            let
                script =
                    model.script

                newScript =
                    { script | pathPrefixName = prefix }
            in
                { model | script = newScript } ! [] |> withoutParentMsg

        UpdatePath path ->
            let
                script =
                    model.script

                newScript =
                    { script | scriptPath = path }
            in
                { model | script = newScript } ! [] |> withoutParentMsg

        UpdateProvider provider ->
            let
                script =
                    model.script

                newScript =
                    { script | provider = provider }
            in
                { model | script = newScript } ! [] |> withoutParentMsg

        UpdatePriority priority ->
            let
                script =
                    model.script

                newScript =
                    { script | priority = priority }
            in
                { model | script = newScript } ! [] |> withoutParentMsg

        CancelChanges ->
            { model | editing = False, script = model.originalScript } ! [] |> withoutParentMsg

        SaveChanges ->
            let
                verb =
                    if isNothing model.script.id then
                        Post
                    else
                        Put
            in
                model ! [ createAjaxCmd model verb ] |> withoutParentMsg

        DeleteScript ->
            model ! [ createAjaxCmd model Delete ] |> withoutParentMsg

        SaveError errorMessage ->
            model ! [] |> withParentMsg (ParentMsg.SaveError errorMessage)

        RefreshScripts scripts ->
            model ! [] |> withParentMsg (ParentMsg.RefreshScripts scripts)

        _ ->
            model ! [] |> withoutParentMsg


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
