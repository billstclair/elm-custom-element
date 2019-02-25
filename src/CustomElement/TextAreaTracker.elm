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
    ( Coordinates, Selection
    , textAreaTracker
    , textAreaId, triggerCoordinates, triggerSelection
    , onCaretCoordinates, onSelection
    )

{-| The Elm interface to the `text-area-tracker` custom element.

[More about it]

This code won't do anything unless `site/js/text-area-tracker.js` is loaded.


# Types

@docs Coordinates, Selection


# Html Elements

@docs textAreaTracker


# Attributes

@docs textAreaId, triggerCoordinates, triggerSelection


# Events

@docs onCaretCoordinates, onSelection

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Events exposing (on)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)


{-| The value for the onCoordinates event.
-}
type alias Coordinates =
    { id : String
    , selectionStart : Int
    , selectionEnd : Int
    , caretCoordinates :
        { top : Int
        , left : Int
        , height : Maybe Int
        }
    }


{-| The value for the onSelection event.
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


{-| This is how you trigger your subscription for the caret coordinates.
-}
triggerCoordinates : Int -> Attribute msg
triggerCoordinates value =
    property "triggerCoordinates" <|
        JE.int value


{-| This is how you trigger your subscription for the caret coordinates.
-}
triggerSelection : Int -> Attribute msg
triggerSelection value =
    property "triggerSelection" <|
        JE.int value


{-| This is how you receive the caret selection and coordinates.
-}
onCaretCoordinates : (Value -> msg) -> Attribute msg
onCaretCoordinates tagger =
    on "caretCoordinates" <|
        JD.map tagger <|
            JD.at [ "target", "elmProperties" ] JD.value


{-| This is how you receive the selection start and end.

This sends a subset of the onCaretCoordinates information.
If you want only the selection, and not the screen coordinates,
it is faster to compute.

-}
onSelection : (Value -> msg) -> Attribute msg
onSelection tagger =
    on "selection" <|
        JD.map tagger <|
            JD.at [ "target", "selection" ] JD.value



---
--- Attributes for text areas and text inputs.
--- These are NOT to be used with `textAreaTracker`.
---
---
--- JSON encoders and decoders
---


{-| Encoder for `Selection` type.
-}
encodeSelection : Selection -> Value
encodeSelection selection =
    JE.null
