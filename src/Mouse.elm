-- https://elm-lang.org/examples/mouse
-- Draw a cicle around the mouse. Change its color by pressing down.
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/
--


module Mouse exposing (main, update, view)

import Playground exposing (..)



-- MAIN


main =
    game view update ()



-- VIEW


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



-- UPDATE


update _ memory =
    memory
