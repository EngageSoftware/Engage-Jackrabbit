module Views.Elm.Model exposing (..)

import Dict exposing (Dict)
import Json.Encode as Encode
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.Script.Model as Script


type alias InitialData =
    { scripts :
        List
            { id : Int
            , pathPrefixName : String
            , scriptPath : String
            , provider : String
            , priority : Int
            }
    , defaultPathPrefix : String
    , defaultScriptPath : String
    , defaultProvider : String
    , defaultPriority : Int
    , httpInfo :
        { baseUrl : String
        , headers : List ( String, String )
        }
    , localization : Encode.Value
    }


type alias Model =
    { scripts : List ScriptRow
    , defaultPathPrefix : String
    , defaultScriptPath : String
    , defaultProvider : String
    , defaultPriority : Int
    , providers : Dict String Int
    , lastScriptRowId : Int
    , errorMessage : Maybe String
    , httpInfo : HttpInfo
    , localization : Dict String String
    }


type alias ScriptRow =
    { rowId : Int
    , script : Script.Model
    }


initialModel : Model
initialModel =
    { scripts = []
    , defaultPathPrefix = ""
    , defaultScriptPath = ""
    , defaultProvider = ""
    , defaultPriority = 0
    , providers =
        Dict.fromList
            [ ( "DnnPageHeaderProvider", 1 )
            , ( "DnnBodyProvider", 2 )
            , ( "DnnFormBottomProvider", 3 )
            ]
    , lastScriptRowId = 0
    , errorMessage = Nothing
    , httpInfo =
        { baseUrl = ""
        , headers = []
        , defaultErrorMessage = ""
        }
    , localization = Dict.empty
    }
