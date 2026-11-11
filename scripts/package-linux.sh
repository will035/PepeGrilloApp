#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $(uname -sm) == 'Linux x86_64' ]] || { echo 'Se requiere Linux x86-64.' >&2; exit 1; }
version=$(awk '$1 == "version:" {print $2}' pubspec.yaml)
name="PepeGrillo-${version}-linux-x64"
flutter pub get --enforce-lockfile
flutter build linux --release --no-pub
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/$name" dist
cp -a build/linux/x64/release/bundle/. "$stage/$name/"
cp packaging/linux/LEEME.txt assets/fonts/OFL.txt "$stage/$name/"
tar -C "$stage" -czf "dist/$name.tar.gz" "$name"
(cd dist && sha256sum "$name.tar.gz" > "$name.tar.gz.sha256")
