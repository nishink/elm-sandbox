module Clock exposing (..)

-- Show the current time in your time zone.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/time.html
--
-- For an analog clock, check out this SVG example:
--   https://elm-lang.org/examples/clock
--

import Browser
import Html exposing (..)
import Html.Attributes as HA
import Html.Events exposing (..)
import Svg exposing (Svg, circle, line, svg)
import Svg.Attributes exposing (..)
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone -- 使用するタイムゾーン
    , time : Time.Posix -- 1970年からの経過秒数
    , stop : Bool -- 時計の停止状態
    }


init : () -> ( Model, Cmd Msg )
init _ =
    -- UTC, POSIX 0秒, 停止しない, を初期値とする
    ( Model Time.utc (Time.millisToPosix 0) False
    , Cmd.batch
        -- 実行環境のタイムゾーンで時間を調節
        -- Taskは失敗する可能性のある非同期操作を実行する
        [ Task.perform AdjustTimeZone Time.here

        -- 現在時刻を設定
        , Task.perform Tick Time.now
        ]
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | Stop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- 表示時刻の更新
        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        -- タイムゾーンの調節
        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none )

        -- 時計の停止、解除
        Stop ->
            ( { model | stop = not model.stop }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.stop then
        Sub.none

    else
        Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time)
                |> String.padLeft 2 '0'

        minute =
            String.fromInt (Time.toMinute model.zone model.time)
                |> String.padLeft 2 '0'

        second =
            String.fromInt (Time.toSecond model.zone model.time)
                |> String.padLeft 2 '0'

        btnText =
            if model.stop then
                "再開"

            else
                "停止"
    in
    div []
        [ div
            [ HA.style "background-color" "silver"
            , HA.style "height" "60px"
            , HA.style "width" "220px"
            , HA.style "font-size" "60px"
            , HA.style "text-align" "center"
            ]
            [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
        , viewShape model
        , button [ HA.style "font-size" "16pt", onClick Stop ] [ text btnText ]
        ]


viewShape : Model -> Html Msg
viewShape model =
    let
        hour =
            toFloat (Time.toHour model.zone model.time)

        minute =
            toFloat (Time.toMinute model.zone model.time)

        second =
            toFloat (Time.toSecond model.zone model.time)
    in
    svg
        [ viewBox "0 0 400 400"
        , width "400"
        , height "400"
        ]
        [ circle [ cx "200", cy "200", r "120", fill "#1293D8" ] []
        , viewHand 6 60 (hour / 12) "white"
        , viewHand 6 90 (minute / 60) "white"
        , viewHand 3 90 (second / 60) "red"
        ]


viewHand : Int -> Float -> Float -> String -> Svg msg
viewHand width length turns color =
    let
        t =
            2 * pi * (turns - 0.25)

        x =
            200 + length * cos t

        y =
            200 + length * sin t
    in
    line
        [ x1 "200"
        , y1 "200"
        , x2 (String.fromFloat x)
        , y2 (String.fromFloat y)
        , stroke color
        , strokeWidth (String.fromInt width)
        , strokeLinecap "round"
        ]
        []
