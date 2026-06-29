#!/bin/sh

set -e

. ../versions.config

OPENSSL_TARBALL="openssl-$OPENSSL_VERSION.tar.gz"
OPENSSL_URL="https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/$OPENSSL_TARBALL"
OPENSSL_DOWNLOAD="$DEPS_BUILD_DIR/$OPENSSL_TARBALL"

download_openssl() {
    if [ -f "$OPENSSL_DOWNLOAD" ]; then
        actual_sha256="$(shasum -a256 "$OPENSSL_DOWNLOAD" | cut -f1 -d' ')"
        if [ "$actual_sha256" = "$OPENSSL_SHA256" ]; then
            return
        fi
    fi

    echo "Downloading $OPENSSL_URL..."
    curl --fail --location --retry 5 --retry-all-errors -o "$OPENSSL_DOWNLOAD.tmp" "$OPENSSL_URL"
    actual_sha256="$(shasum -a256 "$OPENSSL_DOWNLOAD.tmp" | cut -f1 -d' ')"
    if [ "$actual_sha256" != "$OPENSSL_SHA256" ]; then
        echo "error: checksum mismatch for $OPENSSL_TARBALL" >&2
        rm -f "$OPENSSL_DOWNLOAD.tmp"
        exit 1
    fi
    mv "$OPENSSL_DOWNLOAD.tmp" "$OPENSSL_DOWNLOAD"
}

download_openssl

rm -rf "$WORKDIR" "$DEPS_DESTDIR"
mkdir -p "$WORKDIR" "$INTDIR"

echo "Building OpenSSL for $ARCH..."
tar -x -f "$OPENSSL_DOWNLOAD" -C "$WORKDIR" --strip-components 1

cd "$WORKDIR"

./Configure darwin64-${ARCH}-cc no-shared no-zlib no-tests --prefix=/

make
make install_sw DESTDIR="$DEPS_DESTDIR"

rm -rf "$WORKDIR"
touch "$INTDIR/$target.done"
