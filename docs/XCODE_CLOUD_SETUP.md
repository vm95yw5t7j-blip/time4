# Time4: Mac初回起動からXcode Cloud設定まで

この手順書は、新しいMacでTime4を初めて開き、iPhone・Apple Watchシミュレーターを確認し、Xcode Cloudの最初のビルドを成功させるまでを対象とする。

Xcode Cloudの初回設定にはMacとXcodeが必要。最初のビルド後は、App Store ConnectのWeb画面からワークフローの確認・編集・手動実行ができる。

## 0. 事前に必要なもの

- macOSを搭載したMac
- 最新の安定版Xcode
- Apple Developer Programへ加入済みのApple Account
- Time4を登録できるApp Store Connect権限
- GitHubリポジトリ `vm95yw5t7j-blip/time4` の管理権限
- GitHubへ接続できるGitまたはGitHub Desktop
- Homebrew

Appleの現在の利用要件では、Xcode CloudはApple Developer Programへの加入、Xcode 15以降、Xcodeへ追加したApple Account、App Store Connectのアプリレコードを必要とする。実際の作業では、App Store提出要件に合わせて最新の安定版Xcodeを使う。

Apple公式資料:

- [Setting up your project to use Xcode Cloud](https://developer.apple.com/documentation/xcode/setting-up-your-project-to-use-xcode-cloud)
- [Configuring your first Xcode Cloud workflow](https://developer.apple.com/documentation/xcode/configuring-your-first-xcode-cloud-workflow)
- [Connecting Xcode Cloud to GitHub](https://developer.apple.com/documentation/xcode/connecting-xcode-cloud-to-github)

## 1. Xcodeを準備する

1. Mac App StoreからXcodeをインストールする。
2. Xcodeを一度起動する。
3. 利用規約へ同意する。
4. iOSとwatchOSの追加コンポーネントが表示されたらインストールする。
5. Xcodeの `Settings > Accounts` を開く。
6. `+`からApple Accountを追加する。
7. Apple Developer Programへ加入しているTeamが表示されることを確認する。

コマンドラインツールの状態はターミナルで確認できる。

```bash
xcode-select -p
```

Xcode本体ではなく別のCommand Line Toolsを参照している場合は、Xcodeの `Settings > Locations > Command Line Tools` でインストール済みのXcodeを選択する。

## 2. GitHubからTime4を取得する

### GitHub Desktopを使う場合

1. GitHub DesktopをインストールしてGitHubへサインインする。
2. `File > Clone Repository` を開く。
3. `vm95yw5t7j-blip/time4` を選択する。
4. Mac上の保存場所を決めてCloneする。

### GitHub CLIを使う場合

GitHub CLIへログインしていなければ、先に認証する。

```bash
gh auth login
```

Time4をCloneする。

```bash
gh repo clone vm95yw5t7j-blip/time4
```

プロジェクトへ移動する。

```bash
cd time4
```

## 3. Homebrewを確認する

Time4はXcodeGenでXcodeプロジェクトを生成する。セットアップスクリプトは、HomebrewがあればXcodeGenを自動インストールする。

```bash
brew --version
```

`command not found`になる場合は、[Homebrew公式サイト](https://brew.sh/)の手順でインストールしてからターミナルを開き直す。

## 4. Xcodeプロジェクトを生成する

Time4のルートで次を実行する。

```bash
./scripts/bootstrap-mac.sh
```

このスクリプトは以下を行う。

1. Mac上で実行されているか確認
2. Xcode Command Line Toolsを確認
3. XcodeGenがなければHomebrewでインストール
4. `project.yml`から`Time4.xcodeproj`を生成
5. Xcodeのスキーム一覧を検証
6. `Time4.xcodeproj`をXcodeで開く

設定の正本は`project.yml`である。Xcode上だけでビルド設定を変えると、次のXcodeGen実行で消えるため注意する。

普段の開発では生成された`Time4.xcodeproj`を作り直せるが、Xcode Cloudはプロジェクトまたはワークスペースがリポジトリ内に常に存在する構成を推奨している。Xcode Cloudを設定する前に、Macで生成・確認した`Time4.xcodeproj`をGitへ登録する。詳しくは「11. Xcode Cloud用にXcodeプロジェクトを登録する」を参照。

## 5. まずiPhoneシミュレーターで起動する

1. Xcode上部のSchemeを`Time4`にする。
2. 実行先にインストール済みのiPhoneシミュレーターを選ぶ。
3. 再生ボタン、または`Command + R`で実行する。
4. Time4のプリセット一覧が表示されることを確認する。
5. サンプルの「筋トレ」を開く。
6. 4つのタイマーボタンが2×2で表示されることを確認する。
7. いずれかを押し、画面遷移せず、そのボタンが残り時間リングに変わることを確認する。
8. リングをタップして一時停止、再タップして再開できることを確認する。
9. 一時停止中だけ表示される赤い終了ボタンで、元の時間表示へ戻ることを確認する。

初回に通知許可が表示されたら、通知確認のため許可する。拒否した場合は、シミュレーターの設定アプリから後で変更できる。

### 起動しない場合

最初に`Product > Clean Build Folder`を実行し、再度`Command + R`を試す。それでも失敗する場合は、XcodeのIssue Navigatorに表示された最初の赤いエラーを確認する。

## 6. Apple Watchシミュレーターを確認する

1. XcodeまたはSimulatorアプリから、iPhoneとApple Watchのペアシミュレーターを用意する。
2. XcodeのSchemeを`Time4Watch`にする。
3. 実行先としてApple Watchシミュレーターを選ぶ。
4. `Command + R`で起動する。
5. プリセット一覧が表示されることを確認する。
6. プリセットを開き、最大4つのボタンが押せることを確認する。
7. 画面遷移せず、押したボタンが残り時間リングに変わることを確認する。
8. リングのタップで一時停止・再開し、一時停止中の終了ボタンで元に戻ることを確認する。

WatchConnectivityの完全な確認には、ペアになったiPhone・Watchシミュレーター、または実機が必要。触覚、腕を下げた状態、文字盤へ戻った後の復元は実機で確認する。

## 7. Bundle IDを確定する

現在の仮Bundle IDは以下。

- iPhone: `com.naoki.Time4`
- Apple Watch: `com.naoki.Time4.watchkitapp`

Bundle IDはApp Storeへ登録すると簡単には変更できない。公開に使う文字列を決めてからApple Developerへ登録する。

変更する場合は、Xcodeの生成済み設定ではなく`project.yml`の次の2項目を編集する。

```yaml
PRODUCT_BUNDLE_IDENTIFIER: com.naoki.Time4
```

```yaml
PRODUCT_BUNDLE_IDENTIFIER: com.naoki.Time4.watchkitapp
```

変更後は再生成する。

```bash
xcodegen generate
```

## 8. Signingを設定する

1. XcodeでTime4プロジェクトを開く。
2. Project Navigatorで青い`Time4`プロジェクトを選ぶ。
3. iPhoneターゲット`Time4`を選ぶ。
4. `Signing & Capabilities`を開く。
5. `Automatically manage signing`を有効にする。
6. Apple Developer ProgramのTeamを選ぶ。
7. Watchターゲットでも同じTeamを選ぶ。

Time4はXcodeGenを使うため、最終的なTeam設定は`project.yml`で管理するのが望ましい。Team IDが分かったら、両ターゲットの`settings`へ次を追加してGitHubへ反映する。

```yaml
DEVELOPMENT_TEAM: YOUR_TEAM_ID
CODE_SIGN_STYLE: Automatic
```

Team IDをリポジトリへ保存したくない場合は、ローカルまたはCIの設定として渡す方法を別途選ぶ。

## 9. Apple DeveloperへApp IDを登録する

1. [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)を開く。
2. `Identifiers`の追加ボタンを押す。
3. `App IDs`、続いて`App`を選ぶ。
4. Time4のiPhone Bundle IDを登録する。
5. Apple Watch用Bundle IDも必要に応じて登録する。
6. 登録したIDがXcodeのSigningエラーなしで使えることを確認する。

Apple Watchを含むプロジェクトでは、Xcode Cloud開始前にWatch関連Bundle IDの登録不足がないことを確認する。エラーが出た場合は、Xcodeが示すBundle IDと同じものをDeveloperサイトへ追加する。

## 10. App Store ConnectにTime4を作成する

1. [App Store Connect](https://appstoreconnect.apple.com/)へサインインする。
2. `マイApp`を開く。
3. `+`から`新規App`を選ぶ。
4. プラットフォームはiOSを選ぶ。
5. 名前に`Time4`を入力する。
6. プライマリ言語を日本語にする。
7. Bundle IDに登録済みのTime4 iPhone App IDを選ぶ。
8. SKUに内部管理用の値を入力する。例: `time4-ios-001`
9. アクセス権を選択して作成する。

Apple WatchアプリはiOSアプリに含まれるため、Time4では基本的に同じiOSアプリレコードで管理する。

## 11. Xcode Cloud用にXcodeプロジェクトを登録する

Appleは、Xcode Cloudで使用するプロジェクトまたはワークスペースがリポジトリ内に継続して存在する構成を求めている。XcodeGenなどで動的に生成・編集する構成は、初回設定や後続ビルドが失敗する可能性がある。

Time4では`project.yml`を設定の正本として維持しつつ、Xcode Cloudで使う`Time4.xcodeproj`もGitへ登録する。

1. Bundle IDとTeam設定を`project.yml`へ反映する。
2. Xcodeプロジェクトを再生成する。

```bash
xcodegen generate
```

3. 生成されたプロジェクトでiPhone・Watchのビルドを確認する。
4. `project.yml`と`Time4.xcodeproj`をGitへ追加する。

```bash
git add project.yml Time4.xcodeproj
```

5. コミットする。

```bash
git commit -m "Configure Xcode project for cloud builds"
```

6. GitHubへ送る。

```bash
git push
```

以後、`project.yml`を変更した場合は必ず`xcodegen generate`を実行し、生成された`Time4.xcodeproj`も同じコミットへ含める。

参考: [Setting up your project to use Xcode Cloud](https://developer.apple.com/documentation/xcode/setting-up-your-project-to-use-xcode-cloud)

## 12. Xcode CloudとGitHubを接続する

最初のワークフローはXcodeから作成する。

1. MacのTime4フォルダがGitHubの`main`と同期していることを確認する。
2. GitHubの`main`に`Time4.xcodeproj`があることを確認する。
3. Xcodeで`Time4.xcodeproj`を開く。
4. Xcode Cloudの`Create Workflow`を開く。Xcodeのバージョンによって、ProductメニューまたはReport NavigatorのCloudボタンから開始する。
5. ProductとしてiPhoneアプリの`Time4`を選ぶ。
6. Apple DeveloperのTeamを選ぶ。
7. App Store ConnectのTime4レコードを選ぶ。未作成の場合、権限があればXcodeから作成できる。
8. Source ControlとしてGitHubが検出されたことを確認する。
9. `Grant Access`を押す。
10. ブラウザでApple AccountとGitHub Accountを連携する。
11. GitHubに表示されるXcode Cloudアプリを許可する。
12. アクセス対象は可能なら`time4`リポジトリだけに限定する。
13. Xcodeへ戻り、アクセス成功を確認する。

GitHub個人リポジトリでは管理権限が必要。Organization配下の場合はOrganization Ownerの承認が必要になる場合がある。

## 13. 最初のワークフローを作る

初回は設定を増やさず、ビルド成功だけを目的にする。

推奨設定:

- Workflow名: `Time4 Main Build`
- Repository: `vm95yw5t7j-blip/time4`
- Branch: `main`
- Start Condition: 手動、または`main`への変更
- Scheme: `Time4`
- Action: Build
- Platform: iOS
- Xcode: 最新の安定版
- macOS: 推奨または最新の安定版
- TestFlight配布: 初回は無効

設定後、`Start Build`を押す。

## 14. 最初のビルド結果を確認する

成功した場合は以下が確認できる。

- GitHubからcloneできた
- リポジトリ内の`Time4.xcodeproj`を読み込めた
- Swift Packageを解決できた
- iPhoneアプリをビルドできた
- Watchアプリを埋め込めた
- AppleのSigningを利用できた

失敗した場合は、最初に失敗したステップから確認する。

### `Time4.xcodeproj`が見つからない

- Macで`xcodegen generate`を実行したか確認
- `Time4.xcodeproj`をGitへ追加したか確認
- `git status`で未追跡になっていないか確認
- GitHubの`main`に`Time4.xcodeproj`が存在するか確認

### GitHubへアクセスできない

- App Store Connectの`Users and Access > Xcode Cloud`を確認
- GitHubのInstalled GitHub AppsでXcode Cloudを確認
- `time4`リポジトリへのアクセスが許可されているか確認

### Bundle IDまたはSigningエラー

- `project.yml`のBundle IDを確認
- Apple DeveloperのIdentifiersを確認
- XcodeとXcode Cloudで同じTeamを選んでいるか確認
- iPhoneとWatchの両方のBundle IDを確認

### Schemeが見つからない

- Macで`xcodegen generate`を実行
- 次のコマンドで`Time4`と`Time4Watch`が表示されるか確認

```bash
xcodebuild -project Time4.xcodeproj -list
```

### StoreKit設定で失敗する

`StoreKit/Time4.storekit`はローカル購入テスト用。Xcode Cloudの最初のBuildでは購入テストを行わず、ビルド成功を優先する。

### `WKCompanionAppBundleIdentifier`がないためインストールできない

Watchアプリには、親になるiPhoneアプリのBundle IDが必要。`project.yml`のWatchターゲットに次の設定があることを確認する。

```yaml
INFOPLIST_KEY_WKCompanionAppBundleIdentifier: com.naoki.Time4
```

Bundle IDを変更した場合は、この値もiPhoneターゲットのBundle IDと同じ値に変更してから`xcodegen generate`を再実行する。

## 15. 初回成功後に行うこと

最初のビルド成功後は、App Store Connectから管理できる。

1. App Store ConnectでTime4を開く。
2. `Xcode Cloud`タブを開く。
3. `Manage Workflows`を開く。
4. ワークフローの条件、テスト、通知などを編集する。

後から追加する候補:

- Pull RequestごとのBuild
- `main`更新時のBuild
- 単体テスト
- iPhoneの複数OSバージョンでのテスト
- TestFlightへの自動配布
- ビルド失敗通知

TestFlight配布は、ローカルと実機で基本動作を確認してから追加する。

## 16. GitHub Actionsとの役割分担

Time4にはすでにGitHub ActionsのmacOSビルドがある。

GitHub Actions:

- XcodeGen生成を確認
- 共有タイマーロジックのテスト
- 署名なしiPhoneシミュレータービルド
- コード変更時の早いコンパイル確認

Xcode Cloud:

- Apple DeveloperのSigningを使ったビルド
- App Store Connectとの統合
- TestFlight配布
- Appleプラットフォーム向けの継続的なビルド・シミュレーター検証

当面はGitHub Actionsを日常ビルドに使い、Xcode CloudはTestFlightを始める段階で有効化すればよい。

## 17. 完了チェックリスト

- [ ] Xcodeをインストールして初回起動した
- [ ] XcodeへApple Accountを追加した
- [ ] iOS・watchOSコンポーネントをインストールした
- [ ] Time4をGitHubからcloneした
- [ ] Homebrewをインストールした
- [ ] `./scripts/bootstrap-mac.sh`が成功した
- [ ] iPhoneシミュレーターでTime4が起動した
- [ ] Apple WatchシミュレーターでTime4が起動した
- [ ] 最終Bundle IDを決めた
- [ ] iPhone・WatchのApp IDを登録した
- [ ] `Time4.xcodeproj`をGitHubへ登録した
- [ ] App Store ConnectにTime4を作成した
- [ ] Xcode CloudへGitHubアクセスを許可した
- [ ] 最初のXcode Cloudワークフローを作成した
- [ ] Xcode CloudのBuildが成功した
- [ ] App Store Connectからワークフローを確認できた
