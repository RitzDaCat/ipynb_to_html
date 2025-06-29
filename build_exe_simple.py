#!/usr/bin/env python3
"""
Simple build script for the notebook converter executable.
"""

import os
import sys
import subprocess
from pathlib import Path

def main():
    """Build the executable with minimal complexity."""
    print("Building Notebook Converter Executable")
    print("=" * 50)
    
    # Check if GUI file exists
    if not Path("ipynb_to_html_gui_simple.py").exists():
        print("✗ Error: ipynb_to_html_gui_simple.py not found!")
        return
    
    # Simple PyInstaller command
    cmd = [
        "pyinstaller",
        "--onefile",
        "--windowed", 
        "--name=NotebookConverter",
        "ipynb_to_html_gui_simple.py"
    ]
    
    print("Running PyInstaller (this may take 5-10 minutes)...")
    print("Command:", " ".join(cmd))
    print("Please wait...")
    
    try:
        # Run with real-time output
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, 
                                 universal_newlines=True, bufsize=1)
        
        # Print output as it comes
        if process.stdout:
            for line in process.stdout:
                if "INFO:" in line or "WARNING:" in line or "ERROR:" in line:
                    print(line.strip())
        
        process.wait()
        
        if process.returncode == 0:
            print("\n✓ Build successful!")
            print("✓ Executable created: dist/NotebookConverter.exe")
            
            # Check if file actually exists
            exe_path = Path("dist/NotebookConverter.exe")
            if exe_path.exists():
                size_mb = exe_path.stat().st_size / (1024 * 1024)
                print(f"✓ File size: {size_mb:.1f} MB")
            else:
                print("⚠ Warning: Executable not found in expected location")
        else:
            print(f"\n✗ Build failed with exit code: {process.returncode}")
            
    except KeyboardInterrupt:
        print("\n\nBuild cancelled by user")
        return
    except Exception as e:
        print(f"✗ Build failed: {e}")
        return

if __name__ == "__main__":
    main() 