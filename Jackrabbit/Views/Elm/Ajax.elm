module Views.Elm.Ajax exposing (..)

import HttpBuilder
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode
import Task


type HttpVerb
    = Post
    | Put
    | Delete


type alias HttpInfo =
    { baseUrl : String
    , headers : List ( String, String )
    }


type alias AjaxRequestInfo response =
    { verb : HttpVerb
    , path : String
    , data : Encode.Value
    , responseDecoder : Decode.Decoder response
    }


makeSendAjaxFunction : HttpInfo -> (HttpVerb -> String -> Encode.Value -> Decode.Decoder a -> Task.Task String a)
makeSendAjaxFunction httpInfo =
    (\verb path data decoder -> sendAjax httpInfo (AjaxRequestInfo verb path data decoder))


sendAjax : HttpInfo -> AjaxRequestInfo response -> Task.Task String response
sendAjax httpInfo { verb, path, data, responseDecoder } =
    (getRequestBuilder verb) (httpInfo.baseUrl ++ "Scripts/" ++ path)
        |> HttpBuilder.withHeaders httpInfo.headers
        |> HttpBuilder.withJsonBody data
        |> HttpBuilder.send (HttpBuilder.jsonReader responseDecoder) HttpBuilder.stringReader
        |> Task.mapError convertErrorToErrorMessage
        |> Task.map (\response -> response.data)


getRequestBuilder : HttpVerb -> (String -> HttpBuilder.RequestBuilder)
getRequestBuilder verb =
    case verb of
        Post ->
            HttpBuilder.post

        Put ->
            HttpBuilder.put

        Delete ->
            HttpBuilder.delete


convertErrorToErrorMessage : HttpBuilder.Error String -> String
convertErrorToErrorMessage error =
    case error of
        HttpBuilder.BadResponse response ->
            response.data

        _ ->
            "There was an unexpected error"
