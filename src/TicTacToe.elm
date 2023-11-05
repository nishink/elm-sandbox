module TicTacToe exposing (..)

{-| ３目並べ。
ReactのチュートリアルをElmで実装。

@docs init update view

-}

-- Tic Tac Toe - React Tutorial
-- https://ja.reactjs.org/tutorial/tutorial.html

import Array exposing (Array)
import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Maybe
import Set



--------------------------------------------------------------------------------
-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



--------------------------------------------------------------------------------
-- MODEL


{-| 状態。
-}
type alias Model =
    { squares : Array String
    , xIsNext : Bool
    }


{-| 初期状態。
-}
init : Model
init =
    { squares = Array.initialize 9 (always "")
    , xIsNext = True
    }



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類。
-}
type Msg
    = Click Int


{-| 更新処理。
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        Click index ->
            if calculateWinner model.squares /= "" || get index model.squares /= "" then
                -- 勝敗が決している場合か、すでに何か入っている場合は変更しない。
                model

            else
                -- 先手か後手に合わせてマルバツを設定し、手番を入れ替える。
                { model
                    | squares = Array.set index (next model) model.squares
                    , xIsNext = not model.xIsNext
                }


{-| 次の手番。
-}
next : Model -> String
next model =
    if model.xIsNext then
        "X"

    else
        "O"



--------------------------------------------------------------------------------
-- VIEW
-- tag [attributes] [child elements]


{-| 表示処理。
-}
view : Model -> Html Msg
view model =
    let
        winner =
            calculateWinner model.squares

        status =
            if winner /= "" then
                "Winner: " ++ winner

            else
                "Next player: " ++ next model
    in
    div [ class "game", style "display" "flex", style "flex-direction" "row" ]
        [ div []
            [ div [ class "status" ] [ text status ]
            , div [ class "board-row" ]
                [ squareButton 0 model
                , squareButton 1 model
                , squareButton 2 model
                ]
            , div [ class "board-row" ]
                [ squareButton 3 model
                , squareButton 4 model
                , squareButton 5 model
                ]
            , div [ class "board-row" ]
                [ squareButton 6 model
                , squareButton 7 model
                , squareButton 8 model
                ]
            ]
        ]


{-| 四角いボタンを表示。
クリックしたら、クリックした場所を送信。
-}
squareButton : Int -> Model -> Html Msg
squareButton index model =
    button
        [ class "square"
        , onClick (Click index)
        , style "height" "34px"
        , style "width" "34px"
        , style "float" "left"
        ]
        [ text (get index model.squares) ]


{-| 文字列配列から値を取得。
取得失敗時は空文字列を返す。
-}
get : Int -> Array String -> String
get index array =
    Maybe.withDefault "" (Array.get index array)


{-| 勝利判定。
縦横斜めのいずれかにマルかバツが３つ並んだら、並んでいるものを返す。
並んでなければ空文字列を返す。
-}
calculateWinner : Array String -> String
calculateWinner squares =
    let
        lines =
            [ ( 0, 1, 2 )
            , ( 3, 4, 5 )
            , ( 6, 7, 8 )
            , ( 0, 3, 6 )
            , ( 1, 4, 7 )
            , ( 2, 5, 8 )
            , ( 0, 4, 8 )
            , ( 2, 4, 6 )
            ]

        calc ( a, b, c ) =
            let
                aa =
                    get a squares

                bb =
                    get b squares

                cc =
                    get c squares
            in
            if aa /= "" && aa == bb && aa == cc then
                aa

            else
                ""
    in
    -- 一度Setに置き換えることで重複を削除
    List.map calc lines
        |> Set.fromList
        |> Set.toList
        |> String.concat
