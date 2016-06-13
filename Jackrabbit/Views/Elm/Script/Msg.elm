module Views.Elm.Script.Msg exposing (..)

import Views.Elm.Script.Model exposing (ScriptData)


type Msg
    = UpdatePrefix String
    | UpdatePath String
    | UpdateProvider String
    | UpdatePriority Int
    | SaveChanges
    | CancelChanges
    | EditScript
    | DeleteScript
    | RefreshScripts (List ScriptData)
    | SaveError String
