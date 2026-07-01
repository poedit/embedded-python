#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

. ./versions.config

: "${PYTHON_VERSION:?}"

name=Python
build_dir=build/macos
archive_path="$build_dir/macosx.xcarchive"
xcframework_path="$build_dir/$name.xcframework"
package_path="$build_dir/$name-package"
zip_name="$name.xcframework.zip"
zip_path="$build_dir/$zip_name"
url="https://github.com/poedit/python-framework/releases/download/v$PYTHON_VERSION/$zip_name"

mkdir -p "$build_dir"
rm -rf "$archive_path" "$xcframework_path" "$package_path" "$zip_path"

xcodebuild archive \
    -quiet \
    -sdk macosx \
    -archivePath "$archive_path" \
    -scheme "$name"

xcodebuild -create-xcframework \
    -output "$xcframework_path" \
    -archive "$archive_path" \
    -framework "$name.framework"

mkdir -p "$package_path/bin"
cp -a "$xcframework_path" "$package_path/"

# create helper script to run python as part of builds:
python_bin_path="$(find "$package_path/$name.xcframework" -path "*/$name.framework/Versions/*/Resources/Home/bin" -type d -print -quit)"
if [ -z "$python_bin_path" ]; then
    echo "error: Python.framework Resources/Home/bin directory not found in $name.xcframework" >&2
    exit 1
fi
python_bin_path="${python_bin_path#$package_path/}"

cat >"$package_path/bin/python" <<EOF
#!/bin/sh
SELF="\$(realpath "\$0")"
ROOT="\$(dirname "\$SELF")/.."
exec "\$ROOT/$python_bin_path/python" "\$@"
EOF
chmod +x "$package_path/bin/python"

# test it works:
"$package_path/bin/python" -c 'import sys; print(sys.version)'

# package it all:
(
    cd "$package_path"
    ditto -c -k --sequesterRsrc . "../$zip_name"
)

checksum="$(swift package compute-checksum "$zip_path")"

url="$url" checksum="$checksum" perl -0pi -e '
    s|(url:\s*")[^"]+(")|$1$ENV{url}$2|s
        or die "error: binary target URL not found\n";
    s|(checksum:\s*")[0-9a-f]{64}(")|$1$ENV{checksum}$2|s
        or die "error: binary target checksum not found\n";
' Package.swift

cat <<EOF
Created $zip_path
Updated Package.swift
Release URL: $url
Checksum: $checksum
EOF
