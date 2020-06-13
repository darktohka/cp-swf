module Archive exposing
    ( Archive
    , Node(..)
    , archiveDecoder
    , archiveToString
    , defaultSWFPath
    , defaultSelectedPath
    , emptyArchive
    , makeSWFPath
    , maxTreeDepth
    , pathHeader
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Field as Field
import List.Extra exposing (mapAccuml)


type alias Archive =
    List Node


type Node
    = Directory { name : String, contents : List Node }
    | File String
    | Report { directories : Int, files : Int }


archiveToString : Archive -> String
archiveToString archive =
    mapAccuml
        (\acc node ->
            case node of
                Directory dir ->
                    ( acc ++ dir.name ++ "/", node )

                File name ->
                    ( acc ++ name ++ "/", node )

                Report _ ->
                    ( acc, node )
        )
        ""
        archive
        |> Tuple.first
        |> String.dropRight 1


makeSWFPath : Archive -> String
makeSWFPath archive =
    archive |> archiveToString |> String.append pathHeader


archiveDecoder : Decoder Archive
archiveDecoder =
    Decode.list nodeDecoder


nodeDecoder : Decoder Node
nodeDecoder =
    Field.require "type" Decode.string <|
        \t ->
            case t of
                "directory" ->
                    directoryDecoder

                "file" ->
                    fileDecoder

                "report" ->
                    reportDecoder

                _ ->
                    Decode.fail "Could not decode invalid node type"


directoryDecoder : Decoder Node
directoryDecoder =
    Field.require "name" Decode.string <|
        \name ->
            Field.require "contents" (Decode.list nodeDecoder) <|
                \contents ->
                    Decode.succeed <|
                        Directory
                            { name = name
                            , contents = contents
                            }


fileDecoder : Decoder Node
fileDecoder =
    Field.require "name" Decode.string <| \name -> Decode.succeed (File name)


reportDecoder : Decoder Node
reportDecoder =
    Field.require "directories" Decode.int <|
        \directories ->
            Field.require "files"
                Decode.int
            <|
                \files ->
                    Decode.succeed
                        (Report { directories = directories, files = files })


maxTreeDepth : Int
maxTreeDepth =
    4


pathHeader : String
pathHeader =
    "./cp-swf-archive/"


defaultSWFPath : String
defaultSWFPath =
    makeSWFPath defaultSelectedPath


defaultSelectedPath : Archive
defaultSelectedPath =
    [ Directory { name = "2017", contents = [] }
    , Directory { name = "parties", contents = [] }
    , Directory { name = "waddle-on", contents = [] }
    , File "cove.swf"
    ]


emptyArchive : Archive
emptyArchive =
    [ Directory
        { name = "."
        , contents =
            [ File "empty-archive"
            ]
        }
    , Report { directories = 1, files = 1 }
    ]
