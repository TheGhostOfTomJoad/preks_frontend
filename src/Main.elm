module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import File.Download as Download
import Html exposing (Html, code)
import Html.Attributes as Attr
import Html.Events
import Http
import Json.Decode as D
import Json.Encode as E


main : Program D.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Mode
    = Markdown
    | Haskell
    | Python
    | Preks


modeToString : Mode -> String
modeToString m =
    case m of
        Markdown ->
            "markdown"

        Haskell ->
            "haskell"

        Python ->
            "python"

        Preks ->
            "preks"


type Theme
    = Monokai
    | Eighties


themeToString : Theme -> String
themeToString t =
    case t of
        Monokai ->
            "monokai"

        Eighties ->
            "tomorrow-night-eighties"


type KeyMap
    = Vim
    | Emacs
    | Sublime


keyMapToString : KeyMap -> String
keyMapToString m =
    case m of
        Vim ->
            "vim"

        Emacs ->
            "emacs"

        Sublime ->
            "sublime"


codemirror : Mode -> KeyMap -> Theme -> String -> Html Msg
codemirror mode km theme content =
    Html.node "code-mirror"
        [ Attr.attribute "mode" <| modeToString mode
        , Attr.attribute "keymap" <| keyMapToString km
        , Attr.attribute "theme" <| themeToString theme
        , Attr.attribute "editorValue" content
        , Html.Events.on "editorChanged" <|
            D.map EditorChanged <|
                D.at [ "target", "editorValue" ] <|
                    D.string
        ]
        []


type alias Model =
    { editorValue : String
    , res : String
    }


init : D.Value -> ( Model, Cmd Msg )
init _ =
    ( { editorValue = facCode
      , res = ""
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | EditorChanged String
    | Send
    | GotRes (Result Http.Error String)
    | DownloadDoc


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    case msg of
        NoOp ->
            ( m, Cmd.none )

        EditorChanged v ->
            if m.editorValue /= v then
                ( { m | editorValue = v }, Cmd.none )

            else
                ( m, Cmd.none )

        Send ->
            ( m, runPreks m.editorValue )

        GotRes (Ok newRes) ->
            ( { m | res = newRes }, Cmd.none )

        GotRes (Err _) ->
            ( { m | res = "Network Error!" }, Cmd.none )

        DownloadDoc ->
            ( m, downloadManual )


spotifyColors : { background : Color, menubar : Color, topgradient : Color, bottomgradient : Color, primarytext : Color, secondarytext : Color, black : Color }
spotifyColors =
    { background = rgb255 0x12 0x12 0x12
    , menubar = rgb255 0x18 0x18 0x18
    , topgradient = rgb255 0x40 0x40 0x40
    , bottomgradient = rgb255 0x28 0x28 0x28
    , primarytext = rgb255 0xFF 0xFF 0xFF
    , secondarytext = rgb255 0xB3 0xB3 0xB3
    , black = rgb255 0x00 0x00 0x00
    }


buttonstyle : List (Attribute msg)
buttonstyle =
    [ padding 20
    , Font.bold
    , Font.color spotifyColors.primarytext
    , Border.width 0
    , Border.rounded 0
    , Border.color spotifyColors.background
    , Background.color spotifyColors.background
    , Font.size 40
    ]


editorstyle : List (Attribute msg)
editorstyle =
    [ padding 10, Border.color spotifyColors.background, Border.width 3, Border.rounded 6, width fill, height (px 730) ]






textstyle : List (Attribute msg)
textstyle =
    [ Border.width 3, Border.rounded 6, padding 30, width fill, mouseDown [], mouseOver [], Background.color spotifyColors.primarytext ]






viewhelper : Model -> Element.Element Msg
viewhelper m =
    Element.column [ height fill, width fill, paddingXY 0 0, spacing 20, Background.color spotifyColors.background ]
        --[]
        [ Element.row [] [button buttonstyle { onPress = Just DownloadDoc, label = text "Manual" }
        , button buttonstyle { onPress = Just Send, label = text "▶" }]
        , el editorstyle (html (codemirror Preks Sublime Monokai m.editorValue))
        , el textstyle (text m.res)
        ]



--view2 : Model -> Html Msg
--view2 m = layout [] (viewhelper m)


view : Model -> Html Msg
view m =
    layoutWith
        { options =
            [ focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing --- Just spotifyColors.primarytext
                , shadow = Nothing
                }
            ]
        }
        []
        (viewhelper m)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

--https://preksbackend.herokuapp.com/

-- runPreks : String -> Cmd Msg
-- runPreks code =
--     Http.post
--         { url = "http://localhost:3000/runPreks/"
--         , expect = Http.expectJson GotRes eitherDecoder
--         , body = Http.jsonBody (E.string code)
--         }

runPreks : String -> Cmd Msg
runPreks code =
    Http.post
        { url = "https://preksbackend.herokuapp.com/runPreks"
        , expect = Http.expectJson GotRes eitherDecoder
        , body = Http.jsonBody (E.string code)
        }



downloadManual : Cmd msg
downloadManual =
    Download.url "https://github.com/TheGhostOfTomJoad/Preks/blob/main/Documentation/documentation.pdf" --"https://prekInterpreter.de/documentation.pdf"

eitherDecoder : D.Decoder String
eitherDecoder =
    D.oneOf [ D.field "Left" D.string, D.field "Right" (D.map (String.join " ") (D.list (D.map String.fromInt D.int))) ]


facCode : String
facCode =
    "let idOnN = Pi 1 1 \n-- just a comment\nlet sucOfFirst = C (S, (Pi 3 1)) -- just a comment\n \nlet plus = P (idOnN, sucOfFirst) \n\nlet hmul = C (plus, (Pi 3 1, Pi 3 3))\nlet mul = P (Z 1, hmul)\n\n\n\nlet gdec = Z 0\nlet hdec = Pi 2 2 \nlet dec = P (gdec, hdec)\n\n\n\n\nlet gminus = Pi 1 1\nlet hminus = C (dec, (Pi 3 1))\nlet minus = P (gminus, hminus)\n\n\n\n\n\nlet swappedminus = C (minus, (Pi 2 2, Pi 2 1))\n\n\nlet gfac = C (S, (Z 0 ))\nlet hfac = C (mul, (Pi 2 1, C (S, (Pi 2 2))) )\nlet fac = P (gfac,hfac)\n\nfac (5)\n"
