# Simplified Windows Patch Guide

## Quick Patch Instructions

### Method 1: Automatic (Recommended)
Run `5-apply-patches.bat` from the .gist_v4.2 folder. Done!

### Method 2: Search & Replace

#### File 1: `scripts/fetch-and-build.js`
1. Open in any text editor
2. Search for: `await runCommand('cp'`
3. Replace the entire line with:
```javascript
if (process.platform === 'win32') {
  await runCommand('robocopy', [srcPath, destPath, '/E', '/NFL', '/NDL', '/NJH', '/NJS', '/nc', '/ns', '/np']);
} else {
  await runCommand('cp', ['-r', srcPath, destPath]);
}
```

4. Search for: `child.on('exit', (code) => {`
5. Replace the entire function with:
```javascript
child.on('exit', (code) => {
  const isRobocopy = command === 'robocopy' || command.endsWith('robocopy.exe');
  const isSuccess = isRobocopy ? code >= 0 && code <= 7 : code === 0;
  
  if (isSuccess) {
    resolve();
  } else {
    reject(new Error(`Command failed with exit code ${code}`));
  }
});
```

#### File 2: `scripts/build-executables.js`
1. Open in any text editor
2. Search for: `spawn(command, args, { stdio: 'inherit' }`
3. Replace with: `spawn(command, args, { stdio: 'inherit', shell: process.platform === 'win32' }`

#### File 3: `src-tauri/tauri.conf.json`
1. Open in any text editor
2. Search for: `"icons/icon.png"`
3. Add after it: `,` (comma) and new line `"icons/icon.ico"`

That's it! Only 3 simple search & replace operations.