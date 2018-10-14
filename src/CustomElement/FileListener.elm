module CustomElement.FileListener exposing
    ( File, Id
    , fileListener, fileInput
    , fileId
    , onLoad
    , multipartFormContentType, multipartFormData
    , crlf, fileDataBase64
    )

{-| The Elm interface to the `file-listener` custom element.

This code won't do anything unless `site/js/file-listener.js` is loaded.


# Types

@docs File, Id


# HTML Elements

@docs fileListener, fileInput


# Attributes

@docs fileId


# Events

@docs onLoad


# Convenience Functions

@docs multipartFormContentType, multipartFormData
@docs crlf, fileDataBase64

-}

import Char
import Html exposing (Attribute, Html, input, span)
import Html.Attributes as Attributes exposing (property, type_)
import Html.Events exposing (on)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)


{-| `onLoad` receives a `File` instance from the JS code.

`data` is a binary string, containing the file contents.

`dataUrl` is a `data:` URL that you can use as the `src` of an `img` element to display the image.

-}
type alias File =
    { name : String
    , lastModified : Int
    , mimeType : String
    , size : Int
    , data : String
    , dataUrl : String
    }


{-| The custom `file-listener` element.

It's invisible, but it adds an event listener to the asociated `<input type='file' id='fileId' />` element to fetch the contents of the file, and generate a `"load"` event containing the contents and other information.

-}
fileListener : List (Attribute msg) -> List (Html msg) -> Html msg
fileListener =
    Html.node "file-listener"


{-| Convenience type.
-}
type alias Id =
    String


{-| Create a `input` element of `type` `file` with the given `Id` and the first list of attributes.

Connect a `file-listener` element to it, with the second list of attributes.

All bundled up in an enclosing `span` element.

-}
fileInput : Id -> List (Attribute msg) -> List (Attribute msg) -> Html msg
fileInput id fileAttributes listenerAttributes =
    span []
        [ input (type_ "file" :: Attributes.id id :: fileAttributes)
            []
        , fileListener (fileId id :: listenerAttributes)
            []
        ]


{-| You need to set the `fileId` attribute to the `id` of an `input` of type `file`.

Not necessary if you use `fileInput` to create the two elements, since it will connect the `file-listener` element to the `input` element for you.

-}
fileId : String -> Attribute msg
fileId value =
    property "fileId" <|
        JE.string value


{-| This is how you receive file content and other information.
-}
onLoad : (File -> msg) -> Attribute msg
onLoad tagger =
    on "load" <|
        JD.map tagger <|
            JD.at [ "target", "contents" ]
                fileDecoder


fileDecoder : Decoder File
fileDecoder =
    JD.map6 File
        (JD.field "name" JD.string)
        (JD.field "lastModified" JD.int)
        (JD.field "mimeType" JD.string)
        (JD.field "size" JD.int)
        (JD.field "data" JD.string)
        (JD.field "dataUrl" JD.string)


{-| Two-character string: carriage return, line feed
-}
crlf : String
crlf =
    -- elm-format rewrites "\r" or "\u{000d}" to "\x0D", and that doesn't compile.
    List.map Char.fromCode [ 13, 10 ]
        |> String.fromList


{-| Turn a `boundary` string into a `multipart/form-data` mime type.

This is suitable as the first parameter to `Http.stringBody`.

-}
multipartFormContentType : String -> String
multipartFormContentType boundary =
    "multipart/form-data; boundary=" ++ boundary


{-| Convert the `dataUrl` in the `File` to just it's data, without the URL prefix.
-}
fileDataBase64 : File -> String
fileDataBase64 file =
    String.split "," file.dataUrl
        |> List.tail
        |> Maybe.withDefault []
        |> String.join ","


{-| Turn a `boundary` string and a `File` into the body of a multipart form post.

This is suitable as the second parameter to `Http.stringBody`.

-}
multipartFormData : String -> File -> String
multipartFormData boundary file =
    -- In case you're tempted to copy this for your own binary POST,
    -- it depends on a patch to XMLHttpRequest.prototype.send
    -- in site/js/file-listener.js.
    -- Without that patch, the binary data will be converted to UTF-8,
    -- And the upload will fail.
    -- The patch kicks in on finding a header line beginning with
    -- "Content-Type: image"
    "--"
        ++ boundary
        ++ crlf
        ++ "Content-Disposition: form-data; name=\"file\"; filename=\""
        ++ file.name
        ++ "\""
        ++ crlf
        ++ "Content-Type: "
        ++ file.mimeType
        ++ crlf
        ++ crlf
        ++ file.data
        ++ crlf
        ++ "--"
        ++ boundary
        ++ "--"
