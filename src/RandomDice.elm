-- Press a button to generate a random number between 1 and 6.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/random.html
--


module RandomDice exposing (..)

{-| 乱数のサンプル。
<https://guide.elm-lang.jp/effects/random.html>

@docs main init update subscriptions view

-}

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random
import Svg exposing (circle, rect, svg)
import Svg.Attributes exposing (..)
import Tuple



--------------------------------------------------------------------------------
-- MAIN


{-| エントリポイント。
Browser.elementはコマンドとサブスクリプションを使って外の世界とやり取りができるSPAの雛形。
-}
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



--------------------------------------------------------------------------------
-- MODEL


{-| サイコロの１〜６の面を表す型。
-}
type Face
    = One
    | Two
    | Three
    | Four
    | Five
    | Six


{-| 状態を表す型の別名。
２つのサイコロをレコードで保持。
-}
type alias Model =
    { diceFace1 : Face
    , diceFace2 : Face
    }


{-| 状態の初期値。
初期状態はサイコロの目がそれぞれ１、２。
実行するコマンドは特になし。
-}
init : () -> ( Model, Cmd Msg )
init _ =
    ( Model One Two
    , Cmd.none
    )



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を表す型を定義。

    - `Roll` サイコロを転がす。
    - `NewFace` 新しい面を表示する。

-}
type Msg
    = Roll
    | NewFace ( Face, Face )


{-| 更新処理。
メッセージを受けて状態を更新する。
更新とともに、コマンドで新たなメッセージを送信する。
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model
            , Random.generate NewFace
                -- 乱数を生成し、新しい面を表示する状態へ移行する。
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
            -- 生成した乱数をそれぞれサイコロの目として設定する。
            ( Model (Tuple.first newFace) (Tuple.second newFace)
            , Cmd.none
            )



--------------------------------------------------------------------------------
-- SUBSCRIPTIONS


{-| 待受処理。
このプログラムでは何もしない。
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
サイコロの状態をテキストにした文字列と、サイコロを表示。
サイコロを転がすボタンを表示。
-}
view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text (Debug.toString model) ]
        , diceShape model.diceFace1
        , diceShape model.diceFace2
        , button [ onClick Roll ] [ text "Roll" ]
        ]


{-| サイコロをsvgで描画
-}
diceShape : Face -> Html msg
diceShape diceFace =
    let
        -- 出目の形状
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
        -- SVGの属性については https://developer.mozilla.org/ja/docs/Web/SVG を参照。
        [ width "120", height "120", viewBox "0 0 120 120" ]
        (rect
            [ x "10", y "10", width "100", height "100", rx "5", ry "5", fill "white", stroke "black", strokeWidth "2" ]
            []
            :: eye
        )
