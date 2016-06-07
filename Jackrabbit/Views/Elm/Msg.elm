module Views.Elm.Msg exposing (..)

import Views.Elm.Model exposing (..)
import Views.Elm.Script.Msg as ScriptMsg


type Msg
    = Init InitialData
    | AddNewScript
    | ScriptMsg Int ScriptMsg.Msg
