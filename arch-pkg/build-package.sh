#!/bin/bash
# Build script for creating the Arch Linux package
# Automatically detects Flutter or uses pre-built binary

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       Notebook Converter - Arch Linux Package Builder        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Function to find Flutter
find_flutter() {
    # Check if already in PATH
    if command -v flutter &> /dev/null; then
        echo "$(dirname "$(command -v flutter)")"
        return 0
    fi
    
    # Common Flutter installation locations
    local flutter_locations=(
        "$HOME/Develop/flutter/bin"
        "$HOME/flutter/bin"
        "$HOME/.flutter/bin"
        "$HOME/.local/flutter/bin"
        "$HOME/snap/flutter/common/flutter/bin"
        "/opt/flutter/bin"
        "/usr/lib/flutter/bin"
        "/usr/local/flutter/bin"
    )
    
    for loc in "${flutter_locations[@]}"; do
        if [ -x "$loc/flutter" ]; then
            echo "$loc"
            return 0
        fi
    done
    
    return 1
}

# Try to find Flutter
FLUTTER_PATH=""
if FLUTTER_PATH=$(find_flutter); then
    echo "✓ Flutter found at: $FLUTTER_PATH"
    export PATH="$FLUTTER_PATH:$PATH"
else
    echo "⚠ Flutter not found in common locations."
    echo ""
    
    # Check if pre-built binary exists
    if [ -d "$PROJECT_DIR/build/linux/x64/release/bundle" ]; then
        echo "✓ Pre-built binary found! Using existing build."
        SKIP_BUILD=1
    else
        echo "Flutter is required to build from source."
        echo ""
        echo "Options:"
        echo "  1. Install Flutter: https://docs.flutter.dev/get-started/install"
        echo "  2. Set Flutter path: export PATH=\$PATH:/path/to/flutter/bin"
        echo "  3. Use a pre-built package (if available)"
        echo ""
        read -p "Enter Flutter path (or press Enter to abort): " CUSTOM_PATH
        
        if [ -n "$CUSTOM_PATH" ] && [ -x "$CUSTOM_PATH/flutter" ]; then
            export PATH="$CUSTOM_PATH:$PATH"
            echo "✓ Using Flutter at: $CUSTOM_PATH"
        elif [ -n "$CUSTOM_PATH" ] && [ -x "$CUSTOM_PATH/bin/flutter" ]; then
            export PATH="$CUSTOM_PATH/bin:$PATH"
            echo "✓ Using Flutter at: $CUSTOM_PATH/bin"
        else
            echo "✗ Flutter not found. Aborting."
            exit 1
        fi
    fi
fi

cd "$PROJECT_DIR"

# Build Flutter app
if [ -z "$SKIP_BUILD" ]; then
    echo ""
    echo "→ Building Flutter app (release mode)..."
    flutter build linux --release
    echo "✓ Build complete!"
fi

echo ""
echo "→ Creating Arch package..."

cd "$SCRIPT_DIR"

# Clean previous builds
rm -rf pkg src *.tar.gz 2>/dev/null || true

# Create the bundle tarball
if [ -d "$PROJECT_DIR/build/linux/x64/release/bundle" ]; then
    echo "→ Creating bundle archive..."
    cd "$PROJECT_DIR/build/linux/x64/release"
    tar -czf "$SCRIPT_DIR/bundle.tar.gz" bundle
    cd "$SCRIPT_DIR"
fi

# Use the prebuilt PKGBUILD for simpler packaging
echo "→ Running makepkg..."
cp PKGBUILD-prebuilt PKGBUILD.tmp

# Update the source to use local bundle
cat > PKGBUILD << 'PKGBUILD_CONTENT'
# Maintainer: Your Name <your-email@example.com>
pkgname=notebook-converter
pkgver=1.0.0
pkgrel=1
pkgdesc="Convert Jupyter notebooks to beautiful HTML - Flutter GUI app"
arch=('x86_64')
url="https://github.com/RitzDaCat/ipynb_to_html"
license=('MPL2')
depends=(
    'gtk3'
    'glib2'
)
optdepends=(
    'xdg-utils: for opening files and folders'
)
source=()
sha256sums=()
install=notebook-converter.install

package() {
    cd "$startdir"
    
    # Create directories
    install -dm755 "$pkgdir/opt/$pkgname"
    install -dm755 "$pkgdir/usr/bin"
    install -dm755 "$pkgdir/usr/share/applications"

    # Extract and install the app bundle
    tar -xzf bundle.tar.gz -C "$pkgdir/opt/$pkgname" --strip-components=1
    
    # Make executable
    chmod +x "$pkgdir/opt/$pkgname/notebook_converter"

    # Create launcher script
    cat > "$pkgdir/usr/bin/$pkgname" << 'EOF'
#!/bin/bash
cd /opt/notebook-converter
exec ./notebook_converter "$@"
EOF
    chmod +x "$pkgdir/usr/bin/$pkgname"

    # Install desktop file
    install -Dm644 "notebook-converter.desktop" \
        "$pkgdir/usr/share/applications/$pkgname.desktop"

    # Install icons for KDE/GNOME (all standard sizes)
    install -Dm644 "icon.svg" "$pkgdir/usr/share/icons/hicolor/scalable/apps/$pkgname.svg"
    for size in 16 22 24 32 48 64 128 256 512; do
        install -dm755 "$pkgdir/usr/share/icons/hicolor/${size}x${size}/apps"
        install -Dm644 "icon-${size}.png" "$pkgdir/usr/share/icons/hicolor/${size}x${size}/apps/$pkgname.png" 2>/dev/null || true
    done
}
PKGBUILD_CONTENT

makepkg -sf --noconfirm

rm -f PKGBUILD.tmp

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  ✓ Package built successfully!               ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  To install now:                                             ║"
echo "║    sudo pacman -U notebook-converter-*.pkg.tar.zst           ║"
echo "║                                                              ║"
echo "║  Or install directly:                                        ║"
echo "║    Run this script with --install flag                       ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if --install flag was passed
if [[ "$1" == "--install" ]] || [[ "$1" == "-i" ]]; then
    echo "→ Installing package..."
    sudo pacman -U --noconfirm notebook-converter-*.pkg.tar.zst
    echo ""
    echo "✓ Installation complete!"
    echo "  Launch with: notebook-converter"
    echo "  Or find 'Notebook Converter' in your application menu"
fi

# List created packages
echo "Package created:"
ls -lh *.pkg.tar.zst 2>/dev/null
