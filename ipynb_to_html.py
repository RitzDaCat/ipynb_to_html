#!/usr/bin/env python3
"""
Jupyter Notebook to HTML Converter
Converts .ipynb files to HTML while preserving all outputs, images, and dataset visualizations.
"""

import argparse
import os
import sys
from pathlib import Path
import base64
import re
from typing import Optional, Dict, Any

try:
    from nbconvert import HTMLExporter
    from nbconvert.preprocessors import ExecutePreprocessor
    import nbformat
    from bs4 import BeautifulSoup
    from PIL import Image
except ImportError as e:
    print(f"Error: Missing required dependency: {e}")
    print("Please install requirements: pip install -r requirements.txt")
    sys.exit(1)


class NotebookToHTMLConverter:
    """Enhanced notebook to HTML converter with image and dataset support."""
    
    def __init__(self, embed_images: bool = True, include_input: bool = True, 
                 execute_notebook: bool = False, template: str = 'classic'):
        """
        Initialize the converter.
        
        Args:
            embed_images: Whether to embed images as base64 in HTML
            include_input: Whether to include code cells in output
            execute_notebook: Whether to execute notebook before conversion
            template: HTML template to use ('classic', 'lab', 'reveal')
        """
        self.embed_images = embed_images
        self.include_input = include_input
        self.execute_notebook = execute_notebook
        self.template = template
        
        # Configure HTML exporter
        self.html_exporter = HTMLExporter()
        self.html_exporter.template_name = template
        
        # Configure to embed images
        if embed_images:
            self.html_exporter.embed_images = True
        
        # Configure input cell visibility
        if not include_input:
            self.html_exporter.exclude_input = True
    
    def _execute_notebook(self, notebook_path: Path) -> nbformat.NotebookNode:
        """Execute notebook if requested."""
        print(f"Executing notebook: {notebook_path}")
        
        with open(notebook_path, 'r', encoding='utf-8') as f:
            notebook = nbformat.read(f, as_version=4)
        
        # Configure execution
        ep = ExecutePreprocessor(timeout=600, kernel_name='python3')
        
        try:
            ep.preprocess(notebook, {'metadata': {'path': str(notebook_path.parent)}})
            return notebook
        except Exception as e:
            print(f"Warning: Failed to execute notebook: {e}")
            print("Proceeding with existing outputs...")
            return notebook
    
    def _enhance_html_output(self, html_content: str, notebook_path: Path) -> str:
        """Enhance HTML output with better styling and image handling."""
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # Add custom CSS for better visualization
        custom_css = """
        <style>
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .output_png, .output_jpeg, .output_svg {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 10px auto;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .dataframe {
            border-collapse: collapse;
            margin: 1em 0;
            font-size: 0.9em;
            min-width: 400px;
            border-radius: 5px 5px 0 0;
            overflow: hidden;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
        }
        .dataframe thead tr {
            background-color: #009879;
            color: #ffffff;
            text-align: left;
        }
        .dataframe th,
        .dataframe td {
            padding: 12px 15px;
            border-bottom: 1px solid #dddddd;
        }
        .dataframe tbody tr {
            border-bottom: 1px solid #dddddd;
        }
        .dataframe tbody tr:nth-of-type(even) {
            background-color: #f3f3f3;
        }
        .code_cell {
            margin: 1em 0;
        }
        .input_area {
            background-color: #f8f9fa;
            border-left: 4px solid #007bff;
            padding: 10px;
            margin: 5px 0;
        }
        .output_area {
            background-color: #fff;
            border-left: 4px solid #28a745;
            padding: 10px;
            margin: 5px 0;
        }
        </style>
        """
        
        # Insert custom CSS
        if soup.head:
            soup.head.insert(0, BeautifulSoup(custom_css, 'html.parser'))
        
        return str(soup)
    
    def convert_single_file(self, input_path, output_path=None):
        """
        Convert a single notebook file to HTML.
        
        Args:
            input_path: Path to input .ipynb file (str or Path)
            output_path: Path for output HTML file (optional, str or Path)
            
        Returns:
            Path to generated HTML file
        """
        # Convert to Path objects if strings
        input_path = Path(input_path) if isinstance(input_path, str) else input_path
        output_path = Path(output_path) if output_path and isinstance(output_path, str) else output_path
        
        if not input_path.exists():
            raise FileNotFoundError(f"Input file not found: {input_path}")
        
        if not input_path.suffix.lower() == '.ipynb':
            raise ValueError(f"Input file must be a .ipynb file: {input_path}")
        
        print(f"Converting: {input_path}")
        
        # Determine output path
        if output_path is None:
            output_path = input_path.with_suffix('.html')
        
        try:
            # Load and optionally execute notebook
            if self.execute_notebook:
                notebook = self._execute_notebook(input_path)
            else:
                with open(input_path, 'r', encoding='utf-8') as f:
                    notebook = nbformat.read(f, as_version=4)
            
            # Convert to HTML
            (body, resources) = self.html_exporter.from_notebook_node(notebook)
            
            # Enhance HTML output
            enhanced_html = self._enhance_html_output(body, input_path)
            
            # Write HTML file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(enhanced_html)
            
            # Handle additional resources (images, etc.)
            if resources.get('outputs'):
                output_dir = output_path.parent / f"{output_path.stem}_files"
                output_dir.mkdir(exist_ok=True)
                
                for filename, data in resources['outputs'].items():
                    resource_path = output_dir / filename
                    with open(resource_path, 'wb') as f:
                        f.write(data)
            
            print(f"✓ Converted successfully: {output_path}")
            return output_path
            
        except Exception as e:
            print(f"✗ Error converting {input_path}: {e}")
            raise
    
    def convert_directory(self, input_dir: Path, output_dir: Optional[Path] = None,
                         recursive: bool = False) -> list[Path]:
        """
        Convert all notebooks in a directory.
        
        Args:
            input_dir: Directory containing .ipynb files
            output_dir: Output directory (defaults to input_dir)
            recursive: Whether to search subdirectories
            
        Returns:
            List of generated HTML file paths
        """
        if not input_dir.exists() or not input_dir.is_dir():
            raise NotADirectoryError(f"Input directory not found: {input_dir}")
        
        if output_dir is None:
            output_dir = input_dir
        else:
            output_dir.mkdir(parents=True, exist_ok=True)
        
        # Find notebook files
        pattern = "**/*.ipynb" if recursive else "*.ipynb"
        notebook_files = list(input_dir.glob(pattern))
        
        if not notebook_files:
            print(f"No .ipynb files found in {input_dir}")
            return []
        
        converted_files = []
        print(f"Found {len(notebook_files)} notebook(s) to convert")
        
        for notebook_file in notebook_files:
            try:
                # Maintain directory structure in output
                relative_path = notebook_file.relative_to(input_dir)
                output_file = output_dir / relative_path.with_suffix('.html')
                output_file.parent.mkdir(parents=True, exist_ok=True)
                
                converted_file = self.convert_single_file(notebook_file, output_file)
                converted_files.append(converted_file)
                
            except Exception as e:
                print(f"Failed to convert {notebook_file}: {e}")
                continue
        
        return converted_files


def main():
    """Command line interface."""
    parser = argparse.ArgumentParser(
        description="Convert Jupyter notebooks to HTML with full output preservation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s notebook.ipynb                    # Convert single notebook
  %(prog)s notebook.ipynb -o output.html    # Specify output file
  %(prog)s notebooks/ -r                    # Convert all notebooks recursively
  %(prog)s notebook.ipynb --execute         # Execute before conversion
  %(prog)s notebook.ipynb --no-input        # Hide code cells
        """
    )
    
    parser.add_argument('input', type=str,
                       help='Input notebook file or directory')
    parser.add_argument('-o', '--output', type=str,
                       help='Output file or directory')
    parser.add_argument('-r', '--recursive', action='store_true',
                       help='Process directories recursively')
    parser.add_argument('--execute', action='store_true',
                       help='Execute notebook before conversion')
    parser.add_argument('--no-input', action='store_true',
                       help='Exclude input cells from output')
    parser.add_argument('--no-embed-images', action='store_true',
                       help='Do not embed images in HTML')
    parser.add_argument('--template', choices=['classic', 'lab', 'reveal'], 
                       default='classic', help='HTML template to use')
    
    args = parser.parse_args()
    
    # Parse paths
    input_path = Path(args.input)
    output_path = Path(args.output) if args.output else None
    
    # Create converter
    converter = NotebookToHTMLConverter(
        embed_images=not args.no_embed_images,
        include_input=not args.no_input,
        execute_notebook=args.execute,
        template=args.template
    )
    
    try:
        if input_path.is_file():
            # Convert single file
            converter.convert_single_file(input_path, output_path)
            
        elif input_path.is_dir():
            # Convert directory
            converted_files = converter.convert_directory(
                input_path, output_path, args.recursive
            )
            print(f"\n✓ Successfully converted {len(converted_files)} notebook(s)")
            
        else:
            print(f"Error: Input path not found: {input_path}")
            sys.exit(1)
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main() 