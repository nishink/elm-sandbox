-- Walk around with the arrow keys. Press the UP arrow to jump!
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/
--


module Mario exposing (main, toGif, update, view)

import Playground exposing (..)



-- MAIN


main =
    game view update init



-- MODEL


type alias Model =
    { x : Number, y : Number, vx : Number, vy : Number, dir : String }


init : Model
init =
    Model 0 0 0 0 "right"



-- VIEW


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


toGif mario =
    if mario.y > 0 then
        "https://elm-lang.org/images/mario/jump/" ++ mario.dir ++ ".gif"

    else if mario.vx /= 0 then
        "https://elm-lang.org/images/mario/walk/" ++ mario.dir ++ ".gif"

    else
        "https://elm-lang.org/images/mario/stand/" ++ mario.dir ++ ".gif"



-- UPDATE


update computer mario =
    let
        dt =
            1.666

        vx =
            toX computer.keyboard

        vy =
            if mario.y == 0 then
                if computer.keyboard.up then
                    5

                else
                    0

            else
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
