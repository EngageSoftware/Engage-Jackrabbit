module Views.Elm.Update exposing (update)

import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.Script.Model as Script exposing (listScriptDecoder)
import Views.Elm.Script.Msg as Script
import Views.Elm.Script.Update as Script


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init initialData ->
            let
                makeScriptRows lastScriptRowId scripts =
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
                                            initialData.httpInfo

                                    scriptRow =
                                        ScriptRow nextScriptRowId scriptModel

                                    ( otherScriptRows, _ ) =
                                        makeScriptRows nextScriptRowId otherScripts
                                in
                                    ( scriptRow :: otherScriptRows, nextScriptRowId )

                initializedModel =
                    let
                        ( scriptRows, lastScriptRowId ) =
                            makeScriptRows model.lastScriptRowId initialData.scripts
                    in
                        Model scriptRows
                            initialData.defaultPathPrefix
                            initialData.defaultScriptPath
                            initialData.defaultProvider
                            initialData.defaultPriority
                            lastScriptRowId
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
                { model | scripts = newScriptRow :: model.scripts } ! []

        ScriptMsg rowId msg ->
            let
                ( scripts, cmds ) =
                    model.scripts
                        |> List.map (updateScript rowId msg)
                        |> List.unzip
            in
                { model | scripts = scripts } ! cmds


updateScript : Int -> Script.Msg -> ScriptRow -> ( ScriptRow, Cmd Msg )
updateScript targetRowId msg { rowId, script } =
    let
        ( updatedRow, cmd ) =
            if targetRowId == rowId then
                Script.update msg script
            else
                script ! []
    in
        ScriptRow rowId updatedRow ! [ Cmd.map (ScriptMsg rowId) cmd ]
