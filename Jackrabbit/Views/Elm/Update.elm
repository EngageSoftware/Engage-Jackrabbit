module Views.Elm.Update exposing (update)

import Dict exposing (Dict)
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.Script.Model as Script exposing (listScriptDecoder)
import Views.Elm.Script.Msg as Script
import Views.Elm.Script.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.Script.Update as Script
import Views.Elm.Utility exposing (unzip3)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init initialData ->
            let
                initializedModel =
                    let
                        ( scriptRows, lastScriptRowId ) =
                            initialData.scripts
                                |> List.map (\script -> Script.ScriptData (Just script.id) script.pathPrefixName script.scriptPath script.provider script.priority)
                                |> makeScriptRows model.lastScriptRowId initialData.httpInfo model.providers
                    in
                        Model scriptRows
                            initialData.defaultPathPrefix
                            initialData.defaultScriptPath
                            initialData.defaultProvider
                            initialData.defaultPriority
                            model.providers
                            lastScriptRowId
                            Nothing
                            initialData.httpInfo
            in
                initializedModel ! []

        AddNewScript ->
            let
                nextScriptRowId =
                    model.lastScriptRowId + 1

                newScript =
                    Script.init Nothing
                        model.defaultPathPrefix
                        model.defaultScriptPath
                        model.defaultProvider
                        model.defaultPriority
                        True
                        model.httpInfo

                newScriptRow =
                    ScriptRow nextScriptRowId newScript
            in
                { model | scripts = newScriptRow :: model.scripts, lastScriptRowId = nextScriptRowId } ! []

        ScriptMsg rowId msg ->
            let
                ( scripts, cmds, parentMsgs ) =
                    model.scripts
                        |> List.map (updateScript rowId msg)
                        |> unzip3

                updatedModel =
                    { model | scripts = scripts }

                modelWithParentMsgs =
                    parentMsgs
                        |> List.foldl (flip updateFromChild) updatedModel
            in
                modelWithParentMsgs ! cmds


updateFromChild : Model -> ParentMsg -> Model
updateFromChild model parentMsg =
    case parentMsg of
        ParentMsg.NoOp ->
            model

        ParentMsg.SaveError errorMessage ->
            { model | errorMessage = Just errorMessage }

        ParentMsg.RefreshScripts scripts ->
            let
                ( scriptRows, lastScriptRowId ) =
                    scripts
                        |> makeScriptRows model.lastScriptRowId model.httpInfo model.providers
            in
                { model | scripts = scriptRows, lastScriptRowId = lastScriptRowId }


updateScript : Int -> Script.Msg -> ScriptRow -> ( ScriptRow, Cmd Msg, ParentMsg )
updateScript targetRowId msg { rowId, script } =
    let
        ( updatedRow, cmd, parentMsg ) =
            if targetRowId == rowId then
                Script.update msg script
            else
                ( script, Cmd.none, ParentMsg.NoOp )
    in
        ( ScriptRow rowId updatedRow, Cmd.map (ScriptMsg rowId) cmd, parentMsg )


makeScriptRows : Int -> HttpInfo -> Dict String Int -> List Script.ScriptData -> ( List ScriptRow, Int )
makeScriptRows lastScriptRowId httpInfo providers scripts =
    let
        nextScriptRowId =
            lastScriptRowId + 1
    in
        case scripts of
            [] ->
                ( [], nextScriptRowId )

            script :: otherScripts ->
                let
                    scriptModel =
                        Script.init script.id
                            script.pathPrefixName
                            script.scriptPath
                            script.provider
                            script.priority
                            False
                            httpInfo

                    scriptRow =
                        ScriptRow nextScriptRowId scriptModel

                    ( otherScriptRows, lastScriptRowId ) =
                        otherScripts
                            |> makeScriptRows nextScriptRowId httpInfo providers

                    sortedScriptRows =
                        scriptRow
                            :: otherScriptRows
                            |> List.sortWith (compareScriptRows providers)
                in
                    ( sortedScriptRows, lastScriptRowId )


compareScriptRows : Dict String Int -> ScriptRow -> ScriptRow -> Basics.Order
compareScriptRows providers first second =
    Script.compareModels providers first.script second.script
