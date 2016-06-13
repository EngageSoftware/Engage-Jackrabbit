module Views.Elm.Model exposing (..)

import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.Script.Model as Script


type alias InitialData =
    { scripts : List
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
    , httpInfo : HttpInfo
    }


type alias Model =
    { scripts : List ScriptRow
    , defaultPathPrefix : String
    , defaultScriptPath : String
    , defaultProvider : String
    , defaultPriority : Int
    , lastScriptRowId : Int
    , httpInfo : HttpInfo
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
    , lastScriptRowId = 0
    , httpInfo =
        { baseUrl = ""
        , headers = []
        }
    }
