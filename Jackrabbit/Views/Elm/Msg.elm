module Views.Elm.Msg exposing (..)

import Views.Elm.Model exposing (..)
import Views.Elm.Script.Msg as Script


type Msg
    = Init InitialData
    | AddNewScript
    | ScriptMsg Int Script.Msg
