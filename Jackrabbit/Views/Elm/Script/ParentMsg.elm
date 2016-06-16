module Views.Elm.Script.ParentMsg exposing (..)

import Views.Elm.Script.Model exposing (ScriptData)


type ParentMsg
    = NoOp
    | RefreshScripts (List ScriptData)
    | SaveError String
    | RemoveScript
