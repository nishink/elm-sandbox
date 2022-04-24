module SimpleRpg exposing (..)

import Browser
import Html exposing (Html, br, button, div, text)
import Html.Events exposing (onClick)



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { message : String
    , player : Charactor
    , monster : Charactor
    , boss : Charactor
    }


type alias Charactor =
    { name : String
    , hp : Int
    , maxHp : Int
    , attack : Int
    , defence : Int
    }


type alias BattleModel =
    { message : String
    , player : Charactor
    , enemy : Charactor
    }


init : Model
init =
    { message = ""
    , player = Charactor "プレイヤー" 15 15 10 5
    , monster = Charactor "モンスター" 10 10 10 5
    , boss = Charactor "ラスボス" 1000 1000 100 50
    }



-- UPDATE


type Msg
    = StayInn
    | FightMonster
    | FightBoss


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


recover : Charactor -> Charactor
recover charactor =
    { charactor | hp = charactor.maxHp }


hurt : Charactor -> Int -> Charactor
hurt charactor damage =
    { charactor | hp = charactor.hp - damage }


levelUp : Charactor -> Charactor
levelUp charactor =
    { charactor
        | maxHp = charactor.maxHp + 1
        , attack = charactor.attack + 1
        , defence = charactor.defence + 1
    }


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


msgDamage : Charactor -> Charactor -> Int -> String
msgDamage attacker defender damage =
    attacker.name
        ++ "の攻撃！\u{3000}"
        ++ defender.name
        ++ "に"
        ++ String.fromInt damage
        ++ "のダメージ！\n"


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



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick StayInn ] [ text "宿に泊まる" ]
        , button [ onClick FightMonster ] [ text "ザコと戦う" ]
        , button [ onClick FightBoss ] [ text "ボスと戦う" ]
        , div [] [ text (getStatus model.player) ]
        , div [] (linefeed model.message)
        ]


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


linefeed : String -> List (Html msg)
linefeed message =
    String.lines message
        |> List.concatMap (\s -> [ text s, br [] [] ])
