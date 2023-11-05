module TextFields exposing (..)

{-| テキスト入力のサンプル。
<https://guide.elm-lang.jp/architecture/text_fields.html>

@docs main init update view

-}

-- A text input for reversing text. Very useful!
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/text_fields.html
--

import Browser
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



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
このプログラムではレコードで状態を保持する。
-}
type alias Model =
    { content : String
    }


{-| 状態の初期値。
contentに空文字列を設定。
-}
init : Model
init =
    { content = "" }



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を表す型を定義。
型名の後ろに型をつけると、引数のついた型として定義する。
例えば Change String と書くと、 (String -> Msg) という型として扱う。
すなわち、String型の引数を指定して初めてMsg型となる型、という意味になる。
-}
type Msg
    = Change String -- テキストの変更


{-| 更新処理。
メッセージを受けて状態を更新する。
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        -- contentをnewContentで更新した新しいmodelを返す
        Change newContent ->
            { model | content = newContent }



--------------------------------------------------------------------------------
-- VIEW
-- tag [attributes] [child elements]


{-| 描画処理。
テキスト入力欄と、テキストを逆順で表示する欄、テキストの長さを表示する欄を描画。
テキスト入力欄には、プレースホルダと、状態で保持している値を表示。
テキスト入力欄の値が変わると、Changeメッセージを送信し、状態を更新。結果として表示するテキストも更新する。
-}
view : Model -> Html Msg
view model =
    div []
        [ input [ placeholder "Text to reverse", value model.content, onInput Change ] []
        , div [] [ text (String.reverse model.content) ]
        , div [] [ text (String.fromInt (String.length model.content)) ]
        ]
