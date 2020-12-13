# english_cards

Flutterで作ったサンプルアプリです。
それぞれの使い方については、公式のドキュメントを参照してください。

このアプリはそのままは動かせません。このアプリをテストするためには以下の手順を踏んでください。

1. Oxford Dictionaries APIからAppIdとAppKeyを取得(https://developer.oxforddictionaries.com/)
2. `lib/OxfordDictionary.dart`内の`appId`,`appKey`を変更

```dart
/* 省略 */

final _language = "en-us";
final _appId = "<your app id>";  //ここを書き換える
final _appKey = "<your app key>";  //ここを書き換える

/* 省略 */
```
