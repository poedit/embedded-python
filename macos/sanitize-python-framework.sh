#!/bin/bash -e
#
# Make the Python.framework builtin by Python makefiles friendlier to use on
# macOS by removing useless cruft, moving things around and changing link
# paths.
#

ROOT="$1"
PREFIX=$(dirname "$ROOT")

if [ -z "$ROOT" ] ; then
    echo "Usage: $0 /path/to/Python.framework" >&2
    exit 1
fi

cd "$ROOT"/

VERSION=$(cd Versions && ls -1 | grep '^[0-9]')
MAJOR_VERSION=$(echo ${VERSION} | cut -d. -f1)

cd Versions/$VERSION

# Verify that there's no accidental linkage of Homebrew etc. deps:

for dylib in lib/python${VERSION}/lib-dynload/*.so ; do
    if otool -L $dylib | grep -qE '(/usr/local|/opt/homebrew|/opt/local)'; then
      echo "Unwanted linkage of Homebrew/MacPorts libraries found in $dylib"
      exit 1
    fi
done

# Delete cruft:

rm -rf share
rm -f bin/2to3* bin/idle* bin/pydoc* bin/pyvenv*
rm -f bin/*-config
rm -f bin/easy_install* bin/pip*

if [ -f bin/python${VERSION} ]; then
    rm -f bin/python bin/python${MAJOR_VERSION}
    mv bin/python${VERSION} bin/python
    ln -s python bin/python${MAJOR_VERSION}
    ln -s python bin/python${VERSION}
fi


# Fix install names so that runtime linker works:

if ! otool -l bin/python | grep LC_RPATH >/dev/null ; then
    install_name_tool -add_rpath "@loader_path/../../../.." bin/python
fi

bad_name=$(otool -L Resources/Python.app/Contents/MacOS/Python |grep "@rpath" | cut -f2 | cut -d' ' -f1 | sort | uniq)
if [ -n "$bad_name" ] ; then
    install_name_tool -change "$bad_name" "@loader_path/../../../../Python" Resources/Python.app/Contents/MacOS/Python
fi


# Strip unneeded debug symbols:

strip -S -x lib/python${VERSION}/lib-dynload/*.so
chmod +w Python
strip -S -x Python
strip -S -u -r bin/python
strip -S -u -r Resources/Python.app/Contents/MacOS/Python


# Fix distutils so that building modules works:

/usr/bin/sed -i "" -e "s,@rpath,$PREFIX,g" lib/python${VERSION}/config-${VERSION}-darwin/Makefile lib/python${VERSION}/_sysconfigdata__darwin_darwin.py
/usr/bin/sed -i "" -e "s,-lintl -liconv -framework CoreFoundation,,g" lib/python${VERSION}/_sysconfigdata__darwin_darwin.py
