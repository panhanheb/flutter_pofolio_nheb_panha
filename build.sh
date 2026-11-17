#!/usr/bin/env bash
# Cloudflare build command: bash build.sh
# The build image has git, curl and unzip but no Flutter, so install a pinned SDK.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.5}"
FLUTTER_DIR="${HOME}/flutter"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi
export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter config --no-analytics --enable-web >/dev/null
flutter --version
flutter pub get
flutter build web --release
