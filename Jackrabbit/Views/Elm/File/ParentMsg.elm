module Views.Elm.File.ParentMsg exposing (..)

import Views.Elm.File.Model as File


type ParentMsg
    = NoOp
    | RefreshFiles (List File.JackrabbitFile) (Maybe (List String))
    | Error String
    | RemoveFile
    | AddTempFile File.Model
    | CancelTempForm
    | Editing
    | RemoveSuggestion
    | AddSuggestion
