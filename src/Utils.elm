module Utils exposing (defaultURL, errorToString, listToString)

import Http exposing (Error(..))
import Url exposing (Protocol(..), Url)


defaultURL : Url
defaultURL =
    { protocol = Https
    , host = "cpswf.barichello.me"
    , port_ = Nothing
    , path = "/"
    , query = Nothing
    , fragment = Nothing
    }


listToString : List String -> String
listToString list =
    listToStringAux list ""


listToStringAux : List String -> String -> String
listToStringAux list acc =
    let
        head =
            List.head list

        tail =
            Maybe.withDefault [] (List.tail list)
    in
    case head of
        Nothing ->
            acc

        Just el ->
            listToStringAux tail (acc ++ el)


errorToString : Http.Error -> String
errorToString err =
    case err of
        Timeout ->
            "Timeout exceeded"

        NetworkError ->
            "Network error"

        BadStatus _ ->
            "BadStatus"

        BadBody _ ->
            "Bad Body"

        BadUrl url ->
            "Malformed url: " ++ url
