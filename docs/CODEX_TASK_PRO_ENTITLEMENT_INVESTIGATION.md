# Codex調査依頼: Pro購入状態がリセットできない問題

## 1. 今回の目的

App Store審査（Guideline 2.1 - Information Needed）への回答として、Time4 Proの購入フロー（未購入 → ペイウォール表示 → 購入完了）を実機で画面収録する必要がある。

しかし、以下の手順をすべて試しても、TestFlightビルド15（`com.naoki.Time4`）で「未購入状態」を再現できない。

- iPhone設定 > デベロッパ > Sandboxアカウント > 管理 > 購入履歴を消去
- 上記消去後、Time4を完全アンインストール → TestFlightから再インストール
- iPhone設定 > デベロッパ > Sandboxアカウントで、一度も購入していないはずの新規Sandboxテスターアカウントへサインインを切り替え → アンインストール → 再インストール

いずれの場合も、起動直後に一瞬ペイウォール（Time4 Pro画面）が表示されるが、その後すぐ`isProUnlocked`が`true`に戻り、プリセット追加などProの機能がそのまま使える状態になってしまう。

**目的は「なぜ未購入状態を再現できないのか」の原因調査と、可能であれば実機で未購入状態を再現するための具体的な手順（またはコード修正）を明らかにすること。** 審査提出物のコード自体（`3bc91d3` 購入シート重複修正）に対する追加の機能変更は、原因がアプリ側のバグだと判明した場合のみ行う。

## 2. 決定済み仕様（変更しないこと）

- `Time4iOS/PurchaseManager.swift` の購入・復元ロジック自体（`3bc91d3`でのpurchasePro連打防止修正含む）は正しい実装であり、審査に提出済み。ロジックの仕様変更はしない。
- Proの実際の権利判定は `Transaction.currentEntitlements`（StoreKit 2）を正としており、ローカルの `SnapshotStore` の`isProUnlocked`はキャッシュ的な位置づけ。この設計思想（サーバー/StoreKitが正、ローカルはキャッシュ）は変更しない。

## 3. 変更対象（調査の中心）

- `Time4iOS/PurchaseManager.swift`（`start()`, `refreshEntitlements()`）
- `Time4Shared/Sources/Time4Shared/SnapshotStore.swift`（`UserDefaults.standard`への永続化）
- `Time4iOS/PresetListModel.swift`（`init()`での`isProUnlocked`読み込み、`setProUnlocked`の呼び出し箇所）
- 上記はいずれも「読むだけ」で構わない。コード修正が必要かどうかは調査結果次第。

## 4. 壊してはいけない既存仕様

- 実際に購入したユーザーのPro状態が、アプリ再起動やネットワーク不通時に誤って解除されてはならない（[docs/HANDOVER.md](../HANDOVER.md) Engineering Rules: 「Free to Pro upgrade must keep existing data」）。
- 「購入を復元」ボタンの動作（`AppStore.sync()` → `refreshEntitlements()`）を壊さない。
- 審査提出済みのビルド15の動作を変えない。コード修正が必要になった場合は、新しいビルド番号での再提出が前提になる点をユーザーに明示すること（このタスク内でXcode CloudのビルドやApp Store Connectの提出操作は行わない）。

## 5. 調査してほしいこと

1. **TestFlightビルドにおける「Settings > デベロッパ > Sandboxアカウント」の実効性を確認する。**
   Apple公式ドキュメント（`Manage Sandbox Apple Account settings`、`Testing In-App Purchases with sandbox`）を確認し、この設定がXcodeからのデバッグ実行専用で、TestFlight配布ビルドには効かない（TestFlightは常に「Media & Purchases」に signed-in の実Apple IDをSandbox環境にルーティングする）可能性を検証する。もしそうであれば、これはアプリのバグではなく、正しい未購入状態の再現には「設定 > [氏名] > メディアと購入」側のApple IDそのものを、まだ購入していない別のApple ID（または新規Sandboxテスター）へサインインし直す必要がある、という結論になる。
2. **アンインストール後も購入状態が復帰する理由を特定する。**
   - `SnapshotStore`は`UserDefaults.standard`を使っており、通常はアンインストールで消去されるはずである。アンインストール直後の一瞬だけペイウォールが出るという証言（`isProUnlocked`の初期値が`false`から始まっている）は、ローカルストレージ自体は消えていることを示唆している。
   - その後すぐ購入済み状態に戻るのは、`PurchaseManager.start()` → `refreshEntitlements()` が `Transaction.currentEntitlements` から実際に有効なエンタイトルメントを取得できているためだと考えられる。これは「メディアと購入」の実アカウントに紐づくSandboxの購入履歴がサーバー側にまだ残っている（消去手順が効いていない、または反映に時間がかかる）ためである可能性が高い。
   - 上記の仮説が正しいか、コードとApple公式ドキュメントの両面から裏付けを取る。
3. **実機で未購入状態を再現する具体的な手順を提示する。**
   考えられる候補（優先順位不明、調査して確定させること）:
   - 設定 > [氏名（一番上）] > メディアと購入 で、現在サインイン中のApple IDから一度サインアウトし、購入履歴のない別のApple ID（新規Sandboxテスター等）でサインインする。
   - App Store Connectの「Sandboxテスター」一覧で、該当テスターの「購入履歴を消去」を実行してから、十分な時間（数時間〜半日）を空けて再テストする。
   - それでも再現できない場合、一時的なデバッグ専用の回避策（例: デバッグビルドのみで有効な「Pro状態を強制リセットする」隠しメニューを追加する等）が必要かどうかを判断し、必要なら実装案を提示する。ただし審査提出済みのビルド15には手を入れない。

## 6. 確認すべき既存コード

- `Time4iOS/PurchaseManager.swift`
- `Time4iOS/PresetListModel.swift`
- `Time4Shared/Sources/Time4Shared/SnapshotStore.swift`
- `Time4iOS/ProPaywallView.swift`（Pro画面の表示条件）
- `Time4iOS/PresetListView.swift`（`showingPaywall`を出す導線がPro購入済み時に消える仕様。[PresetListView.swift:79](../../Time4iOS/PresetListView.swift)）

## 7. 実行すべきtest / typecheck / lint / build

このタスクは調査が主目的でありコード変更を伴わない可能性が高いが、もし調査の結果コード変更（例: デバッグ専用のリセット手段追加）が必要と判断した場合は、変更後に以下を実行すること。

```bash
xcodegen generate
git diff --exit-code -- Time4.xcodeproj
swift test --package-path Time4Shared
plutil -lint Time4iOS/PrivacyInfo.xcprivacy Time4Watch/PrivacyInfo.xcprivacy
xcodebuild \
  -project Time4.xcodeproj \
  -scheme Time4 \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

このホスト（Mac mini）にはXcode本体が入っておらず、`xcodebuild`と`swift test`はこの環境では失敗する（Command Line Toolsのみ）。実行可能な環境で確認するか、GitHub Actionsのワークフロー（`.github/workflows/apple-platform-build.yml`）を通して確認すること。

## 8. 完了時に報告すること

- 「Settings > デベロッパ > Sandboxアカウント」がTestFlightビルドに効くか効かないか、根拠となるApple公式ドキュメントのURLと共に結論を報告する。
- 実機で未購入状態を再現する、確認済みの具体的な手順（再現できた場合）。再現できなかった場合はその理由と、次に試すべき代替案。
- コード変更を行った場合は、変更ファイル一覧、変更理由、テスト結果、ビルド番号の再提出が必要になる旨。
- コード変更を行わなかった場合は「調査のみで、コード修正は不要と判断した」旨を明記する。
- 未コミットの変更がある場合は、勝手にcommit/push/App Store Connectへの操作をしないこと。
