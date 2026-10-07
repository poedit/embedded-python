# Version updates

## Checking current releases

Search the web for the latest stable Python 3.14 and OpenSSL 3.5 LTS releases. Verify versions and release dates on [Python's release pages](https://www.python.org/downloads/) and [OpenSSL's downloads](https://www.openssl-library.org/source/) or [3.5 release notes](https://www.openssl-library.org/news/openssl-3.5-notes/).

## Performing version bumps

1. Update the versions and official source-archive SHA-256 checksums in `versions.config`, including `PYTHON_VERSION_MAJOR` if needed.
2. Build as documented in `README.md`: `./macos/build-xcframework.sh`. It creates `build/macos/Python.xcframework.zip` and updates the URL and checksum in `Package.swift`.
3. Verify the packaged interpreter's Python and OpenSSL versions and that the archive checksum matches `Package.swift`.
4. Commit `versions.config` and the generated `Package.swift` changes together. Commit any required build fixes separately, before the bump.
5. Create a signed release tag as `v<python-version>` using `git tag -s`.
