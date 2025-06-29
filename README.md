# Jupyter Notebook to HTML Converter

A comprehensive tool for converting Jupyter notebooks (.ipynb) to HTML format while preserving all outputs, images, and dataset visualizations. Available as both command-line tool and GUI application.

## Features

- **Complete Output Preservation**: Converts notebooks to HTML while maintaining all cell outputs, plots, images, and dataset visualizations
- **Image Embedding**: Automatically embeds images as base64 in HTML for standalone files
- **Dataset Visualization**: Enhanced styling for pandas DataFrames and other tabular data
- **Flexible Options**: Control over input cell visibility, execution, and output formatting
- **Batch Processing**: Convert single files or entire directories (with recursive option)
- **Multiple Templates**: Choose from different HTML templates (classic, lab, reveal)
- **Enhanced Styling**: Custom CSS for better visualization of outputs
- **GUI Application**: User-friendly interface with file selection dialogs
- **Executable Version**: Create standalone executable for Windows

## Installation

1. Clone or download this repository
2. Install dependencies:

```bash
pip install -r requirements.txt
```

## Usage

### GUI Application (Recommended for most users)

Run the graphical interface:
```bash
python ipynb_to_html_gui_simple.py
```

The GUI provides:
- **File Selection**: Use "Select File(s)" or "Select Folder" buttons
- **Conversion Settings**: Choose template, embedding options, and output preferences
- **Real-time Log**: Monitor conversion progress
- **Output Management**: Automatically open output folder

### Command Line Interface

#### Basic Usage

Convert a single notebook:
```bash
python ipynb_to_html.py notebook.ipynb
```

Convert with custom output name:
```bash
python ipynb_to_html.py notebook.ipynb -o my_report.html
```

#### Advanced Options

Execute notebook before conversion (useful for notebooks without saved outputs):
```bash
python ipynb_to_html.py notebook.ipynb --execute
```

Hide code cells (show only outputs):
```bash
python ipynb_to_html.py notebook.ipynb --no-input
```

Convert entire directory:
```bash
python ipynb_to_html.py notebooks/ -o html_output/
```

Convert directory recursively:
```bash
python ipynb_to_html.py notebooks/ -r
```

Use different template:
```bash
python ipynb_to_html.py notebook.ipynb --template lab
```

#### Command Line Options

- `input`: Input notebook file or directory (required)
- `-o, --output`: Output file or directory
- `-r, --recursive`: Process directories recursively
- `--execute`: Execute notebook before conversion
- `--no-input`: Exclude input cells from output
- `--no-embed-images`: Do not embed images in HTML
- `--template`: HTML template to use (classic, lab, reveal)

## Creating an Executable

To create a standalone Windows executable:

1. Install PyInstaller (included in requirements.txt):
```bash
pip install pyinstaller
```

2. Run the build script:
```bash
python build_executable.py
```

3. Find the executable in the `dist/` folder: `NotebookConverter.exe`

4. Optional: Run `install.bat` as administrator to install system-wide with file associations

### Executable Features

The standalone executable provides:
- **No Python Required**: Runs on any Windows machine
- **File Associations**: Right-click .ipynb files → "Convert to HTML" (after installation)
- **Desktop Shortcut**: Quick access to the converter
- **Portable**: Single .exe file that can be copied anywhere

## Features in Detail

### Image and Plot Handling

The converter automatically handles:
- Matplotlib plots
- Seaborn visualizations  
- PIL/Pillow images
- Base64 encoded images
- SVG graphics

All images are embedded directly in the HTML file by default, making it completely portable.

### Dataset Visualization

Enhanced styling for:
- Pandas DataFrames
- NumPy arrays
- Tabular data output
- Statistical summaries

### Custom Styling

The generated HTML includes:
- Responsive design
- Enhanced table styling
- Syntax highlighting for code
- Professional formatting for outputs
- Mobile-friendly layout

## Examples

### GUI Usage
1. Launch: `python ipynb_to_html_gui_simple.py`
2. Click "Select File(s)" or "Select Folder"
3. Adjust settings as needed
4. Click "Convert to HTML"
5. View results in the log and click "Open Output Folder"

### Convert a Data Analysis Notebook
```bash
python ipynb_to_html.py data_analysis.ipynb --execute -o analysis_report.html
```

### Create Presentation from Notebook
```bash
python ipynb_to_html.py presentation.ipynb --template reveal --no-input
```

### Batch Convert Research Notebooks
```bash
python ipynb_to_html.py research_notebooks/ -r -o html_reports/
```

## Files Overview

- **`ipynb_to_html.py`**: Main command-line converter
- **`ipynb_to_html_gui_simple.py`**: GUI application  
- **`build_executable.py`**: Script to create Windows executable
- **`demo.py`**: Programmatic usage examples
- **`requirements.txt`**: Python dependencies

## Requirements

- Python 3.7+
- nbconvert 7.0.0+
- Jupyter 1.0.0+
- Additional dependencies listed in `requirements.txt`

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Install all requirements with `pip install -r requirements.txt`

2. **Execution errors**: If using `--execute` fails, the converter will proceed with existing outputs

3. **Large images**: Very large images may increase HTML file size significantly

4. **Kernel issues**: Ensure the notebook's kernel is available when using `--execute`

5. **GUI not starting**: Make sure tkinter is installed (included with most Python installations)

### Performance Tips

- For large notebooks, consider using `--no-embed-images` to keep images as separate files
- Use `--no-input` to reduce HTML file size when only outputs are needed
- Process directories in batches if memory usage becomes an issue

## Distribution

For sharing the tool:

1. **Source Code**: Share the entire project folder with `requirements.txt`
2. **Executable**: Use `build_executable.py` to create `NotebookConverter.exe`
3. **Full Installation**: Use `install.bat` for system-wide installation with file associations

## License

This project is open source. Feel free to modify and distribute according to your needs. 