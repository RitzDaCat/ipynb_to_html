import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/notebook.dart';
import '../models/custom_theme.dart';
import 'notebook_converter.dart';

export 'notebook_converter.dart' show HtmlTheme;
export '../models/custom_theme.dart';

/// Represents a file to be converted
class ConversionFile {
  final String path;
  final String name;
  ConversionStatus status;
  String? error;
  String? outputPath;

  ConversionFile({
    required this.path,
    required this.name,
    this.status = ConversionStatus.pending,
    this.error,
    this.outputPath,
  });
}

enum ConversionStatus { pending, converting, completed, failed }

/// State management for the conversion process
class ConversionState extends ChangeNotifier {
  final List<ConversionFile> _files = [];
  bool _isConverting = false;
  String? _outputDirectory;
  
  // Settings
  bool _embedImages = true;
  bool _includeInput = true;
  bool _appendThemeName = true;  // Append theme name to filename for easy comparison
  HtmlTheme _theme = HtmlTheme.tokyoNight;
  bool _useCustomTheme = false;
  CustomTheme? _customTheme;
  List<CustomTheme> _savedCustomThemes = [];

  // Getters
  List<ConversionFile> get files => List.unmodifiable(_files);
  bool get isConverting => _isConverting;
  String? get outputDirectory => _outputDirectory;
  bool get embedImages => _embedImages;
  bool get includeInput => _includeInput;
  bool get appendThemeName => _appendThemeName;
  HtmlTheme get theme => _theme;
  bool get useCustomTheme => _useCustomTheme;
  CustomTheme? get customTheme => _customTheme;
  List<CustomTheme> get savedCustomThemes => List.unmodifiable(_savedCustomThemes);
  
  int get pendingCount => _files.where((f) => f.status == ConversionStatus.pending).length;
  int get completedCount => _files.where((f) => f.status == ConversionStatus.completed).length;
  int get failedCount => _files.where((f) => f.status == ConversionStatus.failed).length;
  bool get hasFiles => _files.isNotEmpty;

  /// Add files to conversion queue
  void addFiles(List<String> paths) {
    for (final path in paths) {
      // Check if it's a .ipynb file
      if (path.toLowerCase().endsWith('.ipynb')) {
        // Avoid duplicates
        if (!_files.any((f) => f.path == path)) {
          _files.add(ConversionFile(
            path: path,
            name: p.basename(path),
          ));
        }
      } else if (FileSystemEntity.isDirectorySync(path)) {
        // Recursively find .ipynb files in directory
        _addFilesFromDirectory(path);
      }
    }
    notifyListeners();
  }

  void _addFilesFromDirectory(String dirPath) {
    try {
      final dir = Directory(dirPath);
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.ipynb')) {
          if (!_files.any((f) => f.path == entity.path)) {
            _files.add(ConversionFile(
              path: entity.path,
              name: p.basename(entity.path),
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning directory: $e');
    }
  }

  /// Remove a file from the queue
  void removeFile(ConversionFile file) {
    _files.remove(file);
    notifyListeners();
  }

  /// Clear all files
  void clearFiles() {
    _files.clear();
    notifyListeners();
  }

  /// Set output directory
  void setOutputDirectory(String? path) {
    _outputDirectory = path;
    notifyListeners();
  }

  /// Update settings
  void setEmbedImages(bool value) {
    _embedImages = value;
    notifyListeners();
  }

  void setIncludeInput(bool value) {
    _includeInput = value;
    notifyListeners();
  }

  void setTheme(HtmlTheme value) {
    _theme = value;
    notifyListeners();
  }

  void setAppendThemeName(bool value) {
    _appendThemeName = value;
    notifyListeners();
  }

  void setUseCustomTheme(bool value) {
    _useCustomTheme = value;
    notifyListeners();
  }

  void setCustomTheme(CustomTheme? theme) {
    _customTheme = theme;
    if (theme != null) {
      _useCustomTheme = true;
    }
    notifyListeners();
  }

  Future<void> saveCustomTheme(CustomTheme theme) async {
    // Remove existing theme with same name
    _savedCustomThemes.removeWhere((t) => t.name == theme.name);
    _savedCustomThemes.add(theme);
    _customTheme = theme;
    _useCustomTheme = true;
    await _persistCustomThemes();
    notifyListeners();
  }

  Future<void> deleteCustomTheme(CustomTheme theme) async {
    _savedCustomThemes.removeWhere((t) => t.name == theme.name);
    if (_customTheme?.name == theme.name) {
      _customTheme = _savedCustomThemes.isNotEmpty ? _savedCustomThemes.first : null;
      if (_customTheme == null) {
        _useCustomTheme = false;
      }
    }
    await _persistCustomThemes();
    notifyListeners();
  }

  Future<void> loadCustomThemes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/notebook_converter_themes.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _savedCustomThemes = jsonList
            .map((json) => CustomTheme.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading custom themes: $e');
    }
  }

  Future<void> _persistCustomThemes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/notebook_converter_themes.json');
      final jsonList = _savedCustomThemes.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving custom themes: $e');
    }
  }

  /// Start conversion process
  Future<void> convertAll() async {
    if (_isConverting || _files.isEmpty) return;
    
    _isConverting = true;
    notifyListeners();

    final converter = NotebookConverter(
      settings: ConversionSettings(
        embedImages: _embedImages,
        includeInput: _includeInput,
        theme: _theme,
        customTheme: _useCustomTheme ? _customTheme : null,
      ),
    );

    for (final file in _files) {
      // Always allow conversion (don't skip completed - user may want different theme)
      file.status = ConversionStatus.converting;
      file.error = null;
      notifyListeners();

      try {
        // Read the notebook file
        final content = await File(file.path).readAsString();
        
        // Parse and convert
        final notebook = converter.parseNotebook(content);
        final html = converter.convertToHtml(
          notebook,
          title: p.basenameWithoutExtension(file.path),
        );

        // Determine output path
        final outputDir = _outputDirectory ?? p.dirname(file.path);
        final baseName = p.basenameWithoutExtension(file.path);
        final themeName = _useCustomTheme && _customTheme != null 
            ? _customTheme!.name.replaceAll(' ', '_')
            : _theme.name;
        final outputName = _appendThemeName 
            ? '${baseName}_$themeName.html'
            : '$baseName.html';
        final outputPath = p.join(outputDir, outputName);

        // Ensure output directory exists
        await Directory(outputDir).create(recursive: true);

        // Write HTML file
        await File(outputPath).writeAsString(html);

        file.status = ConversionStatus.completed;
        file.outputPath = outputPath;
      } catch (e) {
        file.status = ConversionStatus.failed;
        file.error = e.toString();
        debugPrint('Conversion error for ${file.name}: $e');
      }

      notifyListeners();
    }

    _isConverting = false;
    notifyListeners();
  }

  /// Reset failed files to pending
  void retryFailed() {
    for (final file in _files) {
      if (file.status == ConversionStatus.failed) {
        file.status = ConversionStatus.pending;
        file.error = null;
      }
    }
    notifyListeners();
  }

  /// Reset all files to pending (for re-conversion with different theme)
  void resetAllForReconversion() {
    for (final file in _files) {
      file.status = ConversionStatus.pending;
      file.error = null;
      file.outputPath = null;
    }
    notifyListeners();
  }
}

