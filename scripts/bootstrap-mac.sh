#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_dir"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must be run on a Mac."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Install and launch Xcode, then run this script again."
  exit 1
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required to install XcodeGen: https://brew.sh"
    exit 1
  fi

  brew install xcodegen
fi

xcodegen generate
xcodebuild -project Time4.xcodeproj -list
open Time4.xcodeproj

echo "Time4.xcodeproj is ready. Select the Time4 scheme and an iPhone simulator, then press Run."
