module Views.Elm.Model exposing (..)

import Dict exposing (Dict)
import Json.Encode as Encode
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.File.Model as File


type alias InitialData =
    { files :
        List
            { fileType : String
            , id : Int
            , pathPrefixName : String
            , filePath : String
            , provider : String
            , priority : Int
            }
    , defaultPathPrefix : String
    , defaultFilePath : String
    , defaultProvider : String
    , defaultPriority : Int
    , httpInfo :
        { baseUrl : String
        , headers : List ( String, String )
        }
    , localization : Encode.Value
    }


type alias Model =
    { files : List FileRow
    , defaultPathPrefix : String
    , defaultFilePath : String
    , defaultProvider : String
    , defaultPriority : Int
    , providers : Dict String Int
    , lastRowId : Int
    , errorMessage : Maybe String
    , httpInfo : HttpInfo
    , localization : Dict String String
    }


type alias FileRow =
    { rowId : Int
    , file : File.Model
    }


initialModel : Model
initialModel =
    { files = []
    , defaultPathPrefix = ""
    , defaultFilePath = ""
    , defaultProvider = ""
    , defaultPriority = 0
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
    }
