module DrawTool exposing (..)

{-| 簡易ドローツール。
-}

import Playground exposing (..)



--------------------------------------------------------------------------------
-- MAIN


{-| エントリポイント。
-}
main =
    game view update init



--------------------------------------------------------------------------------
-- MODEL


{-| セルの位置を表す座標
(x, y)
-}
type alias Pos =
    ( Number, Number )


{-| セルを配置する盤面
座標のリストで表す
-}
type alias Board =
    List Pos


{-| 状態。
-}
type alias Model =
    { board : Board
    }


{-| 初期状態。
-}
init : Model
init =
    Model []


{-| 画面の幅
-}
windowWidth =
    width * size


{-| 画面の高さ
-}
windowHeight =
    height * size


{-| １つのセルのサイズ
-}
size =
    16


{-| 横にセルが並ぶ数
-}
width =
    16


{-| 縦にセルが並ぶ数
-}
height =
    16



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
-}
view : a -> Model -> List Shape
view _ model =
    List.map drawPos model.board


{-| セル一つ分を描画
-}
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



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理。
-}
update computer model =
    let
        down =
            computer.mouse.down

        x =
            computer.mouse.x

        y =
            computer.mouse.y

        -- 盤面をドラッグで描画
        board =
            updateBoard down x y model.board
    in
    { model | board = board }


{-| 盤面をドラッグで描画
-}
updateBoard : Bool -> Number -> Number -> Board -> Board
updateBoard down x y board =
    if down then
        let
            ( px, py ) =
                pointToPos x y
        in
        if 0 <= px && px < width && 0 <= py && py < height then
            drawCell ( px, py ) board

        else
            board

    else
        board


{-| クリックした座標をPosに変換
-}
pointToPos : Number -> Number -> Pos
pointToPos x y =
    ( div (x + windowWidth * 0.5) size, div (y + windowHeight * 0.5) size )


{-| セルをクリックした時の処理
そのセルが不在なら誕生、生存なら消滅させる
-}
drawCell : Pos -> Board -> Board
drawCell pos board =
    if isEmpty board pos then
        pos :: board

    else
        board


{-| 存在判定
pがbの要素であれば存在と判定
-}
isExist : Board -> Pos -> Bool
isExist board pos =
    List.filter (\p -> p == pos) board /= []


{-| 虚無判定：存在の逆
-}
isEmpty : Board -> Pos -> Bool
isEmpty board pos =
    not (isExist board pos)



------------------------------------------------------------------------
-- UTILITY
-- Number型に使える整数の割り算がないので自作


{-| Number型に対する割り算の剰余
-}
mod : Number -> Number -> Number
mod x y =
    if x < 0 then
        mod (x + y) y

    else if x < y then
        x

    else
        mod (x - y) y


{-| Number型に対する割り算の商
-}
div : Number -> Number -> Number
div x y =
    if x < 0 then
        -1 + div (x + y) y

    else if x < y then
        0

    else
        1 + div (x - y) y
