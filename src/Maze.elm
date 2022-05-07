module Maze exposing (..)

import Array
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


wall =
    "#"


floor =
    "_"


type alias Array2D a =
    Array.Array (Array.Array a)


set2D : ( Int, Int ) -> a -> Array2D a -> Array2D a
set2D ( x, y ) value array =
    let
        line =
            Array.get y array
                |> Maybe.withDefault Array.empty
    in
    Array.set y (Array.set x value line) array


get2D : ( Int, Int ) -> Array2D a -> Maybe a
get2D ( x, y ) array =
    Array.get y array
        |> Maybe.withDefault Array.empty
        |> Array.get x


getWidth : Array2D a -> Int
getWidth array =
    Array.get 0 array |> Maybe.withDefault Array.empty |> Array.length


getHeight : Array2D a -> Int
getHeight array =
    Array.length array


type alias Model =
    { map : Array2D String
    , size : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        size =
            33
    in
    ( Model (initMap size size) size
    , generateRandomDirections size size
    )


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



-- UPDATE


type Direction
    = South
    | West
    | East
    | North


type Msg
    = Roll ( Int, Int )
    | NewMaze ( List Direction, List Direction )
    | ChangeSize Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ( width, height ) ->
            ( Model (initMap width height) model.size
            , generateRandomDirections width height
            )

        NewMaze ( headLine, tailLine ) ->
            let
                width =
                    getWidth model.map

                height =
                    getHeight model.map
            in
            ( { model | map = boutaoshi (List.append headLine tailLine) ( 2, 2 ) (initMap width height) }
            , Cmd.none
            )

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



-- 棒倒し法による壁生成


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick (Roll ( model.size, model.size )) ] [ text "create maze" ]
        , button [ onClick (ChangeSize -2) ] [ text "size down" ]
        , button [ onClick (ChangeSize 2) ] [ text "size up" ]

        --        , div [] (linefeed <| viewMaze model)
        , div [] [ viewMazeTable model ]
        ]


viewMaze : Model -> String
viewMaze model =
    List.map (\x -> String.concat (Array.toList x) ++ "\n") (Array.toList model.map)
        |> String.concat
        |> String.trimRight


linefeed : String -> List (Html Msg)
linefeed str =
    String.lines str
        |> List.concatMap (\s -> [ text s, br [] [] ])


wallCell : Html Msg
wallCell =
    td [ style "background-color" "black", style "height" "16px", style "width" "16px" ] []


floorCell : Html Msg
floorCell =
    td [ style "background-color" "white", style "height" "16px", style "width" "16px" ] []


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
