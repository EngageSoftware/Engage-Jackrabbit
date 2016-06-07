module Views.Elm.Script.Msg exposing (..)

import Views.Elm.Script.Model exposing (ScriptData)


type Msg
    = Init
    | UpdatePath String
    | UpdatePrefix String
    | UpdateProvider String
    | UpdatePriority Int
    | SaveChanges
    | CancelChanges
    | EditScript
    | DeleteScript
    | RefreshScripts (List ScriptData)
    | SaveError String
