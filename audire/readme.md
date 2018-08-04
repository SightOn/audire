# Readme

### 検討事項
*

### 開発アイテム
* ViewController(ina)
    * 全画面に共通する基本機能を実装する
    * __ダブルタップで録音画面へ__
        * __(08/05 14:00)ダブルタップ以外では画面下部から上スワイプとかもいいかも__
        * Googleのコマンドっぽいけど
    (Controllerの共通化，Viewの共通化をするならUIViewなどをもとにやったほうがよい？)
* Record ViewController(wake)
    * ホールドして録音開始
    * 離すと録音終了
* Post ViewController(wake, ina)
    * 上スワイプ？で投稿
    * データの保存
* Auto ViewController(wake)
    * ノイズ除去
    * 無音区間の除去
    * 処理中を示すビジュアル
* Manual Edit ViewController(wake)
    * 2つくらいの変数をジェスチャーで変更する

* 全体の流れ
    * 起動画面はFeed
    * いつでもRecordに飛べるようにする
    * ManualEditでは横向きでEdit，縦向きで保存（Post）モードに
        * 確認のためここで聞ける

### 価値検証フェーズ
* 2017/08/05 9:00 ReadMeを追加，ボタンによる基本の5画面の遷移を実装
* 2017/08/05 21:00 アイコンとスプラッシュ画面を追加．リストビューのベースを追加．


## リリースノート
