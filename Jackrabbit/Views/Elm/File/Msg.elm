module Views.Elm.File.Msg exposing (..)

import Views.Elm.File.Model exposing (JackrabbitFile, Library)
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
    | AddSuggestedFile
    | DismissSuggestedFile
    | UndoDelete
    | DeleteFile
    | RefreshFiles ( List JackrabbitFile, Maybe (List String) )
    | Error String
    | SetFileType String JackrabbitFile
    | SetLibrary JackrabbitFile
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
    | RequestLibraries (List Library)
