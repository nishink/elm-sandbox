-- https://elm-lang.org/examples/mouse
-- Draw a cicle around the mouse. Change its color by pressing down.
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/
--


module Mouse exposing (main, update, view)

{-| マウスの動きに合わせて円を表示するプログラム。
-}

import Playground exposing (..)



--------------------------------------------------------------------------------
-- MAIN


{-| エントリポイント。
状態は何も持たない。
-}
main =
    game view update ()



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
明るい紫の直径15ピクセルの縁を、マウスポインタの位置に合わせて表示。
マウスボタンを押している時、色を薄くする。
-}
view computer _ =
    [ circle lightPurple 15
        |> moveX computer.mouse.x
        |> moveY computer.mouse.y
        |> fade
            (if computer.mouse.down then
                0.2

             else
                1
            )
    ]



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理。
-}
update _ memory =
    memory
