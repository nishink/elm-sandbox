# elm-sandboxリポジトリ

## Elmとは

[Elm](https://guide.elm-lang.jp)とは、
ブラウザフロントエンド専用の関数型言語。  
haskellに似た文法で、動的なWebサイトが作れる。

機能を制限しており、覚えることが少ない。  
エラーメッセージがとても親切。

### 基本的な文法
https://elm-lang.org/docs/syntax

### 参考文献
- [Elm開発環境について](https://qiita.com/sand/items/9afaef65c6f1ebf453da)
- [初心者のElm入門](https://zenn.dev/lfz/articles/d97df2e89eae0b)

## インストール
$ npm install -g elm

エラーが出る場合は先頭にsudoをつける。

## Elmプロジェクトの作成
適当なフォルダを作成して、

$ elm init

を実行。

elm.jsonファイルとsrcフォルダが作られる。

```
[2022-03-24 05:43:05]~/doc/elm $ mkdir hello
[2022-03-24 05:49:54]~/doc/elm $ cd hello/
[2022-03-24 05:49:55]~/doc/elm/hello $ elm init
Hello! Elm projects always start with an elm.json file. I can create them!

Now you may be wondering, what will be in this file? How do I add Elm files to
my project? How do I see it in the browser? How will my code grow? Do I need
more directories? What about tests? Etc.

Check out <https://elm-lang.org/0.19.1/init> for all the answers!

Knowing all that, would you like me to create an elm.json file now? [Y/n]: y
Okay, I created it. Now read that link!
[2022-03-24 05:51:17]~/doc/elm/hello $ ls
elm.json	src/
[2022-03-24 05:52:08]~/doc/elm/hello $ ls src/
[2022-03-24 05:52:12]~/doc/elm/hello $ 
```

## サンプルプロジェクトの実行
src/Main.elm
を作成し、サンプルコードを添付。

$ elm reactor

で実行。

http://localhost:8000
でブラウザを開くと、
GitHubのような画面が現れる。

src/Main.elmのリンクを辿っていくことで、作ったプログラムを表示できる。
```
[2022-03-24 05:54:47]~/doc/elm/hello/src $ touch Main.elm
[2022-03-24 05:54:53]~/doc/elm/hello/src $ cd ..
[2022-03-24 05:59:58]~/doc/elm/hello $ elm reactor
Go to http://localhost:8000 to see your project dashboard.
```

## 作ったプログラムのリリース

### ブラウザで開くindex.htmlを作成するコマンド

$ elm make src/Main.elm

Main.elmで書いたコードがindex.html内にJavaScriptで展開される。  
リリース時はindex.htmlだけサーバにあげれば良い。

```
[2022-03-24 06:10:32]~/doc/elm/hello $ elm make src/Main.elm 
Success!     

    Main ───> index.html
```

### Main.elmをelm.jsにビルドするコマンド

$ elm make src/Main.elm --optimize --output=elm.js

jsライブラリとして既存のページから読み込みたいときはこちら。

```
[2022-03-24 06:10:51]~/doc/elm/hello $ elm make src/Main.elm --optimize --output=elm.js
Success!     

    Main ───> elm.js
```

## VSCode Elmプラグイン

VSCodeプラグインとして'Elm'をインストール。
以下も追加でインストール。

$ sudo npm install -g elm-test elm-format

elm-formatを使って、ソースの保存時に自動でフォーマットできる。  
ただしVSCodeの設定が汚くなる上、余計な改行が大量に入るのでいまいちな感じではある。

- VSCodeの設定はワークスペースごとに保存できる。  
  elm直下の.vscode/setting.jsonに定義することで設定が汚くなることを回避した。  
  余計な改行が多いのは、これがelmの流儀なんだと慣れるしかない。
- elm initで新規に作成したプロジェクトで、保存時のフォーマットが効かなくなることがあった。 
  VSCodeを終了して開き直したら効いた。


## REPL(コマンドラインインタプリタ)

$ sudo elm repl

sudoなしだとpermission deniedが出る。


## Unit test
elm-test initコマンドで単体テスト環境を初期化する。

```
[2022-04-18 21:14:16]~/doc/elm/beginning-elm $ elm-test init
Here is my plan:
  
  Add:
    elm/random               1.0.0
    elm-explorations/test    1.2.2

Would you like me to update your elm.json accordingly? [Y/n]: y
Success!

Check out the documentation for getting started at https://package.elm-lang.org/packages/elm-explorations/test/latest
[2022-04-18 21:14:34]~/doc/elm/beginning-elm $ 
```

tests/Example.elm
が作られるので、テストコードを書いてelm-testを実行する。

```
[2022-04-18 21:14:34]~/doc/elm/beginning-elm $ elm-test
Compiling > Starting tests

elm-test 0.19.1-revision7
-------------------------

Running 1 test. To reproduce these results, run: elm-test --fuzz 100 --seed 300329023967384


TEST RUN PASSED

Duration: 143 ms
Passed:   1
Failed:   0

[2022-04-19 04:44:46]~/doc/elm/beginning-elm $ 
```

テスト対象は、module宣言で公開しているものが対象となる。

特定のテストだけ実行したい場合は、テストコードのファイル名を指定する。

```
[2022-04-19 04:57:36]~/doc/elm/beginning-elm $ elm-test tests/RippleCarryAdderTests.elm 
```

## elmのバージョンアップ
[2022.5.28追記]  
書籍「プログラミングElm」の６章で、
sarad builderのアプリを動かそうとしてエラーになる。

どうも、npm installで、
ローカルにインストールしたelmのバージョンが0.19.0で
elm.jsonに書いてある0.19.1と合わない様子。

$ npm install elm

で、ローカルのバージョンを上げて対応した。  
（-gをつけないとローカルの/node_modules/.bin/にインストールされる）


## 追加プラグインのインストール
[2023.1.9追記]

$ elm install elm/http


## コメントの書き方

[Elmのコメント記法について調べてみた](https://qiita.com/Atzz/items/641b5d4548d4ffa1827e)

```Elm
-- 単行コメント
```

```Elm
{-
複数行
コメント
-}
```

```Elm
{-| 関数へのコメント
最初の行は{-|のあとにスペースを入れてコメントを記述する。
次の行からは行頭からスペースなしで記述する。

    使用例はスペース４つあけて記述する。
-}
```

```Elm
{-| モジュールへのコメント
ここに関数の説明と同様に、モジュールの概要やサマリーを記載します。
モジュール内で記載されている関数等に関しては以下にカテゴライズして記載します。

# カテゴリー1

@docs func1


# カテゴリー2

@docs func2 func3

-}
```


## 他の言語をやってると忘れるElm独特の文法

### 「:」と「::」

Elmは型注釈が「:」で、リストの先頭要素追加が「::」。  
Haskellは型注釈が「::」で、リストの先頭要素追加が「:」。

```Elm
-- Elm
True : Bool
1 :: [2,3,4]
```

```Haskell
-- Haskell
True :: Bool
1 : [2,3,4]
```

### パイプライン演算子「|>」

```Elm
-- BEFORE
sanitize : String -> Maybe Int
sanitize input =
  String.toInt (String.trim input)
```

```Elm
-- AFTER
sanitize : String -> Maybe Int
sanitize input =
  input
    |> String.trim
    |> String.toInt
```

### 制約付き型変数
[型を読む](https://guide.elm-lang.jp/types/reading_types.html)より引用。

```Elm
negate : number -> number
```
- numberにはIntかFloatを当てはめられます
- appendableにはStringかList aを当てはめられます
- comparableにはIntかFloat,Char,String,そしてcomparableな値で構成されるリストまたはタプルを当てはめられます
- compappendにはStringかList comparableを当てはめられます

## HakellにあってElmにないもの

条件分岐は if then else か case of しかない。パターンマッチとガードはない。

[Haskellで比較/判定を行う4つの方法(if/case/パターンマッチ/ガード)](https://zenn.dev/masahiro_toba/articles/39aa954f402e27)

let in はあるが、where はない。

[let、whereはなぜ必要か？【Haskellにおける局所的な変数】](https://zenn.dev/masahiro_toba/articles/7a60ea19b08208)


