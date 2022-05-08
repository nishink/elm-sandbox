module WeaponShop exposing (..)

-------------
-- 武器屋さん
-------------

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Item =
    { name : String, price : Int }


itemData : List Item
itemData =
    [ Item "こんぼう" 30
    , Item "銅の剣" 100
    ]


getItem : String -> List Item -> Item
getItem name list =
    let
        target =
            List.filter (\item -> item.name == name) list
    in
    List.head target
        |> Maybe.withDefault (Item "ダミー" 0)


type alias Model =
    { inventory : Dict String Int
    , money : Int
    , message : String
    , command : List (Html Msg)
    }


init : Model
init =
    Model Dict.empty
        1000
        initMessage
        initCommand


initMessage : String
initMessage =
    "ここは武器の店だ。何か用かい？"


initCommand : List (Html Msg)
initCommand =
    [ button [ onClick Buy ] [ text "買いに来た" ]
    , button [ onClick Sell ] [ text "売りに来た" ]
    ]



-- UPDATE


type Msg
    = Buy
    | BuyItem Item
    | BuyYes Item
    | BuyNo
    | Init
    | Sell
    | SellItem Item
    | SellYes Item
    | SellNo


update : Msg -> Model -> Model
update msg model =
    case msg of
        -- 買いに来た
        Buy ->
            { model | message = "何を買うかい？", command = sales itemData }

        -- 選んだものを買う
        BuyItem item ->
            if item.price > model.money then
                { model | message = "お金が足りないようだな。他のものを買うかい？", command = sales itemData }

            else
                { model
                    | message = item.name ++ "は" ++ String.fromInt item.price ++ "ゴールドだよ。買うかい？"
                    , command =
                        [ button [ onClick (BuyYes item) ] [ text "はい" ]
                        , button [ onClick BuyNo ] [ text "いいえ" ]
                        ]
                }

        -- 買う？ -> はい
        BuyYes item ->
            { model
                | money = model.money - item.price
                , inventory =
                    Dict.update item.name
                        (\x ->
                            case x of
                                Nothing ->
                                    Just 1

                                Just v ->
                                    Just (v + 1)
                        )
                        model.inventory
                , message = "はいよ！ 毎度あり！ 他にも何か買うかい？"
                , command = sales itemData
            }

        -- 買う？ -> いいえ
        BuyNo ->
            { model | message = "他のものを買うかい？", command = sales itemData }

        -- やめて最初から
        Init ->
            { model | message = initMessage, command = initCommand }

        -- 売る
        Sell ->
            { model | message = "何を売るかい？", command = itemList model.inventory }

        -- 選んだものを売る
        SellItem item ->
            let
                price =
                    String.fromInt item.price
            in
            { model
                | message = item.name ++ "は" ++ price ++ "ゴールドで引き取るよ。それでいいかい？"
                , command =
                    [ button [ onClick (SellYes item) ] [ text "はい" ]
                    , button [ onClick SellNo ] [ text "いいえ" ]
                    ]
            }

        -- 売る -> はい
        SellYes item ->
            let
                newInventory =
                    case Dict.get item.name model.inventory of
                        --　持ってないものを売った（あり得ないケース）
                        Nothing ->
                            model.inventory

                        -- １つしかない場合は持ち物から削除
                        Just 1 ->
                            Dict.remove item.name model.inventory

                        -- 複数所持している場合は１つ減らす
                        Just v ->
                            Dict.update item.name (\_ -> Just (v - 1)) model.inventory
            in
            { model
                | money = model.money + item.price
                , inventory = newInventory
                , message = "はいよ！ 毎度あり！ 他にも何か売るかい？"
                , command = itemList newInventory
            }

        -- 売る -> いいえ
        SellNo ->
            { model | message = "他のものを売るかい？", command = itemList model.inventory }


sales : List Item -> List (Html Msg)
sales items =
    List.append
        (List.map
            (\item ->
                button
                    [ onClick (BuyItem item) ]
                    [ text <| item.name ++ "(" ++ String.fromInt item.price ++ "G)" ]
            )
            items
        )
        [ button [ onClick Init ] [ text "やめる" ] ]


itemList : Dict String Int -> List (Html Msg)
itemList inventory =
    List.append
        (Dict.toList inventory
            |> List.map
                (\( k, _ ) ->
                    let
                        item =
                            getItem k itemData
                    in
                    button
                        [ onClick (SellItem item) ]
                        [ text <| k ++ "(" ++ String.fromInt item.price ++ "G)" ]
                )
        )
        [ button [ onClick Init ] [ text "やめる" ] ]



-- VIEW


view : Model -> Html Msg
view model =
    div []
        (List.append
            (div [] [ text model.message ] :: model.command)
            [ viewInventory model ]
        )


viewInventory : Model -> Html Msg
viewInventory model =
    let
        tableStyle =
            [ style "border" "1px solid gray" ]
    in
    table tableStyle
        (List.append
            [ tr [] [ th tableStyle [ text "所持金" ] ]
            , tr [] [ td tableStyle [ text <| String.fromInt model.money ] ]
            , tr [] [ th tableStyle [ text "所持品" ] ]
            ]
            (Dict.toList model.inventory
                |> List.map
                    (\( k, v ) ->
                        tr [] [ td tableStyle [ text <| k ++ "(" ++ String.fromInt v ++ "個)" ] ]
                    )
            )
        )
