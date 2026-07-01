# Embedded Python

This repository provides a Swift Package Manager package with a Python framework packaged for easier embedding in Poedit.

It is intended for use from Poedit's build system and runtime components.

## Building

Run:

```sh
./macos/build-xcframework.sh
```

The output archive is created as `build/macos/Python.xcframework.zip`.

After building, commit the updated `Package.swift`, tag the release, and upload the zip file to the GitHub release.
