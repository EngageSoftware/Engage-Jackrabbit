module Views.Elm.Script.Update exposing (..)

import Task
import Views.Elm.Ajax exposing (..)
import Views.Elm.Script.Model exposing (..)
import Views.Elm.Script.Msg exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditScript ->
            { model | editing = True } ! []

        UpdatePrefix prefix ->
            let
                script = model.script
                newScript = { script | pathPrefixName = prefix }
            in
                { model | script = newScript } ! []

        UpdatePath path ->
            let
                script = model.script
                newScript = { script | scriptPath = path }
            in
                { model | script = newScript } ! []

        UpdateProvider provider ->
            let
                script = model.script
                newScript = { script | provider = provider }
            in
                { model | script = newScript } ! []

        UpdatePriority priority ->
            let
                script = model.script
                newScript = { script | priority = priority }
            in
                { model | script = newScript } ! []

        SaveChanges ->
            model ! [ saveChanges model ]

        _ ->
            model ! []


saveChanges : Model -> Cmd Msg
saveChanges model =
    let
        ( verb, path ) =
            case model.script.id of
                Just id ->
                    ( Put, "?id=" ++ (toString id) )

                Nothing ->
                    ( Post, "" )

        requestInfo =
            AjaxRequestInfo verb path (encodeScript model.script) listScriptDecoder
    in
        sendAjax model.httpInfo requestInfo
            |> Task.perform SaveError RefreshScripts
