# Time4 Development Handover

## Product

App name: Time4

App Store display proposal: `Time4：Apple Watchプリセットタイマー`

Catch copy: `いつもの時間を、ワンタップで。`

Time4 is a simple preset timer app for iPhone and Apple Watch. It is Apple Watch-first, but iPhone users must be able to use the main timer experience without owning an Apple Watch.

Positioning: `iPhoneでも使える、Apple Watchファーストのプリセットタイマー。`

## Core Decision

The MVP is not a sequence timer.

Each timer inside a preset is independent. On Apple Watch, a preset opens to up to four large buttons in a 2x2 layout, and tapping one starts only that timer.

## MVP

iPhone:

- Preset list.
- Create, edit, delete presets.
- Reorder presets.
- Up to 4 timers per preset.
- 2x2 timer buttons.
- One-tap start.
- Remaining time.
- Progress display.
- Pause, resume, stop.
- Edit timer duration.
- Local notification on finish.
- Restore running timer.
- Sync presets to Apple Watch.
- Free limit: 1 preset.
- Pro one-time purchase groundwork.

Apple Watch:

- Preset list.
- Preset selection.
- 2x2 timer buttons.
- One-tap start.
- Remaining time.
- Pause, resume, stop.
- Haptic feedback on finish.

## Device Roles

iPhone:

- Source of truth for preset data.
- Preset management and Pro purchase/restore.
- Timer use with the same preset -> 4 buttons -> instant start flow.

Apple Watch:

- Fastest timer start surface.
- Uses the latest synced preset data.
- Keeps a local copy so it can run with the last synced presets while offline.
- Does not do detailed preset editing in the MVP.

## Sync Policy

Preset data syncs between iPhone and Apple Watch.

Running timer state does not need complete realtime cross-device control in the MVP. The device that starts a timer owns that timer:

- Timer started on iPhone is controlled on iPhone.
- Timer started on Apple Watch is controlled on Apple Watch.

Future versions may add realtime shared running timer control.

## Deferred

- Sequence timer.
- Multiple simultaneous timers.
- Folders.
- Sharing.
- User accounts.
- Social features.
- Detailed stats.
- Usage history analysis.
- Domain-specific modes for training, cooking, beauty salons, or field work.

## Engineering Rules

- Timer progress must be calculated from `endsAt`.
- A running timer's duration cannot be adjusted. Users choose one of up to four preset timers before starting.
- Running timer state must be persisted so the watch can restore it after returning from the watch face.
- iPhone running timer state must also be persisted so it restores after app restart.
- Preset edits during a running timer should not mutate the active timer; the active timer stores a snapshot of preset and timer names.
- Running timer state stores `startedAt`, `endsAt`, pause state, paused remaining seconds, timer ID, preset ID, and execution device.
- Free to Pro upgrade must keep existing data.
- Restore purchase must be implemented before App Store submission.
