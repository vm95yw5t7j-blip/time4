# Time4 Remote Handover

作成日: 2026-09-04 JST

この文書は、次のRemote（SSH / Mac mini）側Codexタスクが、このチャットを読まなくてもTime4開発を継続できるようにするための引き継ぎです。

## 1. このタスクの目的

Time4開発の前スレッド内容、ローカルリポジトリ状態、未コミット変更、運用ルールを確認し、次のCodexタスクへ引き継げる状態にすること。

今回の作業範囲は引き継ぎ文書の作成のみ。新機能実装、commit、push、本番deploy、本番環境変更は行わない。

## 2. 現在までに完了した作業

- 前スレッド `Time4 開発` を特定。
- 前スレッドの直近履歴を確認。
- Time4のローカルリポジトリ `/Users/naoki/projects/Time4` を確認。
- `README.md`、`docs/HANDOVER.md`、`docs/MVP_TASKS.md`、`docs/RELEASE_CHECKLIST.md`、`docs/APP_STORE_METADATA.md`、`docs/XCODE_CLOUD_SETUP.md`、`project.yml`、主要ソース構成を確認。
- Git状態、最新commit、未コミット変更、未追跡ファイルを確認。
- GitHub Pages予定URLの到達確認を行い、現時点では404であることを確認。
- Netlify設定ファイルが存在しないことを確認。

## 3. 現在の実装・仕様

Time4は、iPhoneとApple Watch向けのプリセットタイマーアプリ。Apple Watch-firstだが、iPhone単体でも主要体験を使える必要がある。

基本コンセプト:

- アプリ名: `Time4`
- キャッチコピー: `いつもの時間を、ワンタップで。`
- 位置づけ: `iPhoneでも使える、Apple Watchファーストのプリセットタイマー。`
- Pro: 買い切り `500円`
- StoreKit商品ID: `time4.pro.lifetime`

MVP仕様:

- シーケンスタイマーではない。
- 各タイマーは独立している。
- iPhoneは1プリセット最大8タイマー。
- Apple Watchは各プリセットの先頭4タイマーを2x2で表示。
- iPhone/Watchともに、タイマー開始後は画面遷移せず、選択したタイル内のリングが進行する。
- 実行中リングをタップすると一時停止。
- 一時停止中リングをタップすると再開。
- 一時停止中のみ赤い終了ボタンを表示し、押すと元の時間表示へ戻る。
- 表示中の複数タイマーは同時実行できる。
- 完了フィードバック後、タイマーは元の時間表示に戻る。
- タイマー進行は画面tickではなく `endsAt` を基準に計算する。
- 実行中タイマーは開始端末が所有する。MVPではiPhoneとWatch間の実行中タイマー完全同期はしない。

実装済み:

- Shared Swift package: `Time4Shared`
- iOS SwiftUI app: `Time4iOS`
- watchOS SwiftUI app: `Time4Watch`
- XcodeGen設定: `project.yml`
- Xcode Cloud用共有プロジェクト: `Time4.xcodeproj`
- ローカルStoreKit設定: `StoreKit/Time4.storekit`
- 共有データモデル
- Freeプランの1プリセット制限
- `endsAt` ベースのタイマーエンジン
- iPhoneプリセット一覧・編集
- iPhone 2列タイマー選択
- iPhone in-gridリング、一時停止、再開、終了
- iPhone最大8同時タイマー
- iPhoneローカル通知
- iPhone実行中タイマー復元
- Watchプリセット一覧
- Watch 2x2タイマー選択
- Watch in-gridリング、一時停止、再開、終了
- Watch最大4同時タイマー
- WatchConnectivity snapshot codec/controller
- StoreKit 2購入・復元UIの土台
- Privacy Manifest
- App Storeメタデータ文案
- プライバシーポリシー・サポートページ素材
- GitHub ActionsのmacOS CI

## 4. 変更したファイル一覧と各変更内容

今回の引き継ぎ作成で追加したファイル:

- `HANDOVER.md`
  - 次のRemote Codexタスク向けの引き継ぎ文書を追加。
  - 実装・仕様、未完了作業、Git状態、コマンド、外部サービス情報、注意点を整理。

今回の作業前から存在していた未コミット変更:

- `docs/HANDOVER.md`
  - 既存引き継ぎメモに以下2点が追加済みだった。
  - コピー操作を導入する場合は、1タップでコピーし、成功後に見える完了フィードバックを表示する。
  - 明示指示なしにNetlify deploy、公開、Netlify設定変更をしない。

今回の作業前から存在していた未追跡ファイル:

- `AGENTS.md`
  - リポジトリ作業ルールのメモ。
  - 内容は、コピー操作の1タップ完了フィードバックと、明示指示なしのNetlify deploy/config変更禁止。
  - 未追跡のため、明示指示なしにcommit対象へ含めない。

## 5. 未完了の作業

2026-09-17時点で、ビルド15を1.0.0 + `time4.pro.lifetime`として審査再提出済み、ステータスは「審査待ち」。詳細な進捗は `docs/RELEASE_CHECKLIST.md` を正とする。

残作業:

- Apple審査結果を待つ。

実施できていない項目:

- StoreKitローカル購入・復元確認。このホストにXcode本体が無く、シミュレータでStoreKit設定ファイルを使ったテストができないため。TestFlight経由のSandbox購入で実質的な確認は済んでいる。

## 5.2 2026-09-17に対応した審査却下（Guideline 2.1 Information Needed）

初回審査でGuideline 2.1「Information Needed」（開発者アカウントのレビュー履歴が少ないための追加情報要求）を受けた。対応内容:

- 実機で画面収録を作成（アプリ起動 → プリセット操作 → 編集画面 → 未購入状態のTime4 Pro画面 → Sandbox購入完了 → プリセット無制限の実演）。
- 収録時、TestFlightビルドの購入は「設定 > 氏名 > メディアと購入」でサインインしているApple IDに紐づくため、「設定 > デベロッパ > Sandbox Apple Account」だけを切り替えても未購入状態を再現できないことが判明した。正しい手順は、メディアと購入を先にサインアウトし、TestFlightアプリを開かずにTime4本体を直接起動してSandboxアカウントでサインインすること（詳細は `docs/CODEX_TASK_PRO_ENTITLEMENT_INVESTIGATION.md` のCodex調査結果を参照）。
- アプリの購入判定ロジック自体にバグは無いと判断し、コード変更は行っていない。
- App Store Connectの「App Reviewに返信」機能で、アプリの目的・アクセス方法・外部サービス一覧・地域差・IAP概要などの7項目に日本語で回答し、画面収録を添付して送信。
- ビルド15を1.0.0として再提出し、「審査待ち」に戻ったことを確認済み（2026-09-17）。

## 5.1 2026-09-16に完了した作業

App Store Connect:

- SKU、著作権表記（`© 2026 Naoki Ito`）を設定。
- Agreements, Tax, and Bankingがすべて「有効」であることを確認（有料アプリ契約、銀行口座、W-8BEN）。
- 非消耗型App内課金 `time4.pro.lifetime` を500円で作成し、日本語ローカリゼーションと審査用スクリーンショットを登録。
- App Privacyで「データを収集しない」を公開。プライバシーポリシーURLを登録。
- カテゴリ（ユーティリティ／仕事効率化）、コンテンツ配信権、年齢制限指定（4+）、価格（無料）、配信地域を設定。
- 説明文、サブタイトル、プロモーション用テキスト、キーワード、サポート／マーケティングURLを登録。
- App Review連絡先と審査メモを登録。自動リリースを選択。
- 提出物の下書きにIAPとバージョン1.0.0を追加済み（未提出）。

スクリーンショット:

- iPhone 6.9インチ（1320x2868）3枚と、Apple Watch Ultra 2（410x502）3枚を作成して登録。見出し付きのマーケティング版を `/tmp` の生成スクリプトで作成した。
- IAP審査用スクリーンショットは6.9インチ規格が通らず、6.5インチ規格（1284x2778）でのみ受け付けられた。

実機検証（iPhone 17 Pro Max / Apple Watch Ultra 2）:

- 初回通知許可、拒否、設定変更。
- 画面消灯、バックグラウンド、アプリ再起動後の残り時間復元。
- 消音オン・オフでの音と触覚。
- iPhone・Watch非通信時に最後の同期データで動作すること。
- プリセット編集後のWatch同期。
- TestFlight経由のSandbox購入（実請求なし）と、再インストール後の自動entitlement復元。

不具合修正:

- 購入ボタン連打で購入シートが積み上がる不具合を修正（コミット3bc91d3）。

## 6. 次にやるべき作業と優先順位

1. Xcode Cloudのビルド15が完了し、TestFlightに配信されているか確認する。
2. iPhoneのTestFlightでビルド15に更新し、Pro購入画面で購入ボタンを連打して、購入シートが1つしか出ないことを確認する。
3. 購入済み状態でプリセットの並び替えとアイコン変更が動くことを確認する。
4. App Store Connectのバージョン1.0.0で、ビルドを14から15へ差し替える。
5. 提出物の下書き（バージョン1.0.0 + IAP `time4.pro.lifetime`）を「審査へ提出」する。
6. 実装を触る場合は、先に対象仕様と完了条件を確認し、不要なrefactorやUI変更を避ける。

## 7. 重要な設計判断と、その理由

- シーケンスタイマーはMVPに入れない。
  - Time4の価値は「いつもの時間をワンタップで開始」する速さであり、連続実行は操作と理解を複雑にするため。
- iPhoneは最大8タイマー、Watchは先頭4タイマー。
  - iPhoneは編集・一覧性を持たせ、Watchは小画面で押しやすい2x2操作に集中するため。
- 実行中タイマーは開始端末が所有する。
  - MVPでリアルタイム双方向同期を入れると状態管理が複雑化し、リリースリスクが上がるため。
- タイマー残り時間は `endsAt` 基準で計算する。
  - バックグラウンド、画面消灯、アプリ復帰後も時間ずれを抑えるため。
- 起動後のタイマーは別画面に遷移せず、タイル内リングで進行する。
  - ワンタップ開始と視認性を優先するため。
- `project.yml` をXcode設定の正本にする。
  - XcodeGen再生成時の設定消失を避けるため。
- `Time4.xcodeproj` もGit管理する。
  - Xcode Cloudがリポジトリ内のプロジェクトを参照できるようにするため。

## 8. 変更してはいけない既存仕様・維持すべき挙動

- シーケンスタイマーへ変更しない。
- 通常の数字入力タイマーをMVPへ追加しない。
- iPhone最大8タイマー、Watch先頭4タイマーの仕様を勝手に変えない。
- Watchを詳細編集画面にしない。MVPではWatchは高速開始が主役。
- タイマー開始時に別画面へ遷移させない。
- タイマーボタンにはMVPではラベルを出さず、時間表示を中心にする。
- 実行中タイマーのdurationを編集できるようにしない。
- プリセット編集で実行中タイマーのスナップショットを変えない。
- FreeからProへのアップグレードで既存データを失わない。
- Restore purchaseをApp Store提出前に維持・確認する。
- コピー操作を入れる場合は、1タップでコピーし、成功後に見える完了フィードバックを出す。
- 明示指示なしにNetlify deploy、公開、Netlify設定変更をしない。
- 明示指示なしにGitHub pushしない。
- 明示指示なしに本番環境を変更しない。

## 9. 現在判明している不具合・注意点・技術的負債

- **このホストにXcode本体がインストールされていない。** `/Applications` にXcode.appが無く、active developer directoryは `/Library/Developer/CommandLineTools`。そのため `xcodebuild`、シミュレータ実行、`swift test --package-path Time4Shared`（`no such module 'XCTest'`）がすべて失敗する。ビルド検証はGitHub ActionsとXcode Cloudに依存している。
- **IAP審査用スクリーンショットは6.5インチ規格（1284x2778）しか受け付けない。** App Store掲載用に使う6.9インチ規格（1320x2868）をアップロードすると「寸法が正しくありません」で弾かれる。
- `project.yml` の `CURRENT_PROJECT_VERSION` は `3` のままだが、実際のTestFlightビルド番号はXcode Cloudが自動採番している（2026-09-15時点で14）。手動で合わせる必要はないが、値が実態と乖離している点に注意。
- Xcode Cloudのワークフローはmainへのpushで自動起動しなかった。ビルドはApp Store Connectから手動で開始する必要がある。
- `ci_scripts/` は存在するが空。
- `docs/MVP_TASKS.md` の「Set real bundle identifiers and Apple Developer Team ID」は古い未完了項目として残っているが、`project.yml` と `docs/RELEASE_CHECKLIST.md` ではBundle IDとTeam IDは設定済み。
- Netlify設定ファイルは見つかっていない。Netlify反映はない。

解消済み:

- GitHub Pagesの3URLは2026-09-15時点でいずれもHTTP 200。公開済み。
- 購入ボタン連打で購入シートが積み上がる不具合はコミット3bc91d3で修正済み（ビルド15で要検証）。
- StoreKit実商品購入・復元は、TestFlight経由のSandbox購入で検証済み。

## 10. Gitの現在状態

確認時点: 2026-09-16

- branch: `main`
- upstream: `origin/main`
- 最新commit: `3bc91d3 Prevent duplicate purchase sheets from repeated taps`
- remote: `https://github.com/vm95yw5t7j-blip/time4.git`

既存の未追跡ファイル、確認用画像、一時ファイルは、明示指示なしにcommit対象へ含めない。

検証結果:

- GitHub Actions `Apple platform build`（run 34986264538）: 成功。共有ロジックのテスト、Privacy Manifest検証、Release構成のiPhoneシミュレータビルドがすべてパス。
- `swift test --package-path Time4Shared`: このホストでは失敗。`XCTest` が見つからない（Xcode本体が無いため）。
- `xcodebuild -version`: 失敗。active developer directory がCommand Line Tools。
- ローカルでのiPhone Simulator Release build: 未実行。`xcodebuild` が使えないため、GitHub Actions側で代替検証している。

## 11. 開発・起動・確認に必要なコマンド

リポジトリ確認:

```bash
cd /Users/naoki/projects/Time4
git status --short --branch
git log -1 --oneline
git remote -v
```

Mac初回セットアップ:

```bash
./scripts/bootstrap-mac.sh
```

Xcode本体をCommand Line Toolsに設定:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

XcodeGen再生成:

```bash
xcodegen generate
git diff --exit-code -- Time4.xcodeproj
```

共有ロジックテスト:

```bash
swift test --package-path Time4Shared
```

Privacy Manifest確認:

```bash
plutil -lint Time4iOS/PrivacyInfo.xcprivacy Time4Watch/PrivacyInfo.xcprivacy
```

iPhone Simulator Releaseビルド:

```bash
xcodebuild \
  -project Time4.xcodeproj \
  -scheme Time4 \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Xcodeで開く:

```bash
open Time4.xcodeproj
```

GitHub Pages到達確認:

```bash
curl -I -L --max-time 15 https://vm95yw5t7j-blip.github.io/time4/
curl -I -L --max-time 15 https://vm95yw5t7j-blip.github.io/time4/support.html
curl -I -L --max-time 15 https://vm95yw5t7j-blip.github.io/time4/privacy-policy.html
```

## 12. 環境変数や外部サービスなど、次タスクが知っておくべき環境情報

必須外部サービス:

- GitHub repository: `vm95yw5t7j-blip/time4`
- App Store Connect app: `Time4`
- Apple Developer Team ID: `98YMT83776`
- Xcode Cloud workflow: 前スレッド上では `Time4 Main Build`
- TestFlight internal group: 前スレッド上では `Time4 Internal`

Bundle ID:

- iPhone: `com.naoki.Time4`
- Apple Watch: `com.naoki.Time4.watchkitapp`

Version/build:

- `MARKETING_VERSION`: `1.0.0`
- `CURRENT_PROJECT_VERSION`: `3`（project.yml上の値。実際のビルド番号はXcode Cloudが自動採番）
- TestFlight配信済みビルド: `1.0.0 (14)`
- ビルド15: 購入シート重複修正を含む。2026-09-16未明にXcode Cloudで手動起動済み。

App Store Connect上のIAP:

- 参照名 `Time4 Pro` / 製品ID `time4.pro.lifetime` / Apple ID `6800293118`
- 非消耗型、500円、ファミリー共有オフ

公開URL:

- Marketing: `https://vm95yw5t7j-blip.github.io/time4/`
- Support: `https://vm95yw5t7j-blip.github.io/time4/support.html`
- Privacy: `https://vm95yw5t7j-blip.github.io/time4/privacy-policy.html`

現時点のURL状態:

- 上記3URLはいずれもHTTP 200。App Store Connectへ登録済み。

本番操作ルール:

- 明示許可なしにNetlify deployしない。
- 明示許可なしにGitHub pushしない。
- 明示許可なしにFirebase本番変更しない。
- 本番Firestore readは最小限にする。
- このリポジトリにはFirestore利用は確認されていない。

環境変数:

- 現時点でTime4固有の必須環境変数は確認されていない。

## 13. 完了条件

この引き継ぎタスクの完了条件:

- 次のRemote Codexタスクが、このチャットを読まずにTime4の目的、仕様、現在状態、未完了作業、禁止事項、確認コマンドを把握できる。
- `HANDOVER.md` がリポジトリ直下に存在する。
- commit、push、deploy、本番環境変更をしていない。
- 既存の未追跡ファイルや一時ファイルを勝手にcommit対象へ含めていない。

Time4 1.0.0リリースとしての完了条件:

- 実機iPhone/Apple WatchでMVP操作と通知・触覚・復元を確認済み。
- StoreKit購入・復元をローカルおよびSandbox/TestFlightで確認済み。
- App Store ConnectのIAP、App Privacy、メタデータ、スクリーンショットが登録済み。
- GitHub Pagesまたは正式公開URLが有効で、App Store Connectへ登録済み。
- TestFlight内部テストが完了。
- 1.0.0本体と初回IAPを同じ審査提出へ追加済み。

## 14. 次のCodexが最初に確認すべきファイル

1. `HANDOVER.md`
2. `AGENTS.md`（未追跡の場合あり。存在すれば読む）
3. `/Users/naoki/projects/AI_DEVELOPMENT_WORKFLOW.md`
4. `docs/HANDOVER.md`
5. `docs/RELEASE_CHECKLIST.md`
6. `docs/MVP_TASKS.md`
7. `docs/APP_STORE_METADATA.md`
8. `docs/XCODE_CLOUD_SETUP.md`
9. `project.yml`
10. `README.md`
11. `Time4Shared/Sources/Time4Shared/Time4Models.swift`
12. `Time4Shared/Sources/Time4Shared/RunningTimer.swift`
13. `Time4Shared/Sources/Time4Shared/Time4Policy.swift`
14. `Time4iOS/TimerGridPhoneView.swift`
15. `Time4Watch/TimerGridWatchView.swift`
16. `.github/workflows/apple-platform-build.yml`
