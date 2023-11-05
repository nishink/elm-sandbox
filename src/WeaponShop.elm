module WeaponShop exposing (..)

-------------
-- 武器屋さん
-------------

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



--------------------------------------------------------------------------------
-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



--------------------------------------------------------------------------------
-- MODEL


{-| 販売品。
-}
type alias Item =
    { name : String -- 品名
    , price : Int -- 価格
    }


{-| 販売品リスト。
-}
itemData : List Item
itemData =
    [ Item "こんぼう" 30
    , Item "銅の剣" 100
    ]


{-| 品名をキーに販売品リストから販売品を取得。
-}
getItem : String -> List Item -> Item
getItem name list =
    let
        target =
            List.filter (\item -> item.name == name) list
    in
    List.head target
        |> Maybe.withDefault (Item "ダミー" 0)


{-| 状態を表す型の別名。
-}
type alias Model =
    { inventory : Dict String Int -- 所持品（辞書型）、持っているアイテム名とその個数
    , money : Int -- 所持金
    , message : String -- 表示するメッセージ（武器屋の店主のセリフ）
    , command : List (Html Msg) -- 表示するボタン（買う、売るなどのコマンド）
    }


{-| 初期状態。
所持品なし、所持金1000G。
-}
init : Model
init =
    Model Dict.empty
        1000
        initMessage
        initCommand


{-| 最初のメッセージ。
-}
initMessage : String
initMessage =
    "ここは武器の店だ。何か用かい？"


{-| 最初のコマンド。
-}
initCommand : List (Html Msg)
initCommand =
    [ commandButton [ onClick Buy ] [ text "買いに来た" ]
    , commandButton [ onClick Sell ] [ text "売りに来た" ]
    ]


{-| コマンドボタン。
形状を統一するためのスタイルを指定。
-}
commandButton : List (Attribute msg) -> List (Html msg) -> Html msg
commandButton attributes children =
    button
        (attributes
            ++ [ style "width" "200px", style "height" "50px" ]
        )
        children



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を示す型。
-}
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


{-| 更新処理。
-}
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
                        [ commandButton [ onClick (BuyYes item) ] [ text "はい" ]
                        , commandButton [ onClick BuyNo ] [ text "いいえ" ]
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
                    [ commandButton [ onClick (SellYes item) ] [ text "はい" ]
                    , commandButton [ onClick SellNo ] [ text "いいえ" ]
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


{-| 武器屋が売っているものの一覧を表示。
「買いに来た」を選んだ時に表示する。
-}
sales : List Item -> List (Html Msg)
sales items =
    List.append
        (List.map
            (\item ->
                commandButton
                    [ onClick (BuyItem item) ]
                    [ text <| item.name ++ "(" ++ String.fromInt item.price ++ "G)" ]
            )
            items
        )
        [ commandButton [ onClick Init ] [ text "やめる" ] ]


{-| 客が持っているものの一覧を表示。
「売りに来た」を選んだ時に表示する。
-}
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
                    commandButton
                        [ onClick (SellItem item) ]
                        [ text <| k ++ "(" ++ String.fromInt item.price ++ "G)" ]
                )
        )
        [ commandButton [ onClick Init ] [ text "やめる" ] ]



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
メッセージ（武器屋のセリフ）、コマンドボタン、所持金と所持品の一覧を表示。
-}
view : Model -> Html Msg
view model =
    div []
        (List.append
            (div [] [ text model.message ] :: model.command)
            [ viewInventory model ]
        )


{-| 所持金と所持品の一覧を表示。
-}
viewInventory : Model -> Html Msg
viewInventory model =
    let
        tableStyle =
            [ style "border" "1px solid gray", style "width" "200px" ]
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
