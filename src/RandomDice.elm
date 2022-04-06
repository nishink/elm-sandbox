-- Press a button to generate a random number between 1 and 6.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/random.html
--


module RandomDice exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random
import Svg exposing (circle, rect, svg)
import Svg.Attributes exposing (..)
import Tuple



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Face
    = One
    | Two
    | Three
    | Four
    | Five
    | Six


type alias Model =
    { diceFace1 : Face
    , diceFace2 : Face
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model One Two
    , Cmd.none
    )



-- UPDATE


type Msg
    = Roll
    | NewFace ( Face, Face )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model
            , Random.generate NewFace
                (Random.pair
                    -- 出目の均等なサイコロ
                    (Random.uniform One [ Two, Three, Four, Five, Six ])
                    -- 出目の偏ったサイコロ
                    (Random.weighted
                        ( 10, One )
                        [ ( 10, Two )
                        , ( 10, Three )
                        , ( 10, Four )
                        , ( 20, Five )
                        , ( 40, Six )
                        ]
                    )
                )
            )

        NewFace newFace ->
            ( Model (Tuple.first newFace) (Tuple.second newFace)
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text (Debug.toString model) ]
        , diceShape model.diceFace1
        , diceShape model.diceFace2
        , button [ onClick Roll ] [ text "Roll" ]
        ]



-- サイコロをsvgで描画


diceShape : Face -> Html msg
diceShape diceFace =
    let
        eye =
            case diceFace of
                One ->
                    [ circle [ cx "60", cy "60", r "20", fill "red" ] [] ]

                Two ->
                    [ circle [ cx "90", cy "30", r "10" ] []
                    , circle [ cx "30", cy "90", r "10" ] []
                    ]

                Three ->
                    [ circle [ cx "90", cy "30", r "10" ] []
                    , circle [ cx "60", cy "60", r "10" ] []
                    , circle [ cx "30", cy "90", r "10" ] []
                    ]

                Four ->
                    [ circle [ cx "30", cy "30", r "10" ] []
                    , circle [ cx "30", cy "90", r "10" ] []
                    , circle [ cx "90", cy "30", r "10" ] []
                    , circle [ cx "90", cy "90", r "10" ] []
                    ]

                Five ->
                    [ circle [ cx "30", cy "30", r "10" ] []
                    , circle [ cx "30", cy "90", r "10" ] []
                    , circle [ cx "60", cy "60", r "10" ] []
                    , circle [ cx "90", cy "30", r "10" ] []
                    , circle [ cx "90", cy "90", r "10" ] []
                    ]

                Six ->
                    [ circle [ cx "30", cy "30", r "10" ] []
                    , circle [ cx "30", cy "60", r "10" ] []
                    , circle [ cx "30", cy "90", r "10" ] []
                    , circle [ cx "90", cy "30", r "10" ] []
                    , circle [ cx "90", cy "60", r "10" ] []
                    , circle [ cx "90", cy "90", r "10" ] []
                    ]
    in
    svg
        [ width "120", height "120", viewBox "0 0 120 120" ]
        (rect
            [ x "10", y "10", width "100", height "100", rx "5", ry "5", fill "white", stroke "black", strokeWidth "2" ]
            []
            :: eye
        )
