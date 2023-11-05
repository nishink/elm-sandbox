module Novel exposing (main)

{-| ノベルゲーム。

@docs init view update subscriptions

-}

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Time



--------------------------------------------------------------------------------
-- MAIN


{-| エントリポイント。
Browser.documentは画面全体を操作する。HTML headやbodyの内容も変更できる。
-}
main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--------------------------------------------------------------------------------
-- MODEL


{-| 状態。
-}
type alias Model =
    { scenario : List String -- 文章データ（残り）
    , text : String -- 表示する文字列
    , length : Int -- 表示する長さ
    }


{-| 文章データ。
-}
scenario : List String
scenario =
    [ "ノベルゲームのように、一文字ずつ表示します。\n"
        ++ "改行もします。"
    , "次の文章"
    , "３つ目の文章"
    ]


{-| 初期状態。
文章データの最初の文章を取り出して表示対象に設定する。
-}
init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        (Maybe.withDefault [] <| List.tail scenario)
        (Maybe.withDefault "" <| List.head scenario)
        0
    , Cmd.none
    )



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類。
-}
type Msg
    = Telling Time.Posix
    | Prompt


{-| 更新処理。
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- タイマー信号に合わせて一文字ずつ表示を進める
        Telling _ ->
            ( { model
                | length =
                    if model.length >= String.length model.text then
                        model.length

                    else
                        model.length + 1
              }
            , Cmd.none
            )

        -- ボタンを押したら次のメッセージの表示を始める
        Prompt ->
            ( { model
                | scenario = Maybe.withDefault [] <| List.tail model.scenario
                , text = Maybe.withDefault "おわり" <| List.head model.scenario
                , length = 0
              }
            , Cmd.none
            )



--------------------------------------------------------------------------------
-- SUBSCRIPTIONS


{-| 待受処理。
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    -- 定期的にタイマー信号を発信
    Time.every 50 Telling



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
-}
view : Model -> Document Msg
view model =
    { title = "Novel Game"
    , body =
        [ div [ style "border" "ridge 5px gray", style "padding" "10px" ]
            [ div [ style "height" "100px" ]
                [ pre [] [ text (String.left model.length model.text) ]
                ]
            , div [ style "height" "32px", style "text-align" "right" ] (viewPrompt model)
            ]
        ]
    }


{-| 次のページを表示するためのプロンプト（いわゆる次へボタン）を表示する。
-}
viewPrompt : Model -> List (Html Msg)
viewPrompt model =
    -- テキストを表示し終わったらプロンプト「▷」を出す。
    if model.length >= String.length model.text then
        [ button [ onClick Prompt ] [ text "▷" ] ]

    else
        []
