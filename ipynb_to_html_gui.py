#!/usr/bin/env python3
"""
Jupyter Notebook to HTML Converter - GUI Version
A user-friendly GUI application with drag-and-drop support for converting notebooks to HTML.
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import tkinter.dnd as dnd
import os
import sys
import threading
from pathlib import Path
from typing import List, Optional
import queue
import re

# Import our converter
try:
    from ipynb_to_html import NotebookToHTMLConverter
except ImportError:
    print("Error: Could not import ipynb_to_html module")
    sys.exit(1)


class NotebookConverterGUI:
    """GUI application for converting Jupyter notebooks to HTML."""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Jupyter Notebook to HTML Converter")
        self.root.geometry("800x600")
        self.root.resizable(True, True)
        
        # Configure style
        self.style = ttk.Style()
        self.style.theme_use('clam')
        
        # Queue for thread communication
        self.message_queue = queue.Queue()
        
        # Current settings
        self.settings = {
            'embed_images': tk.BooleanVar(value=True),
            'include_input': tk.BooleanVar(value=True),
            'execute_notebook': tk.BooleanVar(value=False),
            'template': tk.StringVar(value='classic'),
            'output_directory': tk.StringVar(value='')
        }
        
        self.setup_ui()
        self.setup_drag_drop()
        
        # Start message processing
        self.process_messages()
    
    def setup_ui(self):
        """Set up the user interface."""
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky="ewns")
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(4, weight=1)
        
        # Title
        title_label = ttk.Label(main_frame, text="Jupyter Notebook to HTML Converter", 
                               font=('Arial', 16, 'bold'))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))
        
        # File selection area
        self.setup_file_selection(main_frame)
        
        # Settings area
        self.setup_settings(main_frame)
        
        # Output area
        self.setup_output_area(main_frame)
        
        # Buttons
        self.setup_buttons(main_frame)
    
    def setup_file_selection(self, parent):
        """Set up file selection area with drag-and-drop."""
        # File selection frame
        file_frame = ttk.LabelFrame(parent, text="Select Files", padding="10")
        file_frame.grid(row=1, column=0, columnspan=3, sticky="ew", pady=(0, 10))
        file_frame.columnconfigure(0, weight=1)
        
        # Drag and drop area
        self.drop_area = tk.Text(file_frame, height=6, width=60, 
                                bg='#f0f0f0', relief='sunken', bd=2)
        self.drop_area.grid(row=0, column=0, columnspan=2, sticky="ew", pady=(0, 10))
        
        # Instructions
        instructions = ("Drag and drop .ipynb files here, or use the buttons below\n"
                       "• Single files will be converted to HTML\n"
                       "• Multiple files will be batch converted\n"
                       "• Folders will be processed recursively")
        self.drop_area.insert(tk.END, instructions)
        self.drop_area.config(state=tk.DISABLED)
        
        # File selection buttons
        button_frame = ttk.Frame(file_frame)
        button_frame.grid(row=1, column=0, columnspan=2, sticky="ew")
        
        ttk.Button(button_frame, text="Select File(s)", 
                  command=self.select_files).pack(side=tk.LEFT, padx=(0, 10))
        ttk.Button(button_frame, text="Select Folder", 
                  command=self.select_folder).pack(side=tk.LEFT, padx=(0, 10))
        ttk.Button(button_frame, text="Clear", 
                  command=self.clear_files).pack(side=tk.LEFT)
        
        # Selected files list
        self.selected_files = []
        self.files_var = tk.StringVar()
        self.files_label = ttk.Label(file_frame, textvariable=self.files_var, 
                                    wraplength=600, justify=tk.LEFT)
        self.files_label.grid(row=2, column=0, columnspan=2, sticky="ew", pady=(10, 0))
    
    def setup_settings(self, parent):
        """Set up conversion settings."""
        settings_frame = ttk.LabelFrame(parent, text="Conversion Settings", padding="10")
        settings_frame.grid(row=2, column=0, columnspan=3, sticky="ew", pady=(0, 10))
        settings_frame.columnconfigure(1, weight=1)
        
        row = 0
        
        # Template selection
        ttk.Label(settings_frame, text="Template:").grid(row=row, column=0, sticky=tk.W, padx=(0, 10))
        template_combo = ttk.Combobox(settings_frame, textvariable=self.settings['template'],
                                     values=['classic', 'lab', 'reveal'], state='readonly')
        template_combo.grid(row=row, column=1, sticky=(tk.W, tk.E), padx=(0, 20))
        row += 1
        
        # Checkboxes
        ttk.Checkbutton(settings_frame, text="Embed images in HTML (recommended)", 
                       variable=self.settings['embed_images']).grid(row=row, column=0, columnspan=2, 
                                                                   sticky=tk.W, pady=5)
        row += 1
        
        ttk.Checkbutton(settings_frame, text="Include code cells in output", 
                       variable=self.settings['include_input']).grid(row=row, column=0, columnspan=2, 
                                                                    sticky=tk.W, pady=5)
        row += 1
        
        ttk.Checkbutton(settings_frame, text="Execute notebook before conversion (slower)", 
                       variable=self.settings['execute_notebook']).grid(row=row, column=0, columnspan=2, 
                                                                        sticky=tk.W, pady=5)
        row += 1
        
        # Output directory
        ttk.Label(settings_frame, text="Output Directory:").grid(row=row, column=0, sticky=tk.W, pady=(10, 0))
        output_frame = ttk.Frame(settings_frame)
        output_frame.grid(row=row+1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(5, 0))
        output_frame.columnconfigure(0, weight=1)
        
        self.output_entry = ttk.Entry(output_frame, textvariable=self.settings['output_directory'])
        self.output_entry.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=(0, 10))
        
        ttk.Button(output_frame, text="Browse", 
                  command=self.select_output_directory).grid(row=0, column=1)
        
        ttk.Label(settings_frame, text="(Leave empty to save next to original files)", 
                 font=('Arial', 8), foreground='gray').grid(row=row+2, column=0, columnspan=2, 
                                                           sticky=tk.W, pady=(5, 0))
    
    def setup_output_area(self, parent):
        """Set up output/log area."""
        output_frame = ttk.LabelFrame(parent, text="Conversion Log", padding="10")
        output_frame.grid(row=4, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        output_frame.columnconfigure(0, weight=1)
        output_frame.rowconfigure(0, weight=1)
        
        self.output_text = scrolledtext.ScrolledText(output_frame, height=15, width=80)
        self.output_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Clear log button
        ttk.Button(output_frame, text="Clear Log", 
                  command=self.clear_log).grid(row=1, column=0, sticky=tk.W, pady=(10, 0))
    
    def setup_buttons(self, parent):
        """Set up action buttons."""
        button_frame = ttk.Frame(parent)
        button_frame.grid(row=5, column=0, columnspan=3, pady=(0, 10))
        
        self.convert_button = ttk.Button(button_frame, text="Convert to HTML", 
                                        command=self.start_conversion, style='Accent.TButton')
        self.convert_button.pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(button_frame, text="Open Output Folder", 
                  command=self.open_output_folder).pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(button_frame, text="Exit", 
                  command=self.root.quit).pack(side=tk.RIGHT)
    
    def setup_drag_drop(self):
        """Set up drag and drop functionality."""
        self.drop_area.drop_target_register('DND_Files')
        self.drop_area.dnd_bind('<<Drop>>', self.on_drop)
        
        # Also bind to the whole window for better UX
        self.root.drop_target_register('DND_Files')
        self.root.dnd_bind('<<Drop>>', self.on_drop)
    
    def on_drop(self, event):
        """Handle drag and drop events."""
        files = event.data.split()
        valid_files = []
        
        for file_path in files:
            # Clean up file path
            file_path = file_path.strip('{}')
            path = Path(file_path)
            
            if path.is_file() and path.suffix.lower() == '.ipynb':
                valid_files.append(path)
            elif path.is_dir():
                # Find all .ipynb files in directory
                notebook_files = list(path.rglob('*.ipynb'))
                valid_files.extend(notebook_files)
        
        if valid_files:
            self.selected_files = valid_files
            self.update_files_display()
            self.log_message(f"Added {len(valid_files)} notebook file(s)")
        else:
            self.log_message("No valid .ipynb files found in dropped items")
    
    def select_files(self):
        """Open file dialog to select notebook files."""
        files = filedialog.askopenfilenames(
            title="Select Jupyter Notebook Files",
            filetypes=[("Jupyter Notebooks", "*.ipynb"), ("All Files", "*.*")]
        )
        
        if files:
            self.selected_files = [Path(f) for f in files]
            self.update_files_display()
            self.log_message(f"Selected {len(files)} file(s)")
    
    def select_folder(self):
        """Open dialog to select folder containing notebooks."""
        folder = filedialog.askdirectory(title="Select Folder Containing Notebooks")
        
        if folder:
            folder_path = Path(folder)
            notebook_files = list(folder_path.rglob('*.ipynb'))
            
            if notebook_files:
                self.selected_files = notebook_files
                self.update_files_display()
                self.log_message(f"Found {len(notebook_files)} notebook(s) in {folder}")
            else:
                messagebox.showwarning("No Notebooks Found", 
                                     f"No .ipynb files found in {folder}")
    
    def select_output_directory(self):
        """Select output directory."""
        directory = filedialog.askdirectory(title="Select Output Directory")
        if directory:
            self.settings['output_directory'].set(directory)
    
    def clear_files(self):
        """Clear selected files."""
        self.selected_files = []
        self.update_files_display()
        self.log_message("Cleared file selection")
    
    def update_files_display(self):
        """Update the display of selected files."""
        if not self.selected_files:
            self.files_var.set("No files selected")
        else:
            file_list = "\n".join([f"• {f.name}" for f in self.selected_files[:10]])
            if len(self.selected_files) > 10:
                file_list += f"\n... and {len(self.selected_files) - 10} more files"
            self.files_var.set(f"Selected {len(self.selected_files)} file(s):\n{file_list}")
    
    def start_conversion(self):
        """Start the conversion process in a separate thread."""
        if not self.selected_files:
            messagebox.showwarning("No Files Selected", 
                                 "Please select some notebook files to convert")
            return
        
        # Disable convert button during conversion
        self.convert_button.config(state='disabled', text='Converting...')
        
        # Start conversion in separate thread
        thread = threading.Thread(target=self.convert_files, daemon=True)
        thread.start()
    
    def convert_files(self):
        """Convert the selected files (runs in separate thread)."""
        try:
            # Create converter with current settings
            converter = NotebookToHTMLConverter(
                embed_images=self.settings['embed_images'].get(),
                include_input=self.settings['include_input'].get(),
                execute_notebook=self.settings['execute_notebook'].get(),
                template=self.settings['template'].get()
            )
            
            output_dir = self.settings['output_directory'].get()
            output_path = Path(output_dir) if output_dir else None
            
            converted_files = []
            errors = []
            
            for file_path in self.selected_files:
                try:
                    self.queue_message(f"Converting: {file_path.name}")
                    
                    if output_path:
                        # Use specified output directory
                        html_file = output_path / f"{file_path.stem}.html"
                        html_file.parent.mkdir(parents=True, exist_ok=True)
                    else:
                        # Save next to original file
                        html_file = None
                    
                    result_path = converter.convert_single_file(file_path, html_file)
                    converted_files.append(result_path)
                    self.queue_message(f"✓ Converted: {result_path.name}")
                    
                except Exception as e:
                    error_msg = f"✗ Error converting {file_path.name}: {str(e)}"
                    errors.append(error_msg)
                    self.queue_message(error_msg)
            
            # Summary
            summary = f"\n=== Conversion Complete ===\n"
            summary += f"Successfully converted: {len(converted_files)} files\n"
            if errors:
                summary += f"Errors: {len(errors)} files\n"
            summary += f"Output location: {output_path or 'Next to original files'}\n"
            
            self.queue_message(summary)
            
        except Exception as e:
            self.queue_message(f"Conversion failed: {str(e)}")
        
        finally:
            # Re-enable convert button
            self.queue_message("ENABLE_BUTTON")
    
    def queue_message(self, message):
        """Queue a message for the main thread."""
        self.message_queue.put(message)
    
    def process_messages(self):
        """Process messages from the conversion thread."""
        try:
            while True:
                message = self.message_queue.get_nowait()
                if message == "ENABLE_BUTTON":
                    self.convert_button.config(state='normal', text='Convert to HTML')
                else:
                    self.log_message(message)
        except queue.Empty:
            pass
        
        # Schedule next check
        self.root.after(100, self.process_messages)
    
    def log_message(self, message):
        """Add a message to the log area."""
        self.output_text.insert(tk.END, f"{message}\n")
        self.output_text.see(tk.END)
        self.root.update_idletasks()
    
    def clear_log(self):
        """Clear the log area."""
        self.output_text.delete(1.0, tk.END)
    
    def open_output_folder(self):
        """Open the output folder in file explorer."""
        output_dir = self.settings['output_directory'].get()
        if output_dir and Path(output_dir).exists():
            os.startfile(output_dir)  # Windows
        elif self.selected_files:
            # Open folder containing the first selected file
            os.startfile(str(self.selected_files[0].parent))
        else:
            messagebox.showinfo("No Output Folder", 
                              "No output folder specified or files selected")


def main():
    """Main application entry point."""
    root = tk.Tk()
    
    # Set up the application
    app = NotebookConverterGUI(root)
    
    # Handle command line arguments (for file associations)
    if len(sys.argv) > 1:
        files = [Path(arg) for arg in sys.argv[1:] if Path(arg).suffix.lower() == '.ipynb']
        if files:
            app.selected_files = files
            app.update_files_display()
            app.log_message(f"Loaded {len(files)} file(s) from command line")
    
    # Start the GUI
    root.mainloop()


if __name__ == "__main__":
    main() 