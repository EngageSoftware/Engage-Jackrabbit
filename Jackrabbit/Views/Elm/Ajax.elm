module Views.Elm.Ajax exposing (..)

import Http
import HttpBuilder
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode
import Task


type HttpVerb
    = Post
    | Put
    | Delete
    | Get


type RequestType
    = File
    | Search


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
    , requestType : RequestType
    }


makeSendAjaxFunction : HttpInfo -> (HttpVerb -> String -> Maybe Encode.Value -> Decode.Decoder a -> RequestType -> Task.Task String a)
makeSendAjaxFunction httpInfo =
    (\verb path data decoder requestType -> sendAjax httpInfo (AjaxRequestInfo verb path data decoder requestType))


sendAjax : HttpInfo -> AjaxRequestInfo response -> Task.Task String response
sendAjax httpInfo { verb, path, data, responseDecoder, requestType } =
    let
        requestTypePath =
            case requestType of
                File ->
                    "file"

                Search ->
                    "search"

        fullPath =
            requestTypePath ++ "/" ++ path
    in
        (getRequestBuilder verb) (httpInfo.baseUrl ++ fullPath)
            |> HttpBuilder.withHeaders httpInfo.headers
            |> HttpBuilder.withHeader "Content-Type" "application/json"
            |> HttpBuilder.withHeader "Accept" "application/json"
            |> withJsonBody data
            |> HttpBuilder.withExpect (Http.expectJson responseDecoder)
            |> HttpBuilder.toTask
            |> Task.mapError (convertErrorToErrorMessage httpInfo.defaultErrorMessage)


withJsonBody : Maybe Encode.Value -> HttpBuilder.RequestBuilder response -> HttpBuilder.RequestBuilder response
withJsonBody maybeData builder =
    case maybeData of
        Just data ->
            HttpBuilder.withJsonBody data builder

        Nothing ->
            builder


getRequestBuilder : HttpVerb -> (String -> HttpBuilder.RequestBuilder ())
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


convertErrorToErrorMessage : String -> Http.Error -> String
convertErrorToErrorMessage defaultErrorMessage error =
    case error of
        Http.BadStatus response ->
            response.body

        _ ->
            defaultErrorMessage


errorResponseDecoder : Decode.Decoder String
errorResponseDecoder =
    Decode.oneOf
        [ Decode.at [ "errorMessage" ] Decode.string
        , Decode.at [ "Message" ] Decode.string
        ]
