module Views.Elm.Update exposing (update)

import Dict exposing (Dict)
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.Script.Model as Script exposing (listScriptDecoder)
import Views.Elm.Script.Msg as Script
import Views.Elm.Script.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.Script.Update as Script
import Views.Elm.Utility exposing (createLocalizationDict, localizeString)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init initialData ->
            let
                httpInfo =
                    HttpInfo initialData.httpInfo.baseUrl initialData.httpInfo.headers (localizeString "HTTP Error" localization)

                localization =
                    createLocalizationDict initialData.localization

                initializedModel =
                    let
                        ( scriptRows, lastScriptRowId ) =
                            initialData.scripts
                                |> List.map (\script -> Script.ScriptData (Just script.id) script.pathPrefixName script.scriptPath script.provider script.priority)
                                |> makeScriptRows model.lastScriptRowId httpInfo model.providers localization
                    in
                        Model scriptRows
                            initialData.defaultPathPrefix
                            initialData.defaultScriptPath
                            initialData.defaultProvider
                            initialData.defaultPriority
                            model.providers
                            lastScriptRowId
                            Nothing
                            httpInfo
                            localization
            in
                ( initializedModel, Cmd.none )

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
                        model.localization

                newScriptRow =
                    ScriptRow nextScriptRowId newScript
            in
                ( { model | scripts = newScriptRow :: model.scripts, lastScriptRowId = nextScriptRowId }, Cmd.none )

        ScriptMsg rowId msg ->
            let
                scriptUpdates =
                    model.scripts
                        |> List.map (updateScript rowId msg)

                cmd =
                    scriptUpdates
                        |> List.map (\( script, cmd, parentMsg ) -> cmd)
                        |> Cmd.batch

                scripts =
                    scriptUpdates
                        |> List.map (\( script, cmd, parentMsg ) -> script)

                updatedModel =
                    { model | scripts = scripts }

                modelWithParentMsgs =
                    scriptUpdates
                        |> List.foldl updateFromChild updatedModel
            in
                ( modelWithParentMsgs, cmd )


updateFromChild : ( ScriptRow, Cmd msg, ParentMsg ) -> Model -> Model
updateFromChild ( scriptRow, _, parentMsg ) model =
    case parentMsg of
        ParentMsg.NoOp ->
            model

        ParentMsg.RemoveScript ->
            let
                updatedScripts =
                    model.scripts
                        |> List.filter (\s -> s.rowId /= scriptRow.rowId)
            in
                { model | scripts = updatedScripts }

        ParentMsg.SaveError errorMessage ->
            { model | errorMessage = Just errorMessage }

        ParentMsg.RefreshScripts scripts ->
            let
                ( scriptRows, lastScriptRowId ) =
                    scripts
                        |> makeScriptRows model.lastScriptRowId model.httpInfo model.providers model.localization
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


makeScriptRows : Int -> HttpInfo -> Dict String Int -> Dict String String -> List Script.ScriptData -> ( List ScriptRow, Int )
makeScriptRows lastScriptRowId httpInfo providers localization scripts =
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
                            localization

                    scriptRow =
                        ScriptRow nextScriptRowId scriptModel

                    ( otherScriptRows, lastScriptRowId ) =
                        otherScripts
                            |> makeScriptRows nextScriptRowId httpInfo providers localization

                    sortedScriptRows =
                        scriptRow
                            :: otherScriptRows
                            |> List.sortWith (compareScriptRows providers)
                in
                    ( sortedScriptRows, lastScriptRowId )


compareScriptRows : Dict String Int -> ScriptRow -> ScriptRow -> Basics.Order
compareScriptRows providers first second =
    Script.compareModels providers first.script second.script
