module Views.Elm.File.Msg exposing (..)

import Views.Elm.File.Model exposing (FileData)


type Msg
    = UpdatePrefix String
    | UpdatePath String
    | UpdateProvider String
    | UpdatePriority Int
    | SaveChanges
    | CancelChanges
    | EditFile
    | DeleteFile
    | RefreshFiles (List FileData)
    | SaveError String
