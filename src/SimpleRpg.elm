module SimpleRpg exposing (..)

{-| シンプルRPG。

@docs init update view

-}

import Browser
import Html exposing (Html, br, button, div, text)
import Html.Events exposing (onClick)



--------------------------------------------------------------------------------
-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



--------------------------------------------------------------------------------
-- MODEL


{-| 状態を表す型の別名。
-}
type alias Model =
    { message : String -- 表示するメッセージ
    , player : Charactor -- プレイヤー
    , monster : Charactor -- モンスター
    , boss : Charactor -- ボス
    }


{-| キャラクターを表す型の別名。
プレイヤー、モンスター、ボスをまとめて扱う。
-}
type alias Charactor =
    { name : String -- 名前
    , hp : Int -- HP
    , maxHp : Int -- 最大HP
    , attack : Int -- 攻撃力
    , defence : Int -- 守備力
    }


{-| 戦闘中の状態を表す型の別名。
-}
type alias BattleModel =
    { message : String -- 表示するメッセージ
    , player : Charactor -- プレイヤー
    , enemy : Charactor -- 戦う相手（モンスターまたはボス）
    }


{-| 初期状態。
-}
init : Model
init =
    { message = ""
    , player = Charactor "プレイヤー" 15 15 10 5
    , monster = Charactor "モンスター" 10 10 10 5
    , boss = Charactor "ラスボス" 1000 1000 100 50
    }



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を表す型。
いわゆるコマンド。
-}
type Msg
    = StayInn
    | FightMonster
    | FightBoss


{-| 更新処理。
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        -- 宿に泊まる
        StayInn ->
            { model
                | message = "HPが回復した。\n"
                , player = recover model.player
            }

        -- ザコと戦う
        FightMonster ->
            let
                fought =
                    fightMonster (BattleModel "" model.player model.monster)
            in
            { model | message = fought.message, player = fought.player, monster = fought.enemy }

        -- ボスと戦う
        FightBoss ->
            let
                fought =
                    fightBoss (BattleModel "" model.player model.boss)
            in
            { model | message = fought.message, player = fought.player, boss = fought.enemy }


{-| 回復する
-}
recover : Charactor -> Charactor
recover charactor =
    { charactor | hp = charactor.maxHp }


{-| ダメージを与える
-}
hurt : Charactor -> Int -> Charactor
hurt charactor damage =
    { charactor | hp = charactor.hp - damage }


{-| レベルアップ
-}
levelUp : Charactor -> Charactor
levelUp charactor =
    { charactor
        | maxHp = charactor.maxHp + 1
        , attack = charactor.attack + 1
        , defence = charactor.defence + 1
    }


{-| ダメージ計算
-}
calcDamage : Charactor -> Charactor -> Int
calcDamage attacker defender =
    let
        damage =
            attacker.attack - defender.defence
    in
    if damage < 0 then
        0

    else
        damage


{-| ダメージを与えたメッセージ
-}
msgDamage : Charactor -> Charactor -> Int -> String
msgDamage attacker defender damage =
    attacker.name
        ++ "の攻撃！\u{3000}"
        ++ defender.name
        ++ "に"
        ++ String.fromInt damage
        ++ "のダメージ！\n"


{-| たたかう
-}
fight : BattleModel -> BattleModel
fight model =
    -- プレイヤーが死んでいるとき
    if model.player.hp <= 0 then
        { model | message = model.player.name ++ "は戦える状態ではない。\n" }

    else
        -- プレイヤーが生きているときはプレイヤーの攻撃
        let
            enemyDamage =
                calcDamage model.player model.enemy

            message =
                msgDamage model.player model.enemy enemyDamage

            enemy =
                hurt model.enemy enemyDamage
        in
        -- プレイヤーの攻撃で敵を倒した
        if model.enemy.hp <= enemyDamage then
            { model
                | message = message ++ model.enemy.name ++ "を倒した！\n"
                , enemy = enemy
            }

        else
            -- プレイヤーの攻撃で敵を倒しきれてない
            let
                playerDamage =
                    calcDamage model.enemy model.player

                message2 =
                    msgDamage model.enemy model.player playerDamage

                player =
                    hurt model.player playerDamage
            in
            -- 敵の攻撃でプレイヤーが死んでしまった
            if model.player.hp <= playerDamage then
                { model
                    | message = message ++ message2 ++ model.player.name ++ "は死んでしまった！\n"
                    , player = player
                    , enemy = enemy
                }

            else
                -- 敵の攻撃を受けてもプレイヤーは生きている
                { model
                    | message = message ++ message2
                    , player = player
                    , enemy = enemy
                }


{-| ザコ敵と戦う
-}
fightMonster : BattleModel -> BattleModel
fightMonster model =
    let
        fought =
            fight model
    in
    if fought.enemy.hp <= 0 then
        { model
            | message = fought.message ++ "レベルアップ！\n"
            , player = levelUp fought.player
            , enemy = recover fought.enemy
        }

    else
        fought


{-| ボス敵と戦う
-}
fightBoss : BattleModel -> BattleModel
fightBoss model =
    if model.enemy.hp <= 0 then
        { model | message = model.enemy.name ++ "はもう倒した。\n" }

    else
        let
            fought =
                fight model
        in
        if fought.enemy.hp <= 0 then
            { fought | message = fought.message ++ "平和になった！\n" }

        else
            fought



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
-}
view : Model -> Html Msg
view model =
    div []
        [ button [ onClick StayInn ] [ text "宿に泊まる" ]
        , button [ onClick FightMonster ] [ text "ザコと戦う" ]
        , button [ onClick FightBoss ] [ text "ボスと戦う" ]
        , div [] [ text (getStatus model.player) ]
        , div [] (linefeed model.message)
        ]


{-| ステータス表示
-}
getStatus : Charactor -> String
getStatus charactor =
    "HP:"
        ++ String.fromInt charactor.hp
        ++ "/"
        ++ String.fromInt charactor.maxHp
        ++ " 攻撃力:"
        ++ String.fromInt charactor.attack
        ++ " 守備力:"
        ++ String.fromInt charactor.defence


{-| 改行文字をbrタグに置き換え
-}
linefeed : String -> List (Html msg)
linefeed message =
    String.lines message
        |> List.concatMap (\s -> [ text s, br [] [] ])
