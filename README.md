# Claudia For Windows v4.2

A comprehensive Windows compatibility solution for [Claudia GUI](https://github.com/getAsterisk/claudia) using WSL (Windows Subsystem for Linux) as a bridge.

![Windows](https://img.shields.io/badge/Windows-10%2F11-blue)
![WSL](https://img.shields.io/badge/WSL-2-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🎯 Overview

This repository provides a complete solution to run Claudia (a GUI for Claude) on Windows by:
- Installing Claude CLI in WSL where it works natively
- Creating a Windows bridge script that Claudia can communicate with
- Automatically patching Claudia's source code for Windows compatibility
- Providing pre-flight checks and automated installation

## 📋 Prerequisites

- Windows 10/11 with latest updates
- WSL 2 (Windows Subsystem for Linux)
- Ubuntu from Microsoft Store
- Node.js 18+ (installed in WSL)
- Bun (installed in Windows)
- Rust (installed in Windows)
- Visual Studio Build Tools

## 🚀 Quick Installation

1. Clone Claudia:
   ```cmd
   git clone https://github.com/getAsterisk/claudia.git
   cd claudia
   ```

2. Clone this repository into Claudia folder:
   ```cmd
   git clone https://github.com/Kirchlive/Claudia-For-Windows.git
   ```

3. Run the auto-installer:
   ```cmd
   Claudia-For-Windows\5-auto-install-windows.bat
   ```

4. When prompted, press 'y' to continue with setup

5. Build Claudia (in Windows CMD):
   ```cmd
   bun install
   bun run build
   bun run tauri build
   ```

6. Launch with:
   ```cmd
   start-claudia.bat
   ```

## 📁 Repository Contents

- **`1-claudia-windows-fix.md`** - Complete installation guide
- **`2-claude_binary_patch.rs`** - Version compatibility patch reference
- **`3-setup-windows.bat`** - WSL bridge setup script
- **`4-start-claudia.bat`** - Pre-flight checker and launcher
- **`5-auto-install-windows.bat`** - Fully automated installer
- **`patches/`** - Individual patch files for reference

## 🔧 What the Auto-Installer Does

The `5-auto-install-windows.bat` automatically:
- ✅ Patches main.rs for version compatibility
- ✅ Fixes agents.rs to suppress "Projects directory not found" errors
- ✅ Updates fetch-and-build.js for Windows (robocopy support)
- ✅ Fixes build-executables.js (adds shell support)
- ✅ Adds icon.ico to tauri.conf.json
- ✅ Handles robocopy exit codes properly
- ✅ Creates backups of all modified files

## 🆕 What's New in v4.2

- **Fully Automated Installation**: No more manual patching required!
- **Projects Directory Fix**: Suppresses repeating error messages
- **Smart Patch Detection**: Checks if patches are already applied
- **Backup Creation**: Automatically backs up files before modification
- **Integrated Setup**: Option to run setup script automatically
- **Better Error Handling**: Improved robocopy exit code handling

## 🐛 Troubleshooting

Common issues and solutions are documented in `1-claudia-windows-fix.md`.

### Quick Tips:
- Always build in Windows CMD/PowerShell, NOT in WSL
- Claude Code must be installed in WSL, not Windows
- The start script must be copied to the main Claudia folder

## 🤝 Contributing

Found an issue or improvement? Please:
1. Test the fix thoroughly
2. Document any new issues
3. Submit a pull request or open an issue

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

This fix was developed collaboratively by the Claudia community. Special thanks to all testers and contributors who helped refine this solution for Windows users.

## 📚 Additional Resources

- [Claudia Repository](https://github.com/getAsterisk/claudia)
- [Detailed Installation Guide](1-claudia-windows-fix.md)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)