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

App Store Connect / Developer:

- SKUと著作権表記の確定。
- Agreements, Tax, and Bankingの完了。
- 非消耗型App内課金 `time4.pro.lifetime` を500円で作成。
- App内課金の日本語表示名、説明、審査用スクリーンショット登録。
- App Privacyで「データを収集しない」を公開。
- GitHub Pagesを `main` ブランチの `/docs` から公開。
- 公開後、プライバシー・サポートURLをApp Store Connectへ登録。

実機検証:

- Release構成でiPhone実機ビルド。
- Apple Watch実機インストール。
- 初回通知許可、拒否、設定変更確認。
- iPhoneで8タイマーの開始・一時停止・再開・終了確認。
- Watchで先頭4タイマーの操作確認。
- 画面消灯、バックグラウンド、アプリ再起動後の残り時間確認。
- 消音オン・オフで音と触覚の挙動確認。
- iPhoneとWatchが通信できない状態で最後の同期データを使えるか確認。
- プリセット編集後のWatch同期確認。
- StoreKitローカル購入・復元確認。
- SandboxまたはTestFlightで実商品購入・復元確認。
- 購入済み状態でプリセット無制限、並び替え、アイコン変更確認。

提出素材:

- iPhone 6.9インチ用スクリーンショット3から5枚。
- Apple Watch用スクリーンショット。
- スクリーンショットに透明部分がないことの確認。
- 説明文、サブタイトル、キーワード登録。
- App Review連絡先、App Reviewメモ登録。
- TestFlight内部テスト完了。
- 1.0.0と初回App内課金を同じ審査提出へ追加。

## 6. 次にやるべき作業と優先順位

1. Remote（SSH / Mac mini）でこのリポジトリを開き、`git status --short --branch` と `git log -1 --oneline` を確認する。
2. この `HANDOVER.md`、`docs/HANDOVER.md`、`docs/RELEASE_CHECKLIST.md`、`docs/MVP_TASKS.md` を読む。
3. まだcommitされていない `docs/HANDOVER.md` と `AGENTS.md` の扱いをユーザーに確認する。勝手にcommitしない。
4. GitHub Pages公開またはApp Store Connect作業のどちらを進めるか、ユーザー指示を待つ。
5. 実装を触る場合は、先に対象仕様と完了条件を確認し、不要なrefactorやUI変更を避ける。
6. App Store前は、実機iPhone/Apple WatchとStoreKit/TestFlightの確認を優先する。

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

- GitHub Pages予定URLは現時点で404。`docs/RELEASE_CHECKLIST.md` 上もGitHub Pages公開は未完了。
- Netlify設定ファイルは見つかっていない。Netlify反映はない。
- GitHub CLIの `gh run list` はこの環境ではラン一覧を返さなかったため、最新GitHub Actions状態は未確認。
- このホストでは `xcodebuild -version` が失敗した。active developer directory が `/Library/Developer/CommandLineTools` で、Xcode本体ではないため。
- このホストでは `swift test --package-path Time4Shared` が `no such module 'XCTest'` で失敗した。Xcode本体がactive developer directoryになっていないことが原因と見られる。
- 前スレッド上では、Xcode CloudのBuild 8が警告・エラーなしで成功し、内部テスター自動配信設定まで完了したと記録されている。ただし現在のローカル環境からApp Store Connectの実状態は確認していない。
- 実機でのWatch通知、触覚、腕下げ、文字盤復帰、WatchConnectivityは未検証。
- StoreKit実商品購入・復元は未検証。
- `docs/MVP_TASKS.md` の「Set real bundle identifiers and Apple Developer Team ID」は古い未完了項目として残っているが、`project.yml` と `docs/RELEASE_CHECKLIST.md` ではBundle IDとTeam IDは設定済み。
- `docs/HANDOVER.md` と未追跡 `AGENTS.md` は作業ルール追加を含むが、まだcommitされていない。

## 10. Gitの現在状態

確認時点:

- branch: `main`
- upstream: `origin/main`
- status: `main...origin/main`
- 最新commit: `316fa32a1d093c17712108d340e0624c21199203`
- 最新commit概要: `316fa32 Bump TestFlight build to 3`
- remote: `https://github.com/vm95yw5t7j-blip/time4.git`

未コミット変更:

- modified: `docs/HANDOVER.md`
- untracked: `AGENTS.md`
- untracked: `HANDOVER.md`（この引き継ぎ文書）

既存の未追跡ファイル、確認用画像、一時ファイルは、明示指示なしにcommit対象へ含めない。

今回の引き継ぎ作成後の検証結果:

- `plutil -lint Time4iOS/PrivacyInfo.xcprivacy Time4Watch/PrivacyInfo.xcprivacy`: OK
- `swift test --package-path Time4Shared`: 失敗。`XCTest` が見つからない。
- `xcodebuild -version`: 失敗。active developer directory がCommand Line Tools。
- iPhone Simulator Release build: 未実行。`xcodebuild` が使えないため。

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
- `CURRENT_PROJECT_VERSION`: `3`
- 前スレッド上のXcode Cloud配布ビルド: Build `8` 成功記録あり

予定URL:

- Marketing: `https://vm95yw5t7j-blip.github.io/time4/`
- Support: `https://vm95yw5t7j-blip.github.io/time4/support.html`
- Privacy: `https://vm95yw5t7j-blip.github.io/time4/privacy-policy.html`

現時点のURL状態:

- 上記3URLはいずれもHTTP 404を返した。GitHub Pages公開は未完了と扱う。

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
