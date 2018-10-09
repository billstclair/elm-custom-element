----------------------------------------------------------------------
--
-- Main.elm
-- Example of using Custom Elements.
-- Copyright (c) 2018 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------


module Main exposing (main)

import Browser
import Char
import CustomElement.CodeEditor as Editor
import CustomElement.FileListener as File exposing (File)
import Html exposing (Html, a, div, h1, h2, img, p, pre, text)
import Html.Attributes exposing (href, src, width)
import Iso8601
import Time


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { file : Maybe File
    , value : String
    }


type Msg
    = SetFile File
    | CodeChanged String


init : () -> ( Model, Cmd Msg )
init () =
    ( { file = Nothing
      , value =
            "module Main exposing (main)"
                ++ "\n\n"
                ++ "import Html"
                ++ "\n\n"
                ++ "main = Html.text \"Hello, World!\""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetFile file ->
            ( { model | file = Just file }
            , Cmd.none
            )

        CodeChanged value ->
            ( { model | value = value }
            , Cmd.none
            )


copyright : String
copyright =
    String.fromList [ Char.fromCode 169 ]


br : Html msg
br =
    Html.br [] []


b : String -> Html msg
b string =
    Html.b [] [ text string ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "CustomElement Example" ]
        , p []
            [ text "Examples of custom elements, used by Elm." ]
        , h2 [] [ text "file-listener Custom Element" ]
        , p []
            [ text "Click the 'Choose File' button and choose an image file."
            , text " Information about the file and the image will appear."
            ]
        , div []
            [ File.fileInput "fileid"
                []
                [ File.onLoad SetFile ]
            , br
            , case model.file of
                Nothing ->
                    text ""

                Just file ->
                    p []
                        [ b "Name: "
                        , text file.name
                        , br
                        , b "Last Modified: "
                        , text <|
                            Iso8601.fromTime
                                (Time.millisToPosix file.lastModified)
                        , br
                        , b "Mime Type: "
                        , text file.mimeType
                        , br
                        , b "Size: "
                        , text <| String.fromInt file.size
                        , br
                        , img
                            [ src file.dataUrl
                            , width 500
                            ]
                            []
                        ]
            ]
        , h2 [] [ text "code-editor Custom Element" ]
        , p []
            [ text "Edit the text below."
            , text " Notice that your edits appear in the area below that."
            ]
        , Editor.codeEditor
            [ Editor.editorValue model.value
            , Editor.onEditorChanged CodeChanged
            ]
            []
        , p []
            [ text "Text above echoed below:" ]
        , pre []
            [ text model.value ]
        , p []
            [ text <| copyright ++ " 2018 "
            , a [ href "https://lisplog.org/" ]
                [ text "Bill St. Clair" ]
            , br
            , text "Source code: "
            , a [ href "https://github.com/billstclair/elm-custom-element" ]
                [ text "github.com/billstclair/elm-custom-element" ]
            ]
        ]
