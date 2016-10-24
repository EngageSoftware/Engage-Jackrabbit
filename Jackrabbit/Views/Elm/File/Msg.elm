module Views.Elm.File.Msg exposing (..)

import Views.Elm.File.Model exposing (FileData, JackRabbitFile)


type Msg
    = UpdatePrefix String
    | UpdatePath String
    | UpdateProvider String
    | UpdatePriority Int
    | UpdateLibraryName String
    | UpdateVersion String
    | UpdateVersionSpecificity String
    | SaveChanges
    | CancelChanges
    | EditFile
    | DeleteFile
    | RefreshFiles (List JackRabbitFile)
    | Error String
    | SaveTempForm
    | CancelTempForm
    | SetFileType String JackRabbitFile
    | SetLibrary JackRabbitFile
