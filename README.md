# Jupyter Notebook to HTML Converter

A comprehensive tool for converting Jupyter notebooks (.ipynb) to HTML format while preserving all outputs, images, and dataset visualizations. 

**🚀 For most users**: Download the ready-to-use Windows executable - no Python installation required!  
**🔧 For developers**: Full source code available for customization and cross-platform use.

## ⚡ Quick Start (Windows Users)

### Option 1: Download Executable (Recommended)
1. **Download**: Get `NotebookConverter.exe` from the [Releases](../../releases) page
2. **Run**: Double-click the executable - that's it!
3. **Convert**: Use the GUI to select your `.ipynb` files and convert to HTML

### Option 2: One-Click Installation
1. **Download**: Get both `NotebookConverter.exe` and `install.bat` from [Releases](../../releases)
2. **Install**: Right-click `install.bat` → "Run as administrator"
3. **Use**: Access via desktop shortcut or right-click any `.ipynb` file → "Convert to HTML"

## ✨ Features

- **Complete Output Preservation**: Converts notebooks to HTML while maintaining all cell outputs, plots, images, and dataset visualizations
- **Image Embedding**: Automatically embeds images as base64 in HTML for standalone files
- **Dataset Visualization**: Enhanced styling for pandas DataFrames and other tabular data
- **User-Friendly GUI**: Simple interface with file selection dialogs
- **Batch Processing**: Convert single files or entire directories
- **Multiple Templates**: Choose from different HTML templates (classic, lab, reveal)
- **Enhanced Styling**: Custom CSS for better visualization of outputs
- **No Dependencies**: Executable version requires no Python installation

## 📖 How to Use

### GUI Interface
1. **Launch** the application (double-click `NotebookConverter.exe`)
2. **Select Files**: Click "Select File(s)" or "Select Folder"
3. **Choose Settings**: 
   - Template style (Classic, Lab, Reveal)
   - Include/exclude code cells
   - Embed images (recommended)
4. **Convert**: Click "Convert to HTML"
5. **View Results**: Click "Open Output Folder" to see your HTML files

### Example Use Cases
- **📊 Data Analysis Reports**: Convert analysis notebooks to shareable HTML reports
- **📚 Educational Content**: Turn tutorial notebooks into web-friendly formats
- **📈 Research Documentation**: Create professional-looking research outputs
- **🎯 Presentations**: Use Reveal.js template for slide presentations

## 🎯 What Makes This Special

### Enhanced HTML Output
- **Beautiful DataFrames**: Professional styling for pandas tables
- **Responsive Design**: Works great on mobile and desktop
- **Embedded Images**: All plots and images included in single HTML file
- **Syntax Highlighting**: Code cells with proper formatting
- **Custom CSS**: Enhanced visual styling for better readability

### Smart Conversion
- **Preserves Everything**: All outputs, plots, images, and markdown
- **Multiple Formats**: Support for PNG, JPEG, SVG graphics
- **Dataset Friendly**: Optimized for data science notebooks
- **Error Handling**: Graceful handling of problematic cells

---

## 🔧 For Developers & Power Users

### Source Code Installation

If you want to customize the tool or run it on non-Windows systems:

#### Prerequisites
- Python 3.7+
- pip package manager

#### Installation
```bash
git clone https://github.com/RitzDaCat/ipynb_to_html.git
cd ipynb_to_html
pip install -r requirements.txt
```

#### Usage
```bash
# GUI Version
python ipynb_to_html_gui_simple.py

# Command Line Version
python ipynb_to_html.py notebook.ipynb
```

### Command Line Interface

#### Basic Usage
```bash
# Convert single notebook
python ipynb_to_html.py notebook.ipynb

# Convert with custom output name
python ipynb_to_html.py notebook.ipynb -o my_report.html

# Convert entire directory
python ipynb_to_html.py notebooks/ -o html_output/

# Convert recursively with execution
python ipynb_to_html.py notebooks/ -r --execute
```

#### Advanced Options
- `--execute`: Execute notebook before conversion
- `--no-input`: Hide code cells (show only outputs)
- `--no-embed-images`: Keep images as separate files
- `--template`: Choose template (classic, lab, reveal)
- `-r, --recursive`: Process directories recursively

### Building Your Own Executable

```bash
# Simple build
python build_exe_simple.py

# Advanced build (with installer)
python build_executable.py
```

### Project Structure
- **`ipynb_to_html.py`**: Main command-line converter
- **`ipynb_to_html_gui_simple.py`**: GUI application  
- **`build_exe_simple.py`**: Simple executable builder
- **`build_executable.py`**: Advanced executable builder with installer
- **`demo.py`**: Programmatic usage examples
- **`requirements.txt`**: Python dependencies

### Programmatic Usage
```python
from ipynb_to_html import NotebookToHTMLConverter

# Create converter
converter = NotebookToHTMLConverter(
    embed_images=True,
    include_input=False,  # Hide code cells
    template='lab'
)

# Convert file
converter.convert_single_file('notebook.ipynb', 'output.html')
```

## 🛠️ Troubleshooting

### Common Issues
1. **Executable won't run**: Make sure you downloaded all files and Windows isn't blocking the .exe
2. **Missing outputs**: Try using the `--execute` option in command line version
3. **Large file sizes**: Disable image embedding with `--no-embed-images`
4. **GUI not starting**: Ensure the executable has proper permissions

### For Python Users
1. **Import errors**: Install all requirements with `pip install -r requirements.txt`
2. **Kernel issues**: Ensure Jupyter kernels are properly installed
3. **Permission errors**: Run command prompt as administrator if needed

## 📋 Technical Requirements

### For Executable Users
- **Windows 10/11** (64-bit)
- **No additional software** required

### For Source Code Users
- **Python 3.7+**
- **nbconvert 7.0.0+**
- **Jupyter 1.0.0+**
- Additional dependencies in `requirements.txt`

## 🤝 Contributing

This project is open source! Feel free to:
- Report bugs via [Issues](../../issues)
- Suggest features via [Issues](../../issues)  
- Submit improvements via [Pull Requests](../../pulls)
- Fork the project for your own modifications

## 📄 License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE](LICENSE) file for details.

---

**⭐ If this tool helps you, please give it a star on GitHub!** 