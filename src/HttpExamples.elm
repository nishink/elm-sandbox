module HttpExamples exposing (..)

{-| HTTPのサンプル。
<https://guide.elm-lang.jp/effects/http.html>

@docs main init update subscriptions view

-}

-- Make a GET request to load a book called "Public Opinion"
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/http.html
--

import Browser
import Html exposing (Html, pre, text)
import Http



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


{-| 状態を表す型。

  - `Failure` 失敗
  - `Loading` 読み込み中
  - `Success` 成功（読み込んだ文字列）

-}
type Model
    = Failure -- 失敗
    | Loading -- 読み込み中
    | Success String -- 成功（読み込んだ文字列）


{-| 状態の初期値。
初期状態はLoading。
Http.getを使って、指定したURLからテキストを取得する。
取得時にGotTextメッセージを送信する。
-}
init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Http.get
        { url = "https://elm-lang.org/assets/public-opinion.txt"
        , expect = Http.expectString GotText
        }
    )



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を表す型を定義。

  - `GotText` Result型を引数に取り、成功ならString、失敗ならHttp.Errorを返す。

-}
type Msg
    = GotText (Result Http.Error String)


{-| 更新処理。
メッセージを受けて状態を更新する。
更新とともに、コマンドで新たなメッセージを送信する。
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotText result ->
            case result of
                Ok fullText ->
                    ( Success fullText, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



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
モデルの状態によって表示を切り替える。
-}
view : Model -> Html Msg
view model =
    case model of
        Failure ->
            text "I was unable to load your book."

        Loading ->
            text "Loading..."

        Success fullText ->
            pre [] [ text fullText ]
