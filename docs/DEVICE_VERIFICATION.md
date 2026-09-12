# Time4 実機検証手順書（Mac mini作業用）

このドキュメントは、Xcodeがインストールされた実機（Mac mini + iPhone + Apple Watch）で
`docs/RELEASE_CHECKLIST.md` の「実機検証」セクションを実施するための手順書。

前提: このMac（メイン開発機）にはXcode本体がなく、ローカルでのビルド・実機インストールができないため作成した。

## 0. 事前確認

```bash
cd /path/to/time4
git status --short --branch
git switch main
git pull --ff-only
git rev-parse HEAD
xcodebuild -project Time4.xcodeproj -list
```

未コミットの変更がある場合は、勝手に退避・破棄せず作業を止めて確認する。`git rev-parse HEAD`で表示されたコミットハッシュを「実施ログ」に記録し、検証対象コミットを明確にする。

以下が表示されることを確認する。

- Targets: `Time4`, `Time4Watch Watch App` など
- Schemes: `Time4`（iPhone/Watch両方を含む）, `Time4Watch`（Watch単体）

## 1. Release構成でのビルド確認

```bash
xcodebuild -project Time4.xcodeproj -scheme Time4 -configuration Release \
  -destination 'generic/platform=iOS' build
```

エラーなく完了することを確認する。失敗した場合はエラーログを保存してから報告する（コード修正はここでは行わない）。

## 2. 実機へのインストール（Release構成）

Xcodeを開き、`Time4.xcodeproj` を開く。

1. iPhoneをMac miniにUSB接続し、Xcode上部のデバイス選択でiPhone実機を選ぶ
2. `Time4` スキームを選択（Product > Scheme > Edit Scheme）し、Run（実行）アクションの Build Configuration を一時的に `Debug` から `Release` へ変更する
3. デバイス選択がiPhone実機になっていることを確認し、Run（Cmd+R）
   - これにより実機上でRelease構成のバイナリが起動する。手順1（`xcodebuild ... -configuration Release build`）はコンパイル・署名の確認、この手順2がRelease実機Runの確認であり、両方揃って初めて「Release構成でiPhone実機ビルドする」項目を満たす
4. 初回は「デベロッパモード」の有効化がiPhone側で必要になる場合がある（設定 > プライバシーとセキュリティ）
5. Apple Watchが同じMacに接続されたiPhoneとペアリング済みであれば、`Time4` スキームのRun時に `Time4Watch Watch App` も自動でインストールされる。Watch単体で個別に確認したい場合は `Time4Watch` スキームを選んでRun
6. 検証が終わったら、Edit SchemeのRun Build Configurationを `Debug` に戻す（次回の開発作業に影響しないようにするため）

## 3. チェックリスト実施（`docs/RELEASE_CHECKLIST.md` 該当項目）

各項目を実施し、結果を本ファイル末尾の「実施ログ」に記録する。

- [ ] Release構成でiPhone実機ビルドする（手順1・2で実施）
- [ ] Apple Watch実機へインストールする
- [ ] 初回通知許可、許可拒否、設定変更を確認する
  - アプリ初回起動→タイマー初回開始時に通知許可ダイアログが出るか
  - 拒否した場合の挙動（クラッシュしない、機能は使えるが通知が来ない）
  - 設定アプリから許可へ変更した場合に反映されるか
- [ ] iPhoneで8タイマーを開始・一時停止・再開・終了する
  - 8つ同時に走らせても表示・進行が崩れないか
- [ ] Watchで先頭4タイマーを操作する
- [ ] 画面消灯、バックグラウンド、アプリ再起動後の残り時間を確認する
  - 画面ロック→解除後に残り時間が正しいか（`endsAt`基準なのでズレないはず）
  - アプリをバックグラウンドに回してから復帰
  - アプリを完全終了して再起動後、実行中タイマーが復元されるか
- [ ] 消音オン・オフで音と触覚の挙動を確認する
- [ ] iPhoneとWatchが通信できない状態で最後の同期データを使用できるか確認する
  - Watch側を機内モードにするか、iPhoneから離してBluetooth/Wi-Fi通信を切る
  - 最後に同期されたプリセットで起動・操作できるか
- [ ] プリセット編集後のWatch同期を確認する
  - iPhoneでプリセット編集→Watch側に反映されるまでの時間と正しさ
- [ ] StoreKitローカル購入・復元を確認する
  - `StoreKit/Time4.storekit` を使ったローカルテスト（`Time4` スキームには既にStoreKit Configurationが設定済みであることを確認してから実行）
  - 購入後、Xcodeの StoreKit Transaction Manager等でアプリの購入状態をリセットしてから「復元」を実行し、Pro状態が正しく戻ることを確認する
- [ ] SandboxまたはTestFlightで実商品購入・復元を確認する
  - App Store Connectで`time4.pro.lifetime`作成後、Sandboxアカウントで購入テスト
- [ ] 購入済み状態でプリセット無制限、並び替え、アイコン変更を確認する

## 4. 実施ログ

実施日 / 実施者 / 結果 / 気づいた不具合を追記する。

| 日付 | 検証コミット(`git rev-parse HEAD`) | 項目 | 結果 | メモ |
|------|------|------|------|------|
|      |      |      |      |      |
