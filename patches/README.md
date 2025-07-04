# Pre-patched Files for Windows

This folder contains pre-patched versions of the files that need Windows-specific modifications.

## Usage

Simply copy these files to their respective locations:

1. Copy `fetch-and-build.js` to `scripts/fetch-and-build.js`
2. Copy `build-executables.js` to `scripts/build-executables.js`
3. Copy `tauri.conf.json` to `src-tauri/tauri.conf.json`

```cmd
# From the Claudia root directory:
copy .gist_v4.2\patches\fetch-and-build.js scripts\
copy .gist_v4.2\patches\build-executables.js scripts\
copy .gist_v4.2\patches\tauri.conf.json src-tauri\
```

## What's Changed

### fetch-and-build.js
- Added robocopy support for Windows
- Proper exit code handling (0-7 for robocopy)

### build-executables.js
- Added shell support for Windows spawn commands

### tauri.conf.json
- Added icon.ico to the icon array