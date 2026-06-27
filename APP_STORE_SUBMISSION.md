# JawOff App Store公開メモ

## 公開前に必要なもの

- Apple Developer Programへの登録
- App Store Connectで新規アプリ作成
- XcodeのSigning & CapabilitiesでTeamを選択
- App Store用スクリーンショット
- Appプライバシー情報の入力
- 年齢制限、カテゴリ、価格、配信地域の設定

## アプリ情報案

アプリ名:
JawOff

サブタイトル案:
日中の食いしばりに気づくセルフケア

カテゴリ案:
ヘルスケア／フィットネス

説明文案:
JawOffは、日中の食いしばりや上下の歯の接触に気づくためのセルフケア支援アプリです。

通知が来たタイミングや気づいたタイミングで、今の歯の状態をワンタップで記録できます。朝起きた時の噛み締め感や日々の記録も残せるため、自分の状態を振り返りやすくなります。

主な機能:
- 歯が触れていたか、離れていたかをワンタップで記録
- 任意の時間帯と頻度でリマインダー通知
- 朝起きた時の噛み締め感を記録
- 日別の記録をグラフで確認
- 食いしばり改善のための学習カード
- 月1写真記録ガイド

このアプリはセルフケア支援を目的としたもので、診断・治療を行うものではありません。痛み、顎関節症状、歯の違和感が強い場合は歯科医師に相談してください。

## キーワード案

食いしばり,TCH,歯列接触癖,顎,セルフケア,リマインダー,噛み締め,ヘルスケア

## プライバシー情報案

このアプリはログイン不要で、入力した記録は端末内に保存します。

収集するデータ:
- App Store Connect上では、外部送信・追跡・第三者共有なしとして入力する想定

利用する権限:
- 通知: 食いしばりチェックのリマインダーを表示するため

## 審査メモ案

JawOff is a self-care support app for noticing daytime tooth contact and clenching habits. It does not provide diagnosis or medical treatment. All user records are stored locally on the device. Notifications are used only for reminder prompts selected by the user.

## スクリーンショット候補

- ホーム画面
- チェック画面
- 朝ログ画面
- 記録画面
- 設定画面
- 学習画面

## Xcodeでの公開手順

1. `ios/JawOff/JawOff.xcodeproj` をXcodeで開く
2. `JawOff` ターゲットを選択
3. Signing & Capabilitiesで自分のTeamを選択
4. Bundle Identifierが `com.takecreator.jawoff` で問題ないか確認
5. 実機またはSimulatorで最終確認
6. メニューから `Product > Archive`
7. Archives画面で `Distribute App`
8. `App Store Connect` を選びアップロード
9. App Store Connectでビルドを選択して審査提出
