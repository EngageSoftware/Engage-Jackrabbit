module Views.Elm.File.Msg exposing (..)

import Views.Elm.File.Model exposing (FileData, ThingToLoad)


type Msg
    = UpdatePrefix String
    | UpdatePath String
    | UpdateProvider String
    | UpdatePriority Int
    | SaveChanges
    | CancelChanges
    | EditFile
    | DeleteFile
    | RefreshFiles (List ThingToLoad)
    | Error String
    | SaveTempForm
    | CancelTempForm
    | SetFileType String ThingToLoad
