module Novel exposing (main)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Time



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { scenario : List String
    , text : String
    , length : Int
    }


scenario : List String
scenario =
    [ "ノベルゲームのように、一文字ずつ表示します。\n"
        ++ "改行もします。"
    , "次の文章"
    , "３つ目の文章"
    ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        (Maybe.withDefault [] <| List.tail scenario)
        (Maybe.withDefault "" <| List.head scenario)
        0
    , Cmd.none
    )



-- UPDATE


type Msg
    = Telling Time.Posix
    | Prompt


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

        -- TODO ボタンを押したら次のメッセージの表示を始める
        Prompt ->
            ( { model
                | scenario = Maybe.withDefault [] <| List.tail model.scenario
                , text = Maybe.withDefault "おわり" <| List.head model.scenario
                , length = 0
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    -- 定期的にタイマー信号を発信
    Time.every 50 Telling



-- VIEW


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


viewPrompt : Model -> List (Html Msg)
viewPrompt model =
    -- テキストを表示し終わったらプロンプト「▷」を出す。
    if model.length >= String.length model.text then
        [ button [ onClick Prompt ] [ text "▷" ] ]

    else
        []
