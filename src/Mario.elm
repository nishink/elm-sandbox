-- Walk around with the arrow keys. Press the UP arrow to jump!
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/
--


module Mario exposing (main, toGif, update, view)

{-| マリオのサンプル。

@docs main view update init toGif

-}

import Playground exposing (..)



--------------------------------------------------------------------------------
-- MAIN


main =
    game view update init



--------------------------------------------------------------------------------
-- MODEL


{-| 状態を保持する型の別名。
マリオの位置、速度、向きを保持。
-}
type alias Model =
    { x : Number, y : Number, vx : Number, vy : Number, dir : String }


{-| 初期状態。
マリオは静止しており、右を向いている。
-}
init : Model
init =
    Model 0 0 0 0 "right"



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
背景の空、地面、マリオを表示。
-}
view computer mario =
    let
        w =
            computer.screen.width

        h =
            computer.screen.height

        b =
            computer.screen.bottom
    in
    [ rectangle (rgb 174 238 238) w h
    , rectangle (rgb 74 163 41) w 100
        |> moveY b
    , image 70 70 (toGif mario)
        |> move mario.x (b + 76 + mario.y)
    ]


{-| マリオの状態から画像のURLを取得。
-}
toGif : Model -> String
toGif mario =
    if mario.y > 0 then
        "https://elm-lang.org/images/mario/jump/" ++ mario.dir ++ ".gif"

    else if mario.vx /= 0 then
        "https://elm-lang.org/images/mario/walk/" ++ mario.dir ++ ".gif"

    else
        "https://elm-lang.org/images/mario/stand/" ++ mario.dir ++ ".gif"



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理。
-}
update computer mario =
    let
        -- 重力加速度
        dt =
            1.666

        -- 左右のキー押下状態を横移動速度に変換
        vx =
            toX computer.keyboard

        vy =
            if mario.y == 0 then
                -- 地面についている時
                if computer.keyboard.up then
                    -- 上でジャンプ
                    5

                else
                    0

            else
                -- 地面についていないときは落下
                mario.vy - dt / 8

        x =
            mario.x + dt * vx

        y =
            max 0 (mario.y + dt * vy)

        dir =
            if vx == 0 then
                mario.dir

            else if vx < 0 then
                "left"

            else
                "right"
    in
    Model x y vx vy dir
