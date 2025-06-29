#!/usr/bin/env python3
"""
Demo script showing programmatic usage of the notebook converter.
"""

from pathlib import Path
from ipynb_to_html import NotebookToHTMLConverter

def demo_basic_conversion():
    """Demo basic notebook conversion."""
    print("=== Basic Conversion Demo ===")
    
    # Create converter with default settings
    converter = NotebookToHTMLConverter()
    
    # Convert a single file (if it exists)
    notebook_path = Path("example.ipynb")
    if notebook_path.exists():
        html_path = converter.convert_single_file(notebook_path)
        print(f"Converted: {html_path}")
    else:
        print("example.ipynb not found - create one to test!")

def demo_advanced_conversion():
    """Demo advanced conversion options."""
    print("\n=== Advanced Conversion Demo ===")
    
    # Create converter with custom settings
    converter = NotebookToHTMLConverter(
        embed_images=True,
        include_input=False,  # Hide code cells
        execute_notebook=False,
        template='lab'
    )
    
    notebook_path = Path("example.ipynb")
    if notebook_path.exists():
        output_path = Path("example_report.html")
        html_path = converter.convert_single_file(notebook_path, output_path)
        print(f"Advanced conversion: {html_path}")

def demo_batch_conversion():
    """Demo batch conversion of multiple notebooks."""
    print("\n=== Batch Conversion Demo ===")
    
    converter = NotebookToHTMLConverter()
    
    # Convert all notebooks in current directory
    current_dir = Path(".")
    notebooks_found = list(current_dir.glob("*.ipynb"))
    
    if notebooks_found:
        output_dir = Path("html_output")
        converted_files = converter.convert_directory(current_dir, output_dir)
        print(f"Batch converted {len(converted_files)} files to {output_dir}")
    else:
        print("No .ipynb files found in current directory")

def main():
    """Run all demos."""
    print("Jupyter Notebook to HTML Converter Demo")
    print("=" * 40)
    
    demo_basic_conversion()
    demo_advanced_conversion()
    demo_batch_conversion()
    
    print("\n=== Demo Complete ===")
    print("Check the generated HTML files in your browser!")

if __name__ == "__main__":
    main() 