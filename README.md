# Notebook Converter

A beautiful, cross-platform application for converting Jupyter notebooks (`.ipynb`) to HTML. Built with Flutter for Windows, Linux, macOS, Android, and iOS.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg?style=for-the-badge)

## 📥 Download

### Pre-built Releases (Recommended)

Download the latest release for your platform from [**Releases**](../../releases/latest):

| Platform | Download | Notes |
|----------|----------|-------|
| 🐧 **Linux** | `notebook-converter-linux-x64.tar.gz` | Extract and run |
| 🪟 **Windows** | `notebook-converter-windows-x64.zip` | Extract and run `.exe` |
| 🤖 **Android** | `notebook-converter-android.apk` | Install on device |

### Arch Linux (AUR-style)

Download these files from [Releases](../../releases/latest), then:
- `notebook-converter-linux-x64.tar.gz`
- `PKGBUILD`
- `notebook-converter.desktop`
- `notebook-converter.install`

```bash
# In the directory with downloaded files:
makepkg -si
```

Or build from source:
```bash
cd arch-pkg
./build-package.sh --install
```

## ✨ Features

- 🎨 **10+ Built-in Themes** - Tokyo Night, Dracula, Nord, Monokai, GitHub Light, Catppuccin, and more
- 🖌️ **Custom Theme Editor** - Create your own themes with a live preview
- 🎭 **Background Patterns** - Solid, gradient, dots, grid, diagonal lines, paper texture, blueprint
- 📁 **Drag & Drop** - Simply drag notebooks onto the app
- 📦 **Batch Processing** - Convert multiple files at once
- 🖼️ **Full Output Preservation** - Images, plots, DataFrames, syntax highlighting
- 🎯 **Pure Dart** - No Python dependency required
- 📱 **Cross-Platform** - Works on Linux, Windows, macOS, Android, iOS

## 🎨 Themes

### Built-in Themes

| Dark Themes | Light Themes |
|-------------|--------------|
| Tokyo Night | GitHub Light |
| Dracula | Solarized Light |
| Nord | Paper Light |
| Monokai | |
| One Dark | |
| Catppuccin Mocha | |
| Gruvbox Dark | |

### Custom Theme Editor

Create your own themes with full control over:
- Background colors and patterns (gradient, dots, grid, blueprint, etc.)
- Text and heading colors
- Code cell styling
- Syntax highlighting colors
- Table appearance
- Error/warning colors

## 🛠️ Build from Source

### Prerequisites

- Flutter 3.0+ ([Install Guide](https://docs.flutter.dev/get-started/install))
- For Linux: `cmake`, `ninja`, `clang`, `gtk3`

### Build Commands

```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run -d linux

# Build release
flutter build linux --release    # Linux
flutter build windows --release  # Windows
flutter build apk --release      # Android
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── notebook.dart            # Jupyter notebook parser
│   └── custom_theme.dart        # Custom theme model
├── services/
│   ├── notebook_converter.dart  # Core HTML conversion
│   └── conversion_state.dart    # State management
├── screens/
│   ├── home_screen.dart         # Main UI
│   └── theme_editor_screen.dart # Custom theme editor
└── widgets/
    ├── drop_zone.dart           # Drag & drop area
    ├── file_list_tile.dart      # File list item
    └── settings_panel.dart      # Settings sidebar
```

## 🔧 How It Works

1. **Parse** - Reads `.ipynb` files (JSON format) into Dart objects
2. **Convert** - Transforms cells to HTML:
   - Markdown → rendered HTML via `markdown` package
   - Code → syntax highlighted with `highlight` package
   - Outputs → embedded images, styled DataFrames, error traces
3. **Style** - Applies theme CSS with background patterns
4. **Save** - Writes standalone HTML file

## 📄 License

Mozilla Public License 2.0 - see [LICENSE](LICENSE)

---

**Made with ❤️ using Flutter**
