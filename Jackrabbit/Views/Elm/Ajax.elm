module Views.Elm.Ajax exposing (..)

import HttpBuilder
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode
import Task


type HttpVerb
    = Post
    | Put
    | Delete
    | Get


type alias HttpInfo =
    { baseUrl : String
    , headers : List ( String, String )
    , defaultErrorMessage : String
    }


type alias AjaxRequestInfo response =
    { verb : HttpVerb
    , path : String
    , data : Maybe Encode.Value
    , responseDecoder : Decode.Decoder response
    , requestType : String
    }


makeSendAjaxFunction : HttpInfo -> (HttpVerb -> String -> Maybe Encode.Value -> Decode.Decoder a -> String -> Task.Task String a)
makeSendAjaxFunction httpInfo =
    (\verb path data decoder requestType -> sendAjax httpInfo (AjaxRequestInfo verb path data decoder requestType))


sendAjax : HttpInfo -> AjaxRequestInfo response -> Task.Task String response
sendAjax httpInfo { verb, path, data, responseDecoder, requestType } =
    (getRequestBuilder verb) (httpInfo.baseUrl ++ requestType ++ path)
        |> HttpBuilder.withHeaders httpInfo.headers
        |> HttpBuilder.withHeader "Content-Type" "application/json"
        |> HttpBuilder.withHeader "Accept" "application/json"
        |> withJsonBody data
        |> HttpBuilder.send (HttpBuilder.jsonReader responseDecoder) (HttpBuilder.jsonReader errorResponseDecoder)
        |> Task.mapError (convertErrorToErrorMessage httpInfo.defaultErrorMessage)
        |> Task.map (\response -> response.data)


withJsonBody : Maybe Encode.Value -> HttpBuilder.RequestBuilder -> HttpBuilder.RequestBuilder
withJsonBody maybeData builder =
    case maybeData of
        Just data ->
            HttpBuilder.withJsonBody data builder

        Nothing ->
            builder


getRequestBuilder : HttpVerb -> (String -> HttpBuilder.RequestBuilder)
getRequestBuilder verb =
    case verb of
        Post ->
            HttpBuilder.post

        Put ->
            HttpBuilder.put

        Delete ->
            HttpBuilder.delete

        Get ->
            HttpBuilder.get


convertErrorToErrorMessage : String -> HttpBuilder.Error String -> String
convertErrorToErrorMessage defaultErrorMessage error =
    case error of
        HttpBuilder.BadResponse response ->
            response.data

        _ ->
            defaultErrorMessage


errorResponseDecoder : Decode.Decoder String
errorResponseDecoder =
    Decode.oneOf
        [ Decode.at [ "errorMessage" ] Decode.string
        , Decode.at [ "Message" ] Decode.string
        ]
