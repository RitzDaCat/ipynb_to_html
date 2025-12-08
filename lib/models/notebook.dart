/// Data models for Jupyter Notebook structure
/// .ipynb files are JSON with a specific schema

class Notebook {
  final int nbformatMajor;
  final int nbformatMinor;
  final NotebookMetadata metadata;
  final List<Cell> cells;

  Notebook({
    required this.nbformatMajor,
    required this.nbformatMinor,
    required this.metadata,
    required this.cells,
  });

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      nbformatMajor: json['nbformat'] ?? 4,
      nbformatMinor: json['nbformat_minor'] ?? 0,
      metadata: NotebookMetadata.fromJson(json['metadata'] ?? {}),
      cells: (json['cells'] as List<dynamic>?)
              ?.map((c) => Cell.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'nbformat': nbformatMajor,
        'nbformat_minor': nbformatMinor,
        'metadata': metadata.toJson(),
        'cells': cells.map((c) => c.toJson()).toList(),
      };
}

class NotebookMetadata {
  final String? kernelName;
  final String? languageName;
  final String? languageVersion;
  final Map<String, dynamic> raw;

  NotebookMetadata({
    this.kernelName,
    this.languageName,
    this.languageVersion,
    required this.raw,
  });

  factory NotebookMetadata.fromJson(Map<String, dynamic> json) {
    final kernelspec = json['kernelspec'] as Map<String, dynamic>?;
    final languageInfo = json['language_info'] as Map<String, dynamic>?;

    return NotebookMetadata(
      kernelName: kernelspec?['name'] ?? kernelspec?['display_name'],
      languageName: languageInfo?['name'],
      languageVersion: languageInfo?['version'],
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw;
}

enum CellType { code, markdown, raw }

class Cell {
  final CellType cellType;
  final List<String> source;
  final Map<String, dynamic> metadata;
  final List<CellOutput>? outputs;
  final int? executionCount;

  Cell({
    required this.cellType,
    required this.source,
    required this.metadata,
    this.outputs,
    this.executionCount,
  });

  String get sourceText => source.join();

  factory Cell.fromJson(Map<String, dynamic> json) {
    final typeStr = json['cell_type'] as String? ?? 'code';
    final CellType cellType;
    switch (typeStr) {
      case 'markdown':
        cellType = CellType.markdown;
        break;
      case 'raw':
        cellType = CellType.raw;
        break;
      default:
        cellType = CellType.code;
    }

    // Source can be a string or list of strings
    final sourceRaw = json['source'];
    final List<String> source;
    if (sourceRaw is String) {
      source = [sourceRaw];
    } else if (sourceRaw is List) {
      source = sourceRaw.map((e) => e.toString()).toList();
    } else {
      source = [];
    }

    return Cell(
      cellType: cellType,
      source: source,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      outputs: cellType == CellType.code
          ? (json['outputs'] as List<dynamic>?)
                  ?.map((o) => CellOutput.fromJson(o))
                  .toList() ??
              []
          : null,
      executionCount: json['execution_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'cell_type': cellType.name,
        'source': source,
        'metadata': metadata,
        if (outputs != null) 'outputs': outputs!.map((o) => o.toJson()).toList(),
        if (executionCount != null) 'execution_count': executionCount,
      };
}

enum OutputType { stream, displayData, executeResult, error }

class CellOutput {
  final OutputType outputType;
  final String? name; // For stream: stdout/stderr
  final String? text; // For stream output
  final Map<String, dynamic>? data; // For display_data/execute_result
  final Map<String, dynamic>? metadata;
  final int? executionCount;
  
  // For error output
  final String? ename;
  final String? evalue;
  final List<String>? traceback;

  CellOutput({
    required this.outputType,
    this.name,
    this.text,
    this.data,
    this.metadata,
    this.executionCount,
    this.ename,
    this.evalue,
    this.traceback,
  });

  factory CellOutput.fromJson(Map<String, dynamic> json) {
    final typeStr = json['output_type'] as String? ?? '';
    final OutputType outputType;
    
    switch (typeStr) {
      case 'stream':
        outputType = OutputType.stream;
        break;
      case 'display_data':
        outputType = OutputType.displayData;
        break;
      case 'execute_result':
        outputType = OutputType.executeResult;
        break;
      case 'error':
        outputType = OutputType.error;
        break;
      default:
        outputType = OutputType.stream;
    }

    // Text can be string or list
    String? text;
    final textRaw = json['text'];
    if (textRaw is String) {
      text = textRaw;
    } else if (textRaw is List) {
      text = textRaw.join();
    }

    // Traceback is a list of strings
    List<String>? traceback;
    final tbRaw = json['traceback'];
    if (tbRaw is List) {
      traceback = tbRaw.map((e) => e.toString()).toList();
    }

    return CellOutput(
      outputType: outputType,
      name: json['name'] as String?,
      text: text,
      data: json['data'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      executionCount: json['execution_count'] as int?,
      ename: json['ename'] as String?,
      evalue: json['evalue'] as String?,
      traceback: traceback,
    );
  }

  Map<String, dynamic> toJson() => {
        'output_type': outputType.name,
        if (name != null) 'name': name,
        if (text != null) 'text': text,
        if (data != null) 'data': data,
        if (metadata != null) 'metadata': metadata,
        if (executionCount != null) 'execution_count': executionCount,
        if (ename != null) 'ename': ename,
        if (evalue != null) 'evalue': evalue,
        if (traceback != null) 'traceback': traceback,
      };

  /// Get the best text representation from data
  String? getTextContent() {
    if (text != null) return text;
    if (data == null) return null;

    // Priority order for text content
    if (data!.containsKey('text/plain')) {
      final val = data!['text/plain'];
      return val is List ? val.join() : val.toString();
    }
    return null;
  }

  /// Get HTML content if available
  String? getHtmlContent() {
    if (data == null) return null;
    if (data!.containsKey('text/html')) {
      final val = data!['text/html'];
      return val is List ? val.join() : val.toString();
    }
    return null;
  }

  /// Get image data (base64) if available
  /// Returns map with mime type as key
  Map<String, String> getImageData() {
    final images = <String, String>{};
    if (data == null) return images;

    for (final mimeType in ['image/png', 'image/jpeg', 'image/svg+xml', 'image/gif']) {
      if (data!.containsKey(mimeType)) {
        final val = data![mimeType];
        images[mimeType] = val is List ? val.join() : val.toString();
      }
    }
    return images;
  }
}

