# JawOff iOS

SwiftUI版のiPhone MVPです。

## 目的

- 1時間に1回「歯、触れていませんか？」と通知する
- 通知をきっかけにアプリを開く
- 今の噛み締め状態をチェックして保存する
- 朝ログと直近の推移を端末内で見返す

## 起動方法

1. `ios/JawOff/JawOff.xcodeproj` をXcodeで開く
2. `JawOff` schemeを選ぶ
3. 実機またはiPhone Simulatorを選ぶ
4. Runする

実機で通知を試す場合は、XcodeのSigning & Capabilitiesで自分のTeamを選んでください。

## 通知仕様

- 初回は設定画面から通知許可を依頼
- 許可後、1時間ごとのローカル通知を登録
- 通知文言: `歯、触れていませんか？`
- 通知本文: `アプリを開いて、今の噛み締め状態を確認しましょう。`

## 保存

データは端末内の `UserDefaults` に保存します。

- `checkLogs`
- `morningLogs`
- `settings`
- `reminderLogs`

## 注意

このアプリはセルフケア支援を目的としたもので、診断・治療を行うものではありません。痛み、顎関節症状、歯の違和感が強い場合は歯科医師に相談してください。
