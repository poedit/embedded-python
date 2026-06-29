#!/bin/sh

set -e

. ../versions.config

PYTHON_TARBALL="Python-$PYTHON_VERSION.tar.xz"
PYTHON_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_TARBALL"
PYTHON_DOWNLOAD="$DEPS_BUILD_DIR/$PYTHON_TARBALL"

download_python() {
    if [ -f "$PYTHON_DOWNLOAD" ]; then
        actual_sha256="$(shasum -a256 "$PYTHON_DOWNLOAD" | cut -f1 -d' ')"
        if [ "$actual_sha256" = "$PYTHON_SHA256" ]; then
            return
        fi
    fi

    echo "Downloading $PYTHON_URL..."
    curl --fail --location --retry 5 --retry-all-errors -o "$PYTHON_DOWNLOAD.tmp" "$PYTHON_URL"
    actual_sha256="$(shasum -a256 "$PYTHON_DOWNLOAD.tmp" | cut -f1 -d' ')"
    if [ "$actual_sha256" != "$PYTHON_SHA256" ]; then
        echo "error: checksum mismatch for $PYTHON_TARBALL" >&2
        rm -f "$PYTHON_DOWNLOAD.tmp"
        exit 1
    fi
    mv "$PYTHON_DOWNLOAD.tmp" "$PYTHON_DOWNLOAD"
}

download_python

rm -rf "$WORKDIR" "$DEPS_DESTDIR"
mkdir -p "$WORKDIR" "$INTDIR"

echo "Building Python..."
tar -x -f "$PYTHON_DOWNLOAD" -C "$WORKDIR" --strip-components 1

cd "$WORKDIR"

if [ "$ONLY_ACTIVE_ARCH" = "NO" ] ; then
    python_universal_sdk_flags="--enable-universalsdk --with-universal-archs=universal2"
else
    python_universal_sdk_flags=""
fi

./configure \
    --cache-file=$CONFIG_CACHE \
    --prefix=/ \
    CC="$CC" \
    CXX="$CXX" \
    CFLAGS="$CFLAGS -I$SDKROOT/usr/include" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    MACOSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET \
    --enable-framework=@rpath \
    $python_universal_sdk_flags \
    --without-static-libpython \
    --disable-test-modules \
    --with-readline=no \
    --without-system-expat \
    --without-system-libmpdec \
    --with-openssl="$DEPS_BUILD_DIR/openssl" \
    --enable-optimizations \
    --with-lto=thin \
    --with-ensurepip=no

make
make install -j1 DESTDIR="$DEPS_DESTDIR/"

mv "$DEPS_DESTDIR"/@rpath/* "$DEPS_DESTDIR"/
"$TOP_SRCDIR/sanitize-python-framework.sh" "$DEPS_DESTDIR/Python.framework"

# check linkage correctness:
"$DEPS_DESTDIR/Python.framework/Versions/Current/bin/python" --version

rm -rf "$WORKDIR"
touch "$INTDIR/$target.done"
