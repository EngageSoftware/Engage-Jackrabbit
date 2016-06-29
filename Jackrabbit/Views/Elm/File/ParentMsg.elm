module Views.Elm.File.ParentMsg exposing (..)

import Views.Elm.File.Model exposing (FileData)


type ParentMsg
    = NoOp
    | RefreshFiles (List FileData)
    | SaveError String
    | RemoveFile
