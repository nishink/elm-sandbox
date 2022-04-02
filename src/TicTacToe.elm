module TicTacToe exposing (..)

-- Tic Tac Toe - React Tutorial
-- https://ja.reactjs.org/tutorial/tutorial.html

import Array exposing (Array)
import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Maybe



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { squares : Array String
    , xIsNext : Bool
    }


init : Model
init =
    { squares = Array.initialize 9 (always "")
    , xIsNext = True
    }



-- UPDATE


type Msg
    = Click Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        Click index ->
            if calculateWinner model.squares /= "" || get index model.squares /= "" then
                model

            else
                { model
                    | squares = Array.set index (next model) model.squares
                    , xIsNext = not model.xIsNext
                }


next : Model -> String
next model =
    if model.xIsNext then
        "X"

    else
        "O"



-- VIEW
-- tag [attributes] [child elements]


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


get : Int -> Array String -> String
get index array =
    Maybe.withDefault "" (Array.get index array)


calculateWinner : Array String -> String
calculateWinner squares =
    let
        lines =
            [ ( 0, 1, 2 ), ( 3, 4, 5 ), ( 6, 7, 8 ), ( 0, 3, 6 ), ( 1, 4, 7 ), ( 2, 5, 8 ), ( 0, 4, 8 ), ( 2, 4, 6 ) ]

        calc ( a, b, c ) =
            if get a squares /= "" && get a squares == get b squares && get a squares == get c squares then
                get a squares

            else
                ""
    in
    String.concat (List.map calc lines)
