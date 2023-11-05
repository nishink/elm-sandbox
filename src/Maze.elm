module Maze exposing (..)

{-| 迷路の自動生成。

@docs init update subscriptions view

-}

import Array
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random



--------------------------------------------------------------------------------
-- MAIN


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


{-| 壁。
-}
wall =
    "#"


{-| 床。
-}
floor =
    "_"


{-| 二次元配列。
-}
type alias Array2D a =
    Array.Array (Array.Array a)


{-| 二次元配列に対する値の設定。
-}
set2D : ( Int, Int ) -> a -> Array2D a -> Array2D a
set2D ( x, y ) value array =
    let
        line =
            Array.get y array
                |> Maybe.withDefault Array.empty
    in
    Array.set y (Array.set x value line) array


{-| 二次元配列から値を取得。
-}
get2D : ( Int, Int ) -> Array2D a -> Maybe a
get2D ( x, y ) array =
    Array.get y array
        |> Maybe.withDefault Array.empty
        |> Array.get x


{-| 二次元配列の幅を取得。
-}
getWidth : Array2D a -> Int
getWidth array =
    Array.get 0 array
        |> Maybe.withDefault Array.empty
        |> Array.length


{-| 二次元配列の高さを取得。
-}
getHeight : Array2D a -> Int
getHeight array =
    Array.length array


{-| 状態を表す型の別名。
-}
type alias Model =
    { map : Array2D String
    , size : Int
    }


{-| 初期状態。
-}
init : () -> ( Model, Cmd Msg )
init _ =
    let
        size =
            33
    in
    ( Model (initMap size size) size
    , generateRandomDirections size size
    )


{-| 迷路の初期化。
-}
initMap : Int -> Int -> Array2D String
initMap width height =
    Array.initialize height
        (\y ->
            Array.initialize width
                (\x ->
                    if y == 0 || x == 0 || y == height - 1 || x == width - 1 || modBy 2 y == 0 && modBy 2 x == 0 then
                        wall

                    else
                        floor
                )
        )



--------------------------------------------------------------------------------
-- UPDATE


{-| 方向。
-}
type Direction
    = South
    | West
    | East
    | North


{-| 更新処理を表す命令の種類。
-}
type Msg
    = Roll
    | NewMaze ( List Direction, List Direction )
    | ChangeSize Int


{-| -}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- 乱数の生成
        Roll ->
            let
                n =
                    model.size
            in
            ( { model | map = initMap n n }
            , generateRandomDirections n n
            )

        -- 新しい迷路の作成
        NewMaze ( headLine, tailLine ) ->
            let
                width =
                    getWidth model.map

                height =
                    getHeight model.map

                randomList =
                    List.append headLine tailLine
            in
            ( { model | map = boutaoshi randomList ( 2, 2 ) (initMap width height) }
            , Cmd.none
            )

        -- 迷路の大きさの変更
        ChangeSize size ->
            let
                n =
                    if model.size + size > 3 then
                        model.size + size

                    else
                        3
            in
            ( { model | map = initMap n n, size = n }
            , generateRandomDirections n n
            )


{-| 棒倒し法における、棒が倒れる方向をランダムで生成する。
生成した結果を、「NewMaze 最初の列 残りの列」という形で渡す。
最初の列は東西南北に倒れる。残りの列は倒れた柱に重ならないよう、東南北に倒れる。
-}
generateRandomDirections : Int -> Int -> Cmd Msg
generateRandomDirections width height =
    let
        y =
            (height - 3) // 2

        x =
            (width - 5) // 2
    in
    Random.generate NewMaze
        (Random.pair
            (Random.list y (Random.uniform South [ West, East, North ]))
            (Random.list (y * x) (Random.uniform South [ East, North ]))
        )


{-| 棒倒し法による壁生成
-}
boutaoshi : List Direction -> ( Int, Int ) -> Array2D String -> Array2D String
boutaoshi dirs ( x, y ) maze =
    case dirs of
        d :: irs ->
            let
                nextMaze =
                    case d of
                        South ->
                            set2D ( x, y + 1 ) wall maze

                        West ->
                            -- すでに壁がある場合は反対側に倒す
                            if Maybe.withDefault floor (get2D ( x - 1, y ) maze) == floor then
                                set2D ( x - 1, y ) wall maze

                            else
                                set2D ( x + 1, y ) wall maze

                        East ->
                            set2D ( x + 1, y ) wall maze

                        North ->
                            -- すでに壁がある場合は反対側に倒す
                            if Maybe.withDefault floor (get2D ( x, y - 1 ) maze) == floor then
                                set2D ( x, y - 1 ) wall maze

                            else
                                set2D ( x, y + 1 ) wall maze

                width =
                    getWidth maze

                height =
                    getHeight maze

                nextY =
                    if y + 2 >= height - 1 then
                        2

                    else
                        y + 2

                nextX =
                    if y + 2 >= height - 1 then
                        if x + 2 >= width - 1 then
                            2

                        else
                            x + 2

                    else
                        x
            in
            boutaoshi irs ( nextX, nextY ) nextMaze

        [] ->
            maze



--------------------------------------------------------------------------------
-- SUBSCRIPTIONS


{-| 待受処理。
このプログラムでは使用しない。
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
-}
view : Model -> Html Msg
view model =
    div []
        [ button [ style "font-size" "32px", onClick Roll ] [ text "再生成" ]
        , button [ style "font-size" "32px", onClick (ChangeSize -2) ] [ text "小さく" ]
        , button [ style "font-size" "32px", onClick (ChangeSize 2) ] [ text "大きく" ]

        --        , div [] (linefeed <| viewMaze model)
        , div [] [ viewMazeTable model ]
        ]


{-| 迷路のデータを文字列に変換。
内部データのデバッグ用。
-}
viewMaze : Model -> String
viewMaze model =
    List.map (\x -> String.concat (Array.toList x) ++ "\n") (Array.toList model.map)
        |> String.concat
        |> String.trimRight


{-| 文字列含まれる改行文字をbrタグに置換し、文字列＋brのリストにする。
-}
linefeed : String -> List (Html Msg)
linefeed str =
    String.lines str
        |> List.concatMap (\s -> [ text s, br [] [] ])


{-| 壁を黒いセルで描画。
-}
wallCell : Html Msg
wallCell =
    td [ style "background-color" "black", style "height" "16px", style "width" "16px" ] []


{-| 床を白いセルで描画。
-}
floorCell : Html Msg
floorCell =
    td [ style "background-color" "white", style "height" "16px", style "width" "16px" ] []


{-| 迷路の描画。
-}
viewMazeTable : Model -> Html Msg
viewMazeTable model =
    table []
        (List.map
            (\y ->
                tr []
                    (List.map
                        (\x ->
                            if x == wall then
                                wallCell

                            else
                                floorCell
                        )
                        (Array.toList y)
                    )
            )
            (Array.toList model.map)
        )
