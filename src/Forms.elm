module Forms exposing (..)

-- Input a user name and password. Make sure the password matches.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/forms.html
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    }


init : Model
init =
    Model "" "" ""



-- UPDATE


type Msg
    = Name String
    | Password String
    | PasswordAgain String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Password password ->
            { model | password = password }

        PasswordAgain password ->
            { model | passwordAgain = password }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewInput "text" "Name" model.name Name
        , viewInput "password" "Password" model.password Password
        , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
        , viewValidation model
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
    if model.password /= model.passwordAgain then
        -- パスワード不一致
        div [ style "color" "red" ] [ text "Passwords do not match!" ]

    else if String.length model.password < 8 then
        -- パスワードが八文字より短い
        div [ style "color" "red" ] [ text "Password is too short!" ]

    else if
        not
            (String.any Char.isUpper model.password
                && String.any Char.isLower model.password
                && String.any Char.isDigit model.password
            )
    then
        -- パスワードには大文字、小文字、数字が含まれていないといけない
        div [ style "color" "red" ] [ text "Include uppercase letters, lowercase letters, and numbers in the password." ]

    else
        div [ style "color" "green" ] [ text "OK" ]
