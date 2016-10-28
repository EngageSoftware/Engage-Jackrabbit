module Views.Elm.File.Msg exposing (..)

import Views.Elm.File.Model exposing (FileData, JackRabbitFile)
import Autocomplete


type Msg
    = UpdatePrefix String
    | UpdatePath String
    | UpdateProvider String
    | UpdatePriority Int
    | UpdateLibraryName String
    | UpdateVersion String
    | UpdateSpecificity String
    | SaveChanges
    | CancelChanges
    | EditFile
    | DeleteFile
    | RefreshFiles (List JackRabbitFile)
    | Error String
    | SetFileType String JackRabbitFile
    | SetLibrary JackRabbitFile
    | SetAutoState Autocomplete.Msg
    | SetQuery String
    | Wrap Bool
    | Reset
    | HandleEscape
    | SelectLibraryKeyboard String
    | SelectLibraryMouse String
    | PreviewLibrary String
    | OnFocus
    | NoOp
