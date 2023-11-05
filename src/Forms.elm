module Forms exposing (..)

{-| フォームのサンプル。
<https://guide.elm-lang.jp/architecture/forms.html>

@docs main init update view

-}

-- Input a user name and password. Make sure the password matches.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/forms.html
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



--------------------------------------------------------------------------------
-- MAIN


{-| エントリポイント。
Browser.sandboxは最もシンプルなSPAの雛形。
-}
main =
    Browser.sandbox { init = init, update = update, view = view }



--------------------------------------------------------------------------------
-- MODEL


{-| 状態を表す型の別名。
このプログラムではレコードで状態を保持する。
-}
type alias Model =
    { name : String -- 名前
    , password : String -- パスワード
    , passwordAgain : String -- パスワード再入力
    }


{-| 状態の初期値。
名前とパスワードはいずれも空文字列を設定。
-}
init : Model
init =
    Model "" "" ""



--------------------------------------------------------------------------------
-- UPDATE


{-| 更新処理の種類を表す型を定義。
型名の後ろに型をつけると、引数のついた型として定義する。
例えば Change String と書くと、 (String -> Msg) という型として扱う。
すなわち、String型の引数を指定して初めてMsg型となる型、という意味になる。
-}
type Msg
    = Name String -- 名前入力時のメッセージ
    | Password String -- パスワード入力時のメッセージ
    | PasswordAgain String -- パスワード再入力時のメッセージ


{-| 更新処理。
メッセージを受けて状態を更新する。
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Password password ->
            { model | password = password }

        PasswordAgain password ->
            { model | passwordAgain = password }



--------------------------------------------------------------------------------
-- VIEW


{-| 描画処理。
名前、パスワード、パスワード再入力の欄を表示。
パスワードが規則に合わない場合のエラーメッセージを表示。
-}
view : Model -> Html Msg
view model =
    div []
        [ viewInput "text" "Name" model.name Name
        , viewInput "password" "Password" model.password Password
        , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
        , viewValidation model
        ]


{-| 入力欄を表示。
引数は左から、HTMLタグのタイプ、HTMLタグ名、入力欄の値、入力時に送信するメッセージ。

    viewInput "text" "Name" model.name Name

-}
viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


{-| 入力値が規則に合わない時のエラーメッセージを表示。
-}
viewValidation : Model -> Html msg
viewValidation model =
    let
        failureStyle =
            style "color" "red"

        successStyle =
            style "color" "green"
    in
    if model.password /= model.passwordAgain then
        -- パスワード不一致
        div [ failureStyle ] [ text "Passwords do not match!" ]

    else if String.length model.password < 8 then
        -- パスワードが八文字より短い
        div [ failureStyle ] [ text "Password is too short!" ]

    else if
        not
            (String.any Char.isUpper model.password
                && String.any Char.isLower model.password
                && String.any Char.isDigit model.password
            )
    then
        -- パスワードには大文字、小文字、数字が含まれていないといけない
        div [ failureStyle ]
            [ text "Include uppercase letters, lowercase letters, and numbers in the password." ]

    else
        div [ successStyle ] [ text "OK" ]
