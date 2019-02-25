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
    ( textAreaTracker
    , textAreaId, triggerCoordinates
    , onCaretCoordinates
    )

{-| The Elm interface to the `text-area-tracker` custom element.

[More about it]

This code won't do anything unless `site/js/text-area-tracker.js` is loaded.


# Html Elements

@docs textAreaTracker


# Attributes

@docs textAreaId, triggerCoordinates


# Events

@docs onCaretCoordinates

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Events exposing (on)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)


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


{-| This is how you trigger your subscription for the caret coordinates.
-}
triggerCoordinates : Int -> Attribute msg
triggerCoordinates value =
    property "triggerCoordinates" <|
        JE.int value


{-| This is how you receive the caret position and coordinates.
-}
onCaretCoordinates : (Value -> msg) -> Attribute msg
onCaretCoordinates tagger =
    on "caretCoordinates" <|
        JD.map tagger <|
            JD.at [ "target", "elmProperties" ] JD.value
