module Views.Elm.Model exposing (..)

import Dict exposing (Dict)
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.File.Model as File


type alias InitialHttpInfo =
    { baseUrl : String
    , headers : List ( String, String )
    }


type alias InitialData =
    { files : List File.JackrabbitFile
    , httpInfo : InitialHttpInfo
    , localization : Dict String String
    , pathAliases : List String
    }


type alias Model =
    { fileRows : List FileRow
    , defaultPathPrefix : String
    , defaultFilePath : String
    , defaultProvider : String
    , defaultPriority : Int
    , providers : Dict String Int
    , lastRowId : Int
    , errorMessage : Maybe String
    , httpInfo : HttpInfo
    , localization : Dict String String
    , tempFileRow : Maybe FileRow
    , editing : Bool
    , pathAliases : List String
    , criticalError : Bool
    , suggestedFiles : List FileRow
    , tempLibraryName : String
    }


type alias FileRow =
    { rowId : Int
    , file : File.Model
    }


initialModel : Model
initialModel =
    { fileRows = []
    , defaultPathPrefix = ""
    , defaultFilePath = ""
    , defaultProvider = "DnnFormBottomProvider"
    , defaultPriority = 100
    , providers =
        Dict.fromList
            [ ( "DnnPageHeaderProvider", 1 )
            , ( "DnnBodyProvider", 2 )
            , ( "DnnFormBottomProvider", 3 )
            ]
    , lastRowId = 0
    , errorMessage = Nothing
    , httpInfo =
        { baseUrl = ""
        , headers = []
        , defaultErrorMessage = ""
        }
    , localization = Dict.empty
    , tempFileRow = Nothing
    , editing = False
    , pathAliases = []
    , criticalError = False
    , suggestedFiles = []
    , tempLibraryName = ""
    }
