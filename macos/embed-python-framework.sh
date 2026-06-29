#!/bin/bash -e
#
# Take mostly-vanilla Python.framework prepared by
# macos-sanitize-python-framework.sh and create embeddable copy from it that
# conforms to codesigning rules.
#

if [ -z "$1" -o -z "$2" ] ; then
    echo "Usage: $0 Python.framework embedded.framework" >&2
    exit 1
fi

VERSION=$(cd "$1/Versions" && ls -1 | grep '^[0-9]')
SOURCE="$1/Versions/$VERSION"
DEST_TOP="$2"
DEST="$DEST_TOP/Versions/$VERSION"

rm -rf "$DEST"/*
mkdir -p "$DEST/Resources"

# Put binary, headers and resources into their expected places:
cp "$SOURCE/Python" "$DEST/Python"
cp "$SOURCE/Resources/Info.plist" "$DEST/Resources/"
cp -r "$SOURCE/include/python${VERSION}" "$DEST/Headers"

# Some binaries can't go into their Python.framework places due to codesign
# errors, so shuffle them around:
mkdir -p "$DEST/Frameworks"
mkdir -p "$DEST/Helpers"
cp -a "$SOURCE/bin/python" "$DEST/Helpers"
cp -a "$SOURCE/Resources/Python.app" "$DEST/Helpers"
rm -rf "$DEST/Resources/Python.app" && ln -sf ../Helpers/Python.app "$DEST/Resources/Python.app"


# Create normal-looking PYTHONHOME to work with
mkdir -p "$DEST"/Resources/Home/{lib,bin}

ln -sf ../../../Frameworks "$DEST/Resources/Home/lib/python${VERSION}"
ln -sf ../../../Helpers/python "$DEST/Resources/Home/bin/python.bin"

cat >"$DEST/Resources/Home/bin/python" << EOF
#!/bin/sh
PYTHONHOME="\`dirname "\$0"\`/.."
export PYTHONHOME
exec "\$0.bin" "\$@"
EOF
chmod +x "$DEST/Resources/Home/bin/python"

# Copy standard library to appropriate places:
cp -a "$SOURCE/lib/python$VERSION/lib-dynload/"* "$DEST/Frameworks"
cp -a "$SOURCE/lib/python$VERSION/"* "$DEST/Resources/Home/lib/"
rm -rf "$DEST/Resources/Home/lib/lib-dynload"


# Apple thinks it owns org.python.python bundle id, so change it:
#/usr/bin/sed -i "" -e "s/org.python.python/net.poedit.Python/g" "$DEST/Resources/Info.plist"
/usr/bin/sed -i "" -e "s/org.python.python/net.poedit.PythonApp/g" "$DEST/Helpers/Python.app/Contents/Info.plist"

# Reconstruct toplevel symlinks:
rm -f "$DEST_TOP/Versions/Current"
ln -s "$VERSION" "$DEST_TOP/Versions/Current"
for fn in Python Headers Resources ; do
    rm -f "$DEST_TOP/$fn"
    ln -s "Versions/Current/$fn" "$DEST_TOP/$fn"
done

# check linkage correctness:
"$DEST_TOP/Versions/Current/Helpers/python" --version
"$DEST_TOP/Versions/Current/Resources/Home/bin/python" --version
