module Views.Elm.Msg exposing (..)

import Views.Elm.Model exposing (..)
import Views.Elm.File.Msg as File


type Msg
    = Init InitialData
    | AddNewFile
    | FileMsg Int File.Msg
