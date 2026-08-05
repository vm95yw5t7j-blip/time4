# Time4

Time4 is an iPhone and Apple Watch preset timer app. It is Apple Watch-first, but it must also be fully useful on iPhone.

Concept: `いつもの時間を、ワンタップで。`

## MVP Scope

- iPhone app for preset setup, editing, and timer use.
- Apple Watch app for faster preset selection and one-tap timer start.
- Each preset has up to 4 independent timers.
- Free plan allows 1 preset.
- Pro is planned as a one-time purchase: `time4.pro.lifetime`.
- Timer state is based on `endsAt`, not view tick counts.
- Running timer state is local to the device that started it in the MVP.

## Current Implementation

- Shared Swift package: `Time4Shared`
- iOS SwiftUI app: `Time4iOS`
- watchOS SwiftUI app: `Time4Watch`
- Project generation: `project.yml` for XcodeGen
- StoreKit config placeholder: `StoreKit/Time4.storekit`

## Product Positioning

`iPhoneでも使える、Apple Watchファーストのプリセットタイマー。`

App Store description draft:

Time4は、いつも使う時間をワンタップで始められるプリセットタイマーです。

用途ごとにプリセットを作り、その中に最大4つの時間を登録できます。

筋トレ、料理、仕事、勉強など、毎回同じ時間を入力する必要はありません。

iPhoneでも使用でき、Apple Watchなら手首からさらに素早くタイマーを開始できます。

## Build On Mac

Install XcodeGen, then run:

```bash
cd /path/to/Time4
xcodegen generate
open Time4.xcodeproj
```

Run shared package tests:

```bash
cd /path/to/Time4/Time4Shared
swift test
```

## Notes

This repository was scaffolded in a Linux environment, so Xcode build verification has not been run here.
