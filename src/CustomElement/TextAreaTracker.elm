----------------------------------------------------------------------
--
-- TextAreaTracker.elm
-- Elm interface to <text-area-tracker> custom element.
-- Copyright (c) 2019 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------


module CustomElement.TextAreaTracker exposing
    ( Coordinates, CaretCoordinates, Selection
    , textAreaTracker
    , textAreaId, setSelection, triggerCoordinates, triggerSelection
    , onCoordinates, onSelection
    , coordinatesDecoder, caretCoordinatesDecoder, selectionDecoder
    )

{-| The Elm interface to the `text-area-tracker` custom element.

This code won't do anything unless `site/js/text-area-tracker.js` is loaded.


# Types

@docs Coordinates, CaretCoordinates, Selection


# Html Elements

@docs textAreaTracker


# Attributes

@docs textAreaId, setSelection, triggerCoordinates, triggerSelection


# Events

@docs onCoordinates, onSelection


# Decoders

@docs coordinatesDecoder, caretCoordinatesDecoder, selectionDecoder

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Events exposing (on)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)


{-| The `caretCoordinates` property of a `Coordinates` type.
-}
type alias CaretCoordinates =
    { top : Int
    , left : Int
    , lineheight : Maybe Int
    }


{-| The value for the `onCoordinates` event.
-}
type alias Coordinates =
    { id : String
    , selectionStart : Int
    , selectionEnd : Int
    , caretCoordinates : CaretCoordinates
    }


{-| The value for the `onSelection` event.
-}
type alias Selection =
    { id : String
    , selectionStart : Int
    , selectionEnd : Int
    }


{-| Create a code editor Html element.
-}
textAreaTracker : List (Attribute msg) -> List (Html msg) -> Html msg
textAreaTracker =
    Html.node "text-area-tracker"


{-| This is how you set the id of the tracked text-area element.
-}
textAreaId : String -> Attribute msg
textAreaId value =
    property "textAreaId" <|
        JE.string value


encodeMaybe : (a -> Value) -> Maybe a -> Value
encodeMaybe encoder ma =
    case ma of
        Nothing ->
            JE.null

        Just a ->
            encoder a


{-| This is how you set the selection range.

One of the values must change to cause the selection to be effected.
Hence the `count` parameter. Code will usually increment a model variable
each time the selection needs to be changed.

    setSelection start end count

If `start == end`, the input position will move with no selection.

-}
setSelection : Int -> Int -> Int -> Attribute msg
setSelection start end count =
    property "setSelection" <|
        encodeSetSelection start end count


{-| This is how you trigger the event for the caret coordinates.
-}
triggerCoordinates : Int -> Attribute msg
triggerCoordinates value =
    property "triggerCoordinates" <|
        JE.int value


{-| This is how you trigger the event for the caret coordinates.
-}
triggerSelection : Int -> Attribute msg
triggerSelection value =
    property "triggerSelection" <|
        JE.int value


{-| This is how you receive the caret selection and coordinates.
-}
onCoordinates : (Coordinates -> msg) -> Attribute msg
onCoordinates tagger =
    on "caretCoordinates" <|
        JD.map tagger <|
            JD.at [ "target", "elmProperties" ] coordinatesDecoder


{-| This is how you receive the selection start and end.

This sends a subset of the onCaretCoordinates information.
If you want only the selection, and not the screen coordinates,
it is faster to compute.

-}
onSelection : (Selection -> msg) -> Attribute msg
onSelection tagger =
    on "selection" <|
        JD.map tagger <|
            JD.at [ "target", "selection" ] selectionDecoder



---
--- Attributes for text areas and text inputs.
--- These are NOT to be used with `textAreaTracker`.
---
---
--- JSON encoders and decoders
---


{-| Decoder for the `Coordinates` type.
-}
coordinatesDecoder : Decoder Coordinates
coordinatesDecoder =
    JD.value
        |> JD.andThen coordinatesDecoderDebug


coordinatesDecoderDebug : Value -> Decoder Coordinates
coordinatesDecoderDebug value =
    JD.map4 Coordinates
        (JD.field "id" JD.string)
        (JD.field "selectionStart" JD.int)
        (JD.field "selectionEnd" JD.int)
        (JD.field "caretCoordinates" caretCoordinatesDecoder)


{-| Decoder for the `CaretCoordinates` type.
-}
caretCoordinatesDecoder : Decoder CaretCoordinates
caretCoordinatesDecoder =
    JD.map3 CaretCoordinates
        (JD.field "top" JD.int)
        (JD.field "left" JD.int)
        (JD.field "height" <| JD.maybe JD.int)


{-| Decoder for the `Selection` type.
-}
selectionDecoder : Decoder Selection
selectionDecoder =
    JD.map3 Selection
        (JD.field "id" JD.string)
        (JD.field "selectionStart" JD.int)
        (JD.field "selectionEnd" JD.int)


{-| Encoder for the `setSelection` property.
-}
encodeSetSelection : Int -> Int -> Int -> Value
encodeSetSelection start end count =
    JE.object
        [ ( "start", JE.int start )
        , ( "end", JE.int end )
        , ( "count", JE.int count )
        ]
