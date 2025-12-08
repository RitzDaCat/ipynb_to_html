#!/bin/bash
# One-liner installer for Notebook Converter on Arch Linux
# Usage: curl -sSL https://raw.githubusercontent.com/RitzDaCat/ipynb_to_html/main/install.sh | bash

set -e

echo ""
echo "  ╭─────────────────────────────────────────╮"
echo "  │     Notebook Converter Installer        │"
echo "  │     Arch Linux / Pacman                 │"
echo "  ╰─────────────────────────────────────────╯"
echo ""

# Check if running on Arch-based system
if ! command -v pacman &> /dev/null; then
    echo "✗ Error: pacman not found. This installer is for Arch Linux."
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "→ Downloading package files..."

# Download the arch-pkg files
BASE_URL="https://raw.githubusercontent.com/RitzDaCat/ipynb_to_html/main/arch-pkg"
curl -sSLO "$BASE_URL/PKGBUILD" || { echo "✗ Failed to download PKGBUILD"; exit 1; }
curl -sSLO "$BASE_URL/notebook-converter.desktop" || { echo "✗ Failed to download desktop file"; exit 1; }
curl -sSLO "$BASE_URL/notebook-converter.install" || { echo "✗ Failed to download install script"; exit 1; }
curl -sSLO "$BASE_URL/build-package.sh" || { echo "✗ Failed to download build script"; exit 1; }
chmod +x build-package.sh

echo "→ Building package (this may take a minute)..."
./build-package.sh

echo ""
echo "→ Installing package..."
sudo pacman -U --noconfirm notebook-converter-*.pkg.tar.zst

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "  ╭─────────────────────────────────────────╮"
echo "  │     ✓ Installation Complete!            │"
echo "  │                                         │"
echo "  │  Launch: notebook-converter             │"
echo "  │  Or find 'Notebook Converter' in menu   │"
echo "  ╰─────────────────────────────────────────╯"
echo ""

