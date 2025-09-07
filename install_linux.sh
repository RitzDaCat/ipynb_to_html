#!/bin/bash

echo "Installing Notebook Converter..."
echo

# Check if running as root for system-wide installation
if [ "$EUID" -eq 0 ]; then
	INSTALL_DIR="/opt/notebook-converter"
	BIN_LINK="/usr/local/bin/notebook-converter"
	DESKTOP_DIR="/usr/share/applications"
	echo "Installing system-wide..."
else
	INSTALL_DIR="$HOME/.local/opt/notebook-converter"
	BIN_LINK="$HOME/.local/bin/notebook-converter"
	DESKTOP_DIR="$HOME/.local/share/applications"
	echo "Installing for current user..."
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy executable
cp dist/NotebookConverter "$INSTALL_DIR/" || {
	echo "Error: Failed to copy executable"
	exit 1
}

# Make executable
chmod +x "$INSTALL_DIR/NotebookConverter"

# Create symbolic link
mkdir -p "$(dirname "$BIN_LINK")"
ln -sf "$INSTALL_DIR/NotebookConverter" "$BIN_LINK"

# Install desktop file if it exists
if [ -f "NotebookConverter.desktop" ]; then
	mkdir -p "$DESKTOP_DIR"
	cp NotebookConverter.desktop "$DESKTOP_DIR/"
	echo "✓ Desktop entry installed"
fi

echo
echo "✓ Installation complete!"
echo "✓ Executable installed to: $INSTALL_DIR"
echo "✓ Command available as: notebook-converter"
echo

# Add to PATH if needed
if ! echo "$PATH" | grep -q "$(dirname "$BIN_LINK")"; then
	echo "Note: You may need to add $(dirname "$BIN_LINK") to your PATH"
	echo "Add this to your ~/.bashrc or ~/.zshrc:"
	echo "  export PATH=\$PATH:$(dirname "$BIN_LINK")"
fi
