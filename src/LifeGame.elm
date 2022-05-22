-------------------------------------------------
-- LifeGame
-------------------------------------------------


module LifeGame exposing (..)

import Playground exposing (..)


main =
    game view update init



---------
-- MODEL


type alias Pos =
    ( Number, Number )


type alias Board =
    List Pos


type alias Model =
    { board : Board
    , pause : Bool
    }



-- 初期状態


init : Model
init =
    Model [ ( 3, 3 ), ( 3, 4 ), ( 3, 5 ), ( 4, 5 ), ( 5, 4 ) ] False


windowWidth =
    width * size


windowHeight =
    height * size


size =
    16


width =
    40


height =
    30



--------
-- VIEW


view _ model =
    drawPauseButton model
        :: rectangle (rgb 240 240 240) windowWidth windowHeight
        :: List.map drawPos model.board



-- セル一つ分の描画


drawPos : Pos -> Shape
drawPos ( x, y ) =
    let
        dx =
            x * size - (windowWidth - size) * 0.5

        dy =
            y * size - (windowHeight - size) * 0.5
    in
    rectangle (rgb 0 0 0) size size
        |> move dx dy



-- 一時停止ボタン


drawPauseButton : Model -> Shape
drawPauseButton model =
    let
        text =
            if model.pause then
                "RESUME"

            else
                "PAUSE"

        color =
            if model.pause then
                lightRed

            else
                lightBlue
    in
    group
        [ rectangle color 300 64
            |> moveY (windowHeight * 0.5 + 64)
        , words black text
            |> scale 4
            |> moveY (windowHeight * 0.5 + 64)
        ]



----------
-- UPDATE


update computer model =
    let
        -- ボタンクリックで一時停止
        pause =
            if computer.mouse.click then
                let
                    px =
                        computer.mouse.x

                    py =
                        computer.mouse.y

                    by =
                        windowHeight * 0.5 + 64
                in
                if -128 <= px && px < 128 && by - 32 <= py && py < by + 32 then
                    not model.pause

                else
                    model.pause

            else
                model.pause

        -- 盤面をクリックで種を蒔く
        board =
            if computer.mouse.click then
                let
                    ( px, py ) =
                        pointToPos computer.mouse.x computer.mouse.y
                in
                if 0 <= px && px < width && 0 <= py && py < height then
                    click ( px, py ) model.board

                else
                    model.board

            else
                model.board
    in
    if model.pause then
        { model | board = board, pause = pause }

    else
        { model
            | board =
                survivors board ++ births board
            , pause = pause
        }



-- クリックした座標をPosに変換


pointToPos : Number -> Number -> Pos
pointToPos x y =
    ( div (x + windowWidth * 0.5) size, div (y + windowHeight * 0.5) size )



-- セルをクリックした時の処理
-- そのセルが不在なら誕生、生存なら消滅させる


click : Pos -> Board -> Board
click pos board =
    if isEmpty board pos then
        pos :: board

    else
        board



-- 生存判定：pがbの要素であれば生存と判定


isAlive : Board -> Pos -> Bool
isAlive board pos =
    List.filter (\p -> p == pos) board /= []



-- 死滅判定：生存の逆


isEmpty : Board -> Pos -> Bool
isEmpty board pos =
    not (isAlive board pos)



-- 画面外をループさせる


wrap : Pos -> Pos
wrap ( x, y ) =
    ( mod x width, mod y height )



-- Number型に使える整数の割り算がないので自作


mod : Number -> Number -> Number
mod x y =
    if x < 0 then
        mod (x + y) y

    else if x < y then
        x

    else
        mod (x - y) y


div : Number -> Number -> Number
div x y =
    if x < 0 then
        -1 + div (x + y) y

    else if x < y then
        0

    else
        1 + div (x - y) y



-- 周囲８方向を取得


neighbors : Pos -> List Pos
neighbors ( x, y ) =
    List.map wrap
        [ ( x - 1, y - 1 )
        , ( x, y - 1 )
        , ( x + 1, y - 1 )
        , ( x - 1, y )
        , ( x + 1, y )
        , ( x - 1, y + 1 )
        , ( x, y + 1 )
        , ( x + 1, y + 1 )
        ]



-- 周囲に生きているセルの個数を取得


liveneighbors : Board -> Pos -> Int
liveneighbors board pos =
    neighbors pos
        |> List.filter (isAlive board)
        |> List.length



-- 現在の状態から生存となるものを抽出


survivors : Board -> List Pos
survivors board =
    List.filter (survive board) board



-- 生存判定（周囲の生存者が２か３）


survive : Board -> Pos -> Bool
survive board pos =
    let
        count =
            liveneighbors board pos
    in
    count == 2 || count == 3



-- 重複を削除(remove duplicates)


rmdups : List a -> List a
rmdups list =
    case list of
        [] ->
            []

        x :: xs ->
            x :: rmdups (List.filter (\y -> y /= x) xs)



-- 現在の状態から誕生するものを抽出


births : Board -> List Pos
births board =
    List.concatMap neighbors board
        |> rmdups
        |> List.filter (\p -> isEmpty board p)
        |> List.filter (\p -> liveneighbors board p == 3)
