# Time4 1.0.0 Release Checklist

## リポジトリで完了

- [x] iPhone・Apple Watch App Icon
- [x] `MARKETING_VERSION = 1.0.0`
- [x] Privacy Manifest（UserDefaults: `CA92.1`）
- [x] 暗号化輸出コンプライアンス設定
- [x] プライバシーポリシー、サポートページ
- [x] App Storeメタデータ文案
- [x] StoreKit 2購入・復元UI
- [x] 初回タイマー開始時の通知許可要求
- [x] GitHub Actionsのテストとシミュレータビルド

## Apple Developer / App Store Connect

- [x] 正式Bundle IDを確定する
- [x] iPhone・Watch両ターゲットのTeam IDを`project.yml`へ設定する
- [x] App Store ConnectでTime4のアプリレコードを作成する
- [ ] SKUと著作権表記を確定する
- [ ] Agreements, Tax, and Bankingを完了する
- [ ] 非消耗型App内課金`time4.pro.lifetime`を500円で作成する
- [ ] App内課金の日本語表示名、説明、審査用スクリーンショットを登録する
- [ ] App Privacyで「データを収集しない」を公開する
- [ ] GitHub Pagesを`main`ブランチの`/docs`から公開する
- [ ] 公開後、プライバシー・サポートURLをApp Store Connectへ登録する

## 実機検証

- [ ] Release構成でiPhone実機ビルドする
- [ ] Apple Watch実機へインストールする
- [ ] 初回通知許可、許可拒否、設定変更を確認する
- [ ] iPhoneで8タイマーを開始・一時停止・再開・終了する
- [ ] Watchで先頭4タイマーを操作する
- [ ] 画面消灯、バックグラウンド、アプリ再起動後の残り時間を確認する
- [ ] 消音オン・オフで音と触覚の挙動を確認する
- [ ] iPhoneとWatchが通信できない状態で最後の同期データを使用できるか確認する
- [ ] プリセット編集後のWatch同期を確認する
- [ ] StoreKitローカル購入・復元を確認する
- [ ] SandboxまたはTestFlightで実商品購入・復元を確認する
- [ ] 購入済み状態でプリセット無制限、並び替え、アイコン変更を確認する

## 提出素材

- [ ] iPhone 6.9インチ用スクリーンショットを3〜5枚作成する
- [ ] Apple Watch用スクリーンショットを作成する
- [ ] スクリーンショットに透明部分がないことを確認する
- [ ] 説明文、サブタイトル、キーワードを登録する
- [ ] App Review連絡先を登録する
- [ ] App Reviewメモを登録する
- [ ] ビルドをTestFlightへアップロードする
- [ ] TestFlight内部テストを完了する
- [ ] 1.0.0と初回App内課金を同じ審査提出へ追加する

## リリース判定

- [ ] クラッシュやデータ消失がない
- [ ] タイマー終了通知が実機で安定している
- [ ] Watch同期失敗時もiPhone単体で使用できる
- [ ] 課金前後と購入復元でデータが失われない
- [ ] プライバシーポリシーと実際の挙動が一致している
