#!/usr/bin/env python3
"""
Jupyter Notebook to HTML Converter - Qt GUI Version
A Qt-based GUI application for converting notebooks to HTML.
"""

import sys
import os
from pathlib import Path
from typing import List, Optional
import threading
import queue

try:
	from PyQt6.QtWidgets import (
		QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
		QPushButton, QLabel, QTextEdit, QFileDialog, QCheckBox,
		QComboBox, QGroupBox, QProgressBar, QMessageBox
	)
	from PyQt6.QtCore import Qt, QThread, pyqtSignal
except ImportError:
	print("PyQt6 not available, trying PyQt5...")
	try:
		from PyQt5.QtWidgets import (
			QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
			QPushButton, QLabel, QTextEdit, QFileDialog, QCheckBox,
			QComboBox, QGroupBox, QProgressBar, QMessageBox
		)
		from PyQt5.QtCore import Qt, QThread, pyqtSignal
	except ImportError:
		print("Error: Neither PyQt6 nor PyQt5 is installed")
		print("Install with: pip install PyQt6 or pip install PyQt5")
		sys.exit(1)

# Import our converter
try:
	from ipynb_to_html import NotebookToHTMLConverter
except ImportError:
	print("Error: Could not import ipynb_to_html module")
	sys.exit(1)


class ConversionThread(QThread):
	"""Thread for running conversions without blocking UI."""
	
	progress = pyqtSignal(str)
	finished = pyqtSignal(bool, str)
	
	def __init__(self, files, settings):
		super().__init__()
		self.files = files
		self.settings = settings
	
	def run(self):
		"""Run the conversion process."""
		try:
			converter = NotebookToHTMLConverter(
				embed_images=self.settings['embed_images'],
				include_input=self.settings['include_input'],
				execute_notebook=self.settings['execute_notebook'],
				template=self.settings['template']
			)
			
			total_files = len(self.files)
			converted = 0
			failed = []
			
			for i, file_path in enumerate(self.files, 1):
				self.progress.emit(f"Converting {i}/{total_files}: {Path(file_path).name}")
				
				try:
					# Generate output filename
					input_path = Path(file_path)
					output_dir = self.settings.get('output_directory')
					
					if output_dir:
						output_path = Path(output_dir) / f"{input_path.stem}.html"
					else:
						output_path = input_path.with_suffix('.html')
					
					# Convert the file
					converter.convert_single_file(str(input_path), str(output_path))
					converted += 1
					self.progress.emit(f"✓ Converted: {input_path.name}")
					
				except Exception as e:
					failed.append((file_path, str(e)))
					self.progress.emit(f"✗ Failed: {Path(file_path).name} - {str(e)}")
			
			# Report results
			if failed:
				msg = f"Converted {converted}/{total_files} files.\n"
				msg += f"Failed files:\n"
				for path, error in failed:
					msg += f"  - {Path(path).name}: {error}\n"
				self.finished.emit(False, msg)
			else:
				self.finished.emit(True, f"Successfully converted {converted} file(s)")
				
		except Exception as e:
			self.finished.emit(False, f"Conversion error: {str(e)}")


class NotebookConverterQt(QMainWindow):
	"""Qt GUI application for converting Jupyter notebooks to HTML."""
	
	def __init__(self):
		super().__init__()
		self.selected_files = []
		self.conversion_thread = None
		self.init_ui()
	
	def init_ui(self):
		"""Initialize the user interface."""
		self.setWindowTitle("Jupyter Notebook to HTML Converter")
		self.setGeometry(100, 100, 800, 600)
		
		# Central widget and layout
		central_widget = QWidget()
		self.setCentralWidget(central_widget)
		layout = QVBoxLayout(central_widget)
		
		# Title
		title = QLabel("Jupyter Notebook to HTML Converter")
		title.setAlignment(Qt.AlignmentFlag.AlignCenter)
		title.setStyleSheet("font-size: 18px; font-weight: bold; padding: 10px;")
		layout.addWidget(title)
		
		# File selection area
		self.setup_file_selection(layout)
		
		# Settings area
		self.setup_settings(layout)
		
		# Output area
		self.setup_output_area(layout)
		
		# Buttons
		self.setup_buttons(layout)
	
	def setup_file_selection(self, parent_layout):
		"""Set up file selection area."""
		group = QGroupBox("Select Files")
		layout = QVBoxLayout(group)
		
		# Instructions
		instructions = QLabel(
			"Select .ipynb files to convert to HTML\n"
			"• Single files will be converted to HTML\n"
			"• Multiple files will be batch converted\n"
			"• Folders will be processed recursively"
		)
		layout.addWidget(instructions)
		
		# Buttons
		button_layout = QHBoxLayout()
		
		self.select_files_btn = QPushButton("Select File(s)")
		self.select_files_btn.clicked.connect(self.select_files)
		button_layout.addWidget(self.select_files_btn)
		
		self.select_folder_btn = QPushButton("Select Folder")
		self.select_folder_btn.clicked.connect(self.select_folder)
		button_layout.addWidget(self.select_folder_btn)
		
		self.clear_btn = QPushButton("Clear Selection")
		self.clear_btn.clicked.connect(self.clear_selection)
		button_layout.addWidget(self.clear_btn)
		
		layout.addLayout(button_layout)
		
		# Selected files label
		self.selected_label = QLabel("No files selected")
		layout.addWidget(self.selected_label)
		
		parent_layout.addWidget(group)
	
	def setup_settings(self, parent_layout):
		"""Set up settings area."""
		group = QGroupBox("Settings")
		layout = QVBoxLayout(group)
		
		# Template selection
		template_layout = QHBoxLayout()
		template_layout.addWidget(QLabel("Template:"))
		self.template_combo = QComboBox()
		self.template_combo.addItems(["classic", "lab", "reveal"])
		template_layout.addWidget(self.template_combo)
		template_layout.addStretch()
		layout.addLayout(template_layout)
		
		# Checkboxes
		self.embed_images_check = QCheckBox("Embed images in HTML (recommended)")
		self.embed_images_check.setChecked(True)
		layout.addWidget(self.embed_images_check)
		
		self.include_input_check = QCheckBox("Include code cells")
		self.include_input_check.setChecked(True)
		layout.addWidget(self.include_input_check)
		
		self.execute_check = QCheckBox("Execute notebook before conversion")
		layout.addWidget(self.execute_check)
		
		# Output directory
		output_layout = QHBoxLayout()
		output_layout.addWidget(QLabel("Output:"))
		self.output_label = QLabel("Same as input")
		output_layout.addWidget(self.output_label)
		self.output_btn = QPushButton("Choose...")
		self.output_btn.clicked.connect(self.select_output_dir)
		output_layout.addWidget(self.output_btn)
		layout.addLayout(output_layout)
		
		parent_layout.addWidget(group)
	
	def setup_output_area(self, parent_layout):
		"""Set up output/log area."""
		group = QGroupBox("Output")
		layout = QVBoxLayout(group)
		
		self.output_text = QTextEdit()
		self.output_text.setReadOnly(True)
		layout.addWidget(self.output_text)
		
		self.progress_bar = QProgressBar()
		self.progress_bar.setVisible(False)
		layout.addWidget(self.progress_bar)
		
		parent_layout.addWidget(group)
	
	def setup_buttons(self, parent_layout):
		"""Set up action buttons."""
		button_layout = QHBoxLayout()
		
		self.convert_btn = QPushButton("Convert to HTML")
		self.convert_btn.clicked.connect(self.start_conversion)
		self.convert_btn.setEnabled(False)
		self.convert_btn.setStyleSheet("font-weight: bold; padding: 5px;")
		button_layout.addWidget(self.convert_btn)
		
		button_layout.addStretch()
		
		self.exit_btn = QPushButton("Exit")
		self.exit_btn.clicked.connect(self.close)
		button_layout.addWidget(self.exit_btn)
		
		parent_layout.addLayout(button_layout)
	
	def select_files(self):
		"""Select notebook files."""
		files, _ = QFileDialog.getOpenFileNames(
			self,
			"Select Notebook Files",
			"",
			"Jupyter Notebooks (*.ipynb);;All Files (*.*)"
		)
		
		if files:
			self.selected_files = files
			self.update_selection_label()
			self.convert_btn.setEnabled(True)
			self.log(f"Selected {len(files)} file(s)")
	
	def select_folder(self):
		"""Select a folder containing notebooks."""
		folder = QFileDialog.getExistingDirectory(self, "Select Folder")
		
		if folder:
			# Find all .ipynb files
			path = Path(folder)
			files = list(path.rglob("*.ipynb"))
			
			if files:
				self.selected_files = [str(f) for f in files]
				self.update_selection_label()
				self.convert_btn.setEnabled(True)
				self.log(f"Found {len(files)} notebook(s) in folder")
			else:
				self.log("No notebook files found in selected folder")
	
	def select_output_dir(self):
		"""Select output directory."""
		folder = QFileDialog.getExistingDirectory(self, "Select Output Directory")
		if folder:
			self.output_label.setText(folder)
			self.log(f"Output directory: {folder}")
	
	def clear_selection(self):
		"""Clear file selection."""
		self.selected_files = []
		self.update_selection_label()
		self.convert_btn.setEnabled(False)
		self.log("Selection cleared")
	
	def update_selection_label(self):
		"""Update the selection label."""
		if not self.selected_files:
			self.selected_label.setText("No files selected")
		elif len(self.selected_files) == 1:
			self.selected_label.setText(f"1 file selected: {Path(self.selected_files[0]).name}")
		else:
			self.selected_label.setText(f"{len(self.selected_files)} files selected")
	
	def log(self, message):
		"""Add message to output log."""
		self.output_text.append(message)
	
	def start_conversion(self):
		"""Start the conversion process."""
		if not self.selected_files:
			QMessageBox.warning(self, "No Files", "Please select files to convert")
			return
		
		# Disable controls during conversion
		self.convert_btn.setEnabled(False)
		self.select_files_btn.setEnabled(False)
		self.select_folder_btn.setEnabled(False)
		self.progress_bar.setVisible(True)
		
		# Gather settings
		settings = {
			'embed_images': self.embed_images_check.isChecked(),
			'include_input': self.include_input_check.isChecked(),
			'execute_notebook': self.execute_check.isChecked(),
			'template': self.template_combo.currentText(),
			'output_directory': self.output_label.text() if self.output_label.text() != "Same as input" else None
		}
		
		# Start conversion thread
		self.conversion_thread = ConversionThread(self.selected_files, settings)
		self.conversion_thread.progress.connect(self.log)
		self.conversion_thread.finished.connect(self.conversion_finished)
		self.conversion_thread.start()
		
		self.log("\n" + "=" * 50)
		self.log("Starting conversion...")
	
	def conversion_finished(self, success, message):
		"""Handle conversion completion."""
		self.log(message)
		self.log("=" * 50)
		
		# Re-enable controls
		self.convert_btn.setEnabled(True)
		self.select_files_btn.setEnabled(True)
		self.select_folder_btn.setEnabled(True)
		self.progress_bar.setVisible(False)
		
		# Show completion message
		if success:
			QMessageBox.information(self, "Success", message)
		else:
			QMessageBox.warning(self, "Partial Success", message)


def main():
	"""Main entry point."""
	app = QApplication(sys.argv)
	
	# Set application style for better cross-platform appearance
	app.setStyle('Fusion')
	
	# Create and show main window
	window = NotebookConverterQt()
	window.show()
	
	sys.exit(app.exec())


if __name__ == "__main__":
	main()