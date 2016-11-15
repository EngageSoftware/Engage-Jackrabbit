module Views.Elm.Msg exposing (..)

import Views.Elm.File.Msg as File
import Json.Encode as Encode


type Msg
    = Init Encode.Value
    | AddNewFile
    | FileMsg Int File.Msg
    | DismissError
    | DismissAll
