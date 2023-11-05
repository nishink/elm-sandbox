module Buttons exposing (..)

{-| ボタンのサンプルコード。
<https://guide.elm-lang.jp/architecture/buttons.html>

@docs main init update view

-}

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)



--------------------------------------------------------------------------------
-- MAIN


{-| エントリポイント。
Browser.sandboxは最もシンプルなSPAの雛形。
-}
main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



--------------------------------------------------------------------------------
-- MODEL


{-| 状態を表す型の別名。
このプログラムではIntで状態を保持する。
-}
type alias Model =
    Int


{-| 状態の初期値。0を設定。
-}
init : Model
init =
    0



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を表す型を定義。
いずれも引数なしであるため、Msg型の引数に設定する値として使用することができる。
-}
type Msg
    = Increment -- １つ増やす
    | Decrement -- １つ減らす
    | Reset -- ０に初期化
    | PlusTen -- 10増やす
    | MinusTen -- 10減らす


{-| 更新処理。
メッセージを受けて状態を更新する。
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1

        Reset ->
            0

        PlusTen ->
            model + 10

        MinusTen ->
            model - 10



--------------------------------------------------------------------------------
-- VIEW
-- tag [attributes] [child elements]


{-| 描画処理。
各メッセージを発信するボタンと、状態で保持している値を表示。
-}
view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , button [ onClick MinusTen ] [ text "-10" ]
        , div [] [ text (String.fromInt model) ]
        , button [ onClick Increment ] [ text "+" ]
        , button [ onClick PlusTen ] [ text "+10" ]
        , button [ onClick Reset ] [ text "reset" ]
        ]
