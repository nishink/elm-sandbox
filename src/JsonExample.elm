module JsonExample exposing (..)

{-| JSONのサンプル。
<https://guide.elm-lang.jp/effects/json.html>

@docs main init update subscriptions view

-}

-- Press a button to send a GET request for random quotes.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, map4, string)



--------------------------------------------------------------------------------
-- MAIN


{-| エントリポイント。
Browser.elementはコマンドとサブスクリプションを使って外の世界とやり取りができるSPAの雛形。
-}
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
  - `Success` 成功（読み込んだ引用文）

-}
type Model
    = Failure
    | Loading
    | Success Quote


{-| 引用文を表す型の別名。
-}
type alias Quote =
    { quote : String -- 引用文
    , source : String -- 出典
    , author : String -- 著者
    , year : Int -- 発表年
    }


{-| 状態の初期値。
初期状態はLoading。
ランダムに引用文を取得するメッセージを送信。
-}
init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getRandomQuote )



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を表す型を定義。

  - `MorePlease` 再度、引用文を取得するメッセージを送信する。
  - `GotQuote` Result型を引数に取り、成功ならQuote、失敗ならHttp.Errorを返す。

-}
type Msg
    = MorePlease
    | GotQuote (Result Http.Error Quote)


{-| 更新処理。
メッセージを受けて状態を更新する。
更新とともに、コマンドで新たなメッセージを送信する。
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        MorePlease ->
            ( Loading, getRandomQuote )

        GotQuote result ->
            case result of
                Ok quote ->
                    ( Success quote, Cmd.none )

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
タイトルと引用文を表示する。
-}
view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Random Quotes" ]
        , viewQuote model
        ]


{-| 引用文(Quote)を表示する。
モデルの状態によって表示を切り替える。
-}
viewQuote : Model -> Html Msg
viewQuote model =
    case model of
        Failure ->
            -- 取得失敗のメッセージと、再送要求ボタンを表示。
            div []
                [ text "I could not load a random quote for some reason. "
                , button [ onClick MorePlease ] [ text "Try Again!" ]
                ]

        Loading ->
            text "Loading..."

        Success quote ->
            -- 再送要求ボタンと、取得した引用文を表示。
            -- 引用文 + "-" + 出典 + "by" + 著者 + "(" + 発表年 + ")"
            div []
                [ button [ onClick MorePlease, style "display" "block" ] [ text "More Please!" ]
                , blockquote [] [ text quote.quote ]
                , p [ style "text-align" "right" ]
                    [ text "— "
                    , cite [] [ text quote.source ]
                    , text (" by " ++ quote.author ++ " (" ++ String.fromInt quote.year ++ ")")
                    ]
                ]



--------------------------------------------------------------------------------
-- HTTP


{-| 引用文(Quote)をランダムで取得。
Http.getを使って、指定したURLからJSONデータを取得する。
取得時にGotQuoteメッセージを、JSONデータから取得した引用文付きで送信する。
-}
getRandomQuote : Cmd Msg
getRandomQuote =
    Http.get
        { url = "https://elm-lang.org/api/random-quotes"
        , expect = Http.expectJson GotQuote quoteDecoder
        }


{-| JSONデータをデコードし、引用文(Quote)を取得。
map4とデコーダの説明はコメントで書ききれないため、引用元の説明を参照すること。
<https://guide.elm-lang.jp/effects/json.html>
-}
quoteDecoder : Decoder Quote
quoteDecoder =
    map4 Quote
        (field "quote" string)
        (field "source" string)
        (field "author" string)
        (field "year" int)
