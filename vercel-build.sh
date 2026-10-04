#!/usr/bin/env bash
#
# Vercel build for the DoseGPT PWA.
#
# Vercel does not ship the Flutter SDK, so it has to be installed here. This
# runs on every production build from the Git integration.
#
# The pinned version matches what CI and local development use, so a Dart
# upgrade cannot land on the deployed site without anyone choosing it. If that
# archive is ever removed upstream the build falls back to the current stable
# channel rather than hard-failing every deploy.
set -euo pipefail

# Flutter resolves the project from the working directory, so every path here
# is absolute and this script never changes directory. An earlier version did
# `cd /tmp` to unpack the SDK and never returned, so `flutter pub get` ran in
# /tmp and died with "Expected to find project root in current working
# directory".
PROJECT_DIR="$(pwd)"
SDK_DIR="/tmp/flutter-sdk"
TARBALL="/tmp/flutter-sdk.tar.xz"
FLUTTER_VERSION="3.32.7"
BASE="https://storage.googleapis.com/flutter_infra_release/releases"

if [ ! -x "${SDK_DIR}/bin/flutter" ]; then
  echo "Installing Flutter ${FLUTTER_VERSION}..."
  PINNED="${BASE}/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

  if ! curl -fsSL --retry 3 --retry-delay 2 "$PINNED" -o "$TARBALL"; then
    echo "Pinned ${FLUTTER_VERSION} archive unavailable, using current stable."
    ARCHIVE="$(
      curl -fsSL "${BASE}/releases_linux.json" |
        grep -o '"archive": *"stable/linux/[^"]*linux\.tar\.xz"' |
        head -1 |
        sed 's/.*"stable\/linux\///; s/"$//'
    )"
    curl -fsSL --retry 3 --retry-delay 2 "${BASE}/stable/linux/${ARCHIVE}" -o "$TARBALL"
  fi

  # -C unpacks without moving the shell's working directory.
  tar -xJf "$TARBALL" -C /tmp
  mv /tmp/flutter "$SDK_DIR"
  rm -f "$TARBALL"
fi

export PATH="${SDK_DIR}/bin:${PATH}"
# git refuses to run against an SDK owned by a different uid, which is the
# normal situation inside a container.
git config --global --add safe.directory "${SDK_DIR}"

# Fail loudly and specifically if we are not in the project, rather than
# letting the Flutter tool report it as a missing project root.
if [ ! -f "${PROJECT_DIR}/pubspec.yaml" ]; then
  echo "ERROR: no pubspec.yaml in ${PROJECT_DIR}" >&2
  exit 1
fi
cd "${PROJECT_DIR}"

flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version

flutter pub get
flutter build web --release

# A PWA that silently lost its manifest or service worker still "builds", so
# assert the pieces that make it installable and offline-capable rather than
# trusting a zero exit code.
test -f build/web/index.html
test -f build/web/manifest.json
test -f build/web/flutter_service_worker.js

grep -q "DoseGPT" build/web/manifest.json
grep -q "flutter-first-frame" build/web/index.html
grep -q "Inter-Variable.ttf" build/web/assets/FontManifest.json
grep -q "NotoSansEthiopic-Variable.ttf" build/web/assets/FontManifest.json

# The service worker must precache the clinical data, or an offline install
# opens to an empty app.
for asset in drugs.json adult_drugs.json illnesses.json meta.json; do
  grep -q "$asset" build/web/flutter_service_worker.js
done

echo "manifest, service worker, bundled fonts and precached data all verified"