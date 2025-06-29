#!/usr/bin/env python3
"""
Build script to create an executable from the GUI application.
"""

import os
import sys
import subprocess
from pathlib import Path

def build_executable():
    """Build the executable using PyInstaller."""
    
    print("Building Jupyter Notebook to HTML Converter executable...")
    print("=" * 60)
    
    # Check if PyInstaller is installed
    try:
        import PyInstaller
        print(f"✓ PyInstaller found: {PyInstaller.__version__}")
    except ImportError:
        print("✗ PyInstaller not found. Installing...")
        subprocess.run([sys.executable, "-m", "pip", "install", "pyinstaller"], check=True)
        print("✓ PyInstaller installed")
    
    # Build command
    cmd = [
        "pyinstaller",
        "--onefile",                    # Single executable file
        "--windowed",                   # No console window (GUI app)
        "--name=NotebookConverter",     # Executable name
        "--icon=icon.ico",              # Icon file (if exists)
        "--add-data=README.md;.",       # Include README
        "--hidden-import=PIL._tkinter_finder",  # Fix PIL import issues
        "--hidden-import=pkg_resources.py2_warn",
        "--exclude-module=matplotlib.backends._backend_tk",
        "ipynb_to_html_gui_simple.py"
    ]
    
    # Remove icon option if icon file doesn't exist
    if not Path("icon.ico").exists():
        cmd = [c for c in cmd if not c.startswith("--icon")]
        print("Note: No icon.ico file found, building without custom icon")
    
    print("Running PyInstaller...")
    print(" ".join(cmd))
    print()
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("✓ Build successful!")
        print(f"✓ Executable created: dist/NotebookConverter.exe")
        
        # Create a simple installer script
        create_installer_script()
        
    except subprocess.CalledProcessError as e:
        print("✗ Build failed!")
        print("Error output:")
        print(e.stderr)
        return False
    
    return True

def create_installer_script():
    """Create a simple installer script."""
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

REM Register file association
reg add "HKCR\\.ipynb" /ve /d "JupyterNotebook" /f >nul 2>&1
reg add "HKCR\\JupyterNotebook" /ve /d "Jupyter Notebook" /f >nul 2>&1
reg add "HKCR\\JupyterNotebook\\shell\\Convert to HTML" /ve /d "Convert to HTML" /f >nul 2>&1
reg add "HKCR\\JupyterNotebook\\shell\\Convert to HTML\\command" /ve /d "\"%INSTALL_DIR%\\NotebookConverter.exe\" \"%%1\"" /f >nul 2>&1

echo.
echo ✓ Installation complete!
echo ✓ Desktop shortcut created
echo ✓ Right-click menu integration added
echo.
echo You can now:
echo   - Use the desktop shortcut to open the converter
echo   - Right-click on .ipynb files and select "Convert to HTML"
echo   - Select files using the GUI interface
echo.
pause
'''
    
    with open("install.bat", "w") as f:
        f.write(installer_content)
    
    print("✓ Installer script created: install.bat")

def create_icon():
    """Create a simple icon for the application."""
    try:
        from PIL import Image, ImageDraw
        
        # Create a simple icon
        size = 64
        img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
        draw = ImageDraw.Draw(img)
        
        # Draw a simple notebook icon
        # Background
        draw.rectangle([8, 8, size-8, size-8], fill=(255, 140, 0), outline=(200, 100, 0), width=2)
        
        # Lines representing text
        for i in range(3):
            y = 20 + i * 8
            draw.rectangle([16, y, size-16, y+2], fill=(255, 255, 255))
        
        # Arrow pointing right (conversion)
        arrow_x = size - 20
        arrow_y = size // 2
        draw.polygon([
            (arrow_x, arrow_y-6),
            (arrow_x+8, arrow_y),
            (arrow_x, arrow_y+6)
        ], fill=(255, 255, 255))
        
        img.save("icon.ico", format='ICO')
        print("✓ Icon created: icon.ico")
        return True
        
    except ImportError:
        print("Note: PIL not available, skipping icon creation")
        return False

def main():
    """Main build process."""
    print("Jupyter Notebook to HTML Converter - Build Script")
    print("=" * 60)
    
    # Check if GUI file exists
    if not Path("ipynb_to_html_gui_simple.py").exists():
        print("✗ Error: ipynb_to_html_gui_simple.py not found!")
        print("Make sure you're running this script in the project directory.")
        return
    
    # Create icon
    create_icon()
    
    # Build executable
    if build_executable():
        print("\n" + "=" * 60)
        print("BUILD COMPLETE!")
        print("=" * 60)
        print("Files created:")
        print("  - dist/NotebookConverter.exe  (Main executable)")
        print("  - install.bat                 (Windows installer)")
        print()
        print("To distribute:")
        print("  1. Copy dist/NotebookConverter.exe to target machine")
        print("  2. Or run install.bat as administrator for full installation")
        print()
        print("The executable supports:")
        print("  - User-friendly GUI interface")
        print("  - File associations (after installation)")
        print("  - Standalone operation (no Python required)")
    else:
        print("Build failed. Please check the error messages above.")

if __name__ == "__main__":
    main() 