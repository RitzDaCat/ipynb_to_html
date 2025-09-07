#!/usr/bin/env python3
"""
Cross-platform build script for the notebook converter.
Supports both Windows and Linux builds.
"""

import os
import sys
import platform
import subprocess
from pathlib import Path

def get_platform_info():
	"""Get platform-specific information."""
	system = platform.system().lower()
	is_windows = system == 'windows'
	is_linux = system == 'linux'
	is_macos = system == 'darwin'
	
	return {
		'system': system,
		'is_windows': is_windows,
		'is_linux': is_linux,
		'is_macos': is_macos,
		'exe_extension': '.exe' if is_windows else '',
		'path_separator': ';' if is_windows else ':'
	}

def check_dependencies():
	"""Check if required dependencies are available."""
	missing = []
	
	# Check Python packages with correct import names
	package_imports = {
		'nbconvert': 'nbconvert',
		'jupyter': 'jupyter',
		'jinja2': 'jinja2',
		'beautifulsoup4': 'bs4',
		'pillow': 'PIL',
		'matplotlib': 'matplotlib',
		'pyinstaller': 'PyInstaller'
	}
	
	for package, import_name in package_imports.items():
		try:
			__import__(import_name)
			print(f"✓ {package} found")
		except ImportError:
			print(f"✗ {package} missing")
			missing.append(package)
	
	return missing

def build_executable(platform_info):
	"""Build the executable using PyInstaller."""
	
	print("\nBuilding Jupyter Notebook to HTML Converter executable...")
	print("=" * 60)
	
	# Base PyInstaller command
	cmd = [
		"pyinstaller",
		"--onefile",
		"--name=NotebookConverter",
		"ipynb_to_html_gui_simple.py"
	]
	
	# Platform-specific options
	if platform_info['is_windows']:
		cmd.append("--windowed")  # No console window on Windows
		cmd.append("--icon=icon.ico") if Path("icon.ico").exists() else None
		cmd.extend([
			"--add-data", "README.md;.",
			"--hidden-import=PIL._tkinter_finder",
		])
	
	elif platform_info['is_linux']:
		# Linux-specific options
		cmd.extend([
			"--add-data", "README.md:.",
			"--hidden-import=PIL._tkinter_finder",
		])
		
		# Check if running under Wayland
		if os.environ.get('WAYLAND_DISPLAY'):
			print("Note: Wayland detected. The application will use tkinter which works with XWayland.")
	
	elif platform_info['is_macos']:
		cmd.append("--windowed")
		cmd.extend([
			"--add-data", "README.md:.",
			"--hidden-import=PIL._tkinter_finder",
		])
	
	# Remove None values from cmd
	cmd = [c for c in cmd if c is not None]
	
	print("Running PyInstaller...")
	print(" ".join(cmd))
	print("\nThis may take 5-10 minutes...")
	
	try:
		# Run with real-time output
		process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, 
								 universal_newlines=True, bufsize=1)
		
		# Print output as it comes
		if process.stdout:
			for line in process.stdout:
				if any(keyword in line for keyword in ["INFO:", "WARNING:", "ERROR:", "Building", "Analyzing"]):
					print(line.strip())
		
		process.wait()
		
		if process.returncode == 0:
			exe_name = f"NotebookConverter{platform_info['exe_extension']}"
			exe_path = Path("dist") / exe_name
			
			print(f"\n✓ Build successful!")
			print(f"✓ Executable created: {exe_path}")
			
			if exe_path.exists():
				size_mb = exe_path.stat().st_size / (1024 * 1024)
				print(f"✓ File size: {size_mb:.1f} MB")
				
				# Make executable on Linux/Mac
				if not platform_info['is_windows']:
					import stat
					exe_path.chmod(exe_path.stat().st_mode | stat.S_IEXEC)
					print("✓ Made file executable")
			else:
				print("⚠ Warning: Executable not found in expected location")
				return False
		else:
			print(f"\n✗ Build failed with exit code: {process.returncode}")
			return False
			
	except KeyboardInterrupt:
		print("\n\nBuild cancelled by user")
		return False
	except Exception as e:
		print(f"✗ Build failed: {e}")
		return False
	
	return True

def create_linux_desktop_file():
	"""Create a .desktop file for Linux systems."""
	desktop_content = """[Desktop Entry]
Version=1.0
Type=Application
Name=Notebook Converter
Comment=Convert Jupyter notebooks to HTML
Exec={exec_path}
Icon=jupyter
Terminal=false
Categories=Development;Education;Science;
MimeType=application/x-ipynb+json;
"""
	
	exec_path = Path.cwd() / "dist" / "NotebookConverter"
	desktop_content = desktop_content.format(exec_path=exec_path.absolute())
	
	desktop_file = Path("NotebookConverter.desktop")
	desktop_file.write_text(desktop_content)
	desktop_file.chmod(0o755)
	
	print(f"✓ Desktop file created: {desktop_file}")
	print("  To install system-wide:")
	print(f"  sudo cp {desktop_file} /usr/share/applications/")
	print("  To install for current user:")
	print(f"  cp {desktop_file} ~/.local/share/applications/")

def create_windows_installer():
	"""Create a Windows installer batch script."""
	installer_content = '''@echo off
echo Installing Notebook Converter...
echo.

REM Create installation directory
set INSTALL_DIR=%PROGRAMFILES%\\NotebookConverter
mkdir "%INSTALL_DIR%" 2>nul

REM Copy executable
copy "dist\\NotebookConverter.exe" "%INSTALL_DIR%\\" >nul
if errorlevel 1 (
	echo Error: Failed to copy executable. Please run as administrator.
	pause
	exit /b 1
)

REM Create desktop shortcut
set DESKTOP=%USERPROFILE%\\Desktop
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\\shortcut.vbs"
echo sLinkFile = "%DESKTOP%\\Notebook Converter.lnk" >> "%TEMP%\\shortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\\shortcut.vbs"
echo oLink.TargetPath = "%INSTALL_DIR%\\NotebookConverter.exe" >> "%TEMP%\\shortcut.vbs"
echo oLink.Description = "Convert Jupyter notebooks to HTML" >> "%TEMP%\\shortcut.vbs"
echo oLink.Save >> "%TEMP%\\shortcut.vbs"
cscript "%TEMP%\\shortcut.vbs" >nul
del "%TEMP%\\shortcut.vbs"

echo.
echo Installation complete!
echo Desktop shortcut created
echo.
pause
'''
	
	with open("install_windows.bat", "w") as f:
		f.write(installer_content)
	
	print("✓ Windows installer created: install_windows.bat")

def create_linux_installer():
	"""Create a Linux installer shell script."""
	installer_content = '''#!/bin/bash

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
	echo "  export PATH=\\$PATH:$(dirname "$BIN_LINK")"
fi
'''
	
	with open("install_linux.sh", "w") as f:
		f.write(installer_content)
	
	Path("install_linux.sh").chmod(0o755)
	print("✓ Linux installer created: install_linux.sh")

def main():
	"""Main build process."""
	print("Cross-Platform Jupyter Notebook to HTML Converter Builder")
	print("=" * 60)
	
	# Get platform info
	platform_info = get_platform_info()
	print(f"Platform: {platform_info['system'].title()}")
	print(f"Python: {sys.version.split()[0]}")
	print()
	
	# Check if GUI file exists
	if not Path("ipynb_to_html_gui_simple.py").exists():
		print("✗ Error: ipynb_to_html_gui_simple.py not found!")
		print("Make sure you're running this script in the project directory.")
		return 1
	
	# Check dependencies
	print("Checking dependencies...")
	missing = check_dependencies()
	
	if missing:
		print(f"\n⚠ Warning: Missing packages: {', '.join(missing)}")
		print("Install with: pip install -r requirements.txt")
		# Check if running in non-interactive mode
		if not sys.stdin.isatty():
			print("Running in non-interactive mode, continuing with build...")
		else:
			response = input("\nContinue anyway? (y/N): ").lower()
			if response != 'y':
				print("Build cancelled.")
				return 1
	
	# Build executable
	if build_executable(platform_info):
		print("\n" + "=" * 60)
		print("BUILD COMPLETE!")
		print("=" * 60)
		
		exe_name = f"NotebookConverter{platform_info['exe_extension']}"
		print(f"\nExecutable created: dist/{exe_name}")
		
		# Create platform-specific installers
		if platform_info['is_windows']:
			create_windows_installer()
			print("\nTo install on Windows:")
			print("  Run install_windows.bat as administrator")
		
		elif platform_info['is_linux']:
			create_linux_desktop_file()
			create_linux_installer()
			print("\nTo install on Linux:")
			print("  ./install_linux.sh        (user installation)")
			print("  sudo ./install_linux.sh   (system-wide installation)")
		
		print("\nThe executable can be run directly from dist/ without installation")
		print("It includes all dependencies and requires no Python installation")
		
		return 0
	else:
		print("\nBuild failed. Please check the error messages above.")
		return 1

if __name__ == "__main__":
	sys.exit(main())