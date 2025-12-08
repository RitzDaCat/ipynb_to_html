import 'dart:convert';
import 'package:flutter/material.dart';

/// Background style options
enum BackgroundStyle {
  solid('Solid Color'),
  gradient('Gradient'),
  dots('Dot Pattern'),
  grid('Grid Pattern'),
  diagonalLines('Diagonal Lines'),
  noise('Subtle Noise'),
  paper('Paper Texture'),
  blueprint('Blueprint');

  final String displayName;
  const BackgroundStyle(this.displayName);
}

/// Custom theme configuration
class CustomTheme {
  final String name;
  
  // Background
  final Color backgroundColor;
  final Color? backgroundColorSecondary; // For gradients
  final BackgroundStyle backgroundStyle;
  final double patternOpacity;
  
  // Text colors
  final Color textColor;
  final Color headingColor;
  final Color linkColor;
  
  // Code cell colors
  final Color codeCellBackground;
  final Color codeCellBorder;
  final Color executionCountColor;
  final Color outputBackground;
  
  // Syntax highlighting
  final Color syntaxComment;
  final Color syntaxString;
  final Color syntaxKeyword;
  final Color syntaxNumber;
  final Color syntaxFunction;
  final Color syntaxVariable;
  
  // Output colors
  final Color outputText;
  final Color errorBackground;
  final Color errorText;
  final Color warningText;
  
  // Table colors
  final Color tableHeaderBackground;
  final Color tableHeaderText;
  final Color tableBorder;
  final Color tableRowAlt;

  const CustomTheme({
    required this.name,
    this.backgroundColor = const Color(0xFF1a1b26),
    this.backgroundColorSecondary,
    this.backgroundStyle = BackgroundStyle.solid,
    this.patternOpacity = 0.05,
    this.textColor = const Color(0xFFc0caf5),
    this.headingColor = const Color(0xFF7aa2f7),
    this.linkColor = const Color(0xFF7aa2f7),
    this.codeCellBackground = const Color(0xFF1f2335),
    this.codeCellBorder = const Color(0xFF3b4261),
    this.executionCountColor = const Color(0xFF7aa2f7),
    this.outputBackground = const Color(0xFF1a1b26),
    this.syntaxComment = const Color(0xFF565f89),
    this.syntaxString = const Color(0xFF9ece6a),
    this.syntaxKeyword = const Color(0xFFbb9af7),
    this.syntaxNumber = const Color(0xFFff9e64),
    this.syntaxFunction = const Color(0xFF7aa2f7),
    this.syntaxVariable = const Color(0xFFc0caf5),
    this.outputText = const Color(0xFFc0caf5),
    this.errorBackground = const Color(0x26f7768e),
    this.errorText = const Color(0xFFf7768e),
    this.warningText = const Color(0xFFe0af68),
    this.tableHeaderBackground = const Color(0xFF7aa2f7),
    this.tableHeaderText = const Color(0xFF1a1b26),
    this.tableBorder = const Color(0xFF3b4261),
    this.tableRowAlt = const Color(0x0Dffffff),
  });

  CustomTheme copyWith({
    String? name,
    Color? backgroundColor,
    Color? backgroundColorSecondary,
    BackgroundStyle? backgroundStyle,
    double? patternOpacity,
    Color? textColor,
    Color? headingColor,
    Color? linkColor,
    Color? codeCellBackground,
    Color? codeCellBorder,
    Color? executionCountColor,
    Color? outputBackground,
    Color? syntaxComment,
    Color? syntaxString,
    Color? syntaxKeyword,
    Color? syntaxNumber,
    Color? syntaxFunction,
    Color? syntaxVariable,
    Color? outputText,
    Color? errorBackground,
    Color? errorText,
    Color? warningText,
    Color? tableHeaderBackground,
    Color? tableHeaderText,
    Color? tableBorder,
    Color? tableRowAlt,
  }) {
    return CustomTheme(
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundColorSecondary: backgroundColorSecondary ?? this.backgroundColorSecondary,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      patternOpacity: patternOpacity ?? this.patternOpacity,
      textColor: textColor ?? this.textColor,
      headingColor: headingColor ?? this.headingColor,
      linkColor: linkColor ?? this.linkColor,
      codeCellBackground: codeCellBackground ?? this.codeCellBackground,
      codeCellBorder: codeCellBorder ?? this.codeCellBorder,
      executionCountColor: executionCountColor ?? this.executionCountColor,
      outputBackground: outputBackground ?? this.outputBackground,
      syntaxComment: syntaxComment ?? this.syntaxComment,
      syntaxString: syntaxString ?? this.syntaxString,
      syntaxKeyword: syntaxKeyword ?? this.syntaxKeyword,
      syntaxNumber: syntaxNumber ?? this.syntaxNumber,
      syntaxFunction: syntaxFunction ?? this.syntaxFunction,
      syntaxVariable: syntaxVariable ?? this.syntaxVariable,
      outputText: outputText ?? this.outputText,
      errorBackground: errorBackground ?? this.errorBackground,
      errorText: errorText ?? this.errorText,
      warningText: warningText ?? this.warningText,
      tableHeaderBackground: tableHeaderBackground ?? this.tableHeaderBackground,
      tableHeaderText: tableHeaderText ?? this.tableHeaderText,
      tableBorder: tableBorder ?? this.tableBorder,
      tableRowAlt: tableRowAlt ?? this.tableRowAlt,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'backgroundColor': backgroundColor.value,
    'backgroundColorSecondary': backgroundColorSecondary?.value,
    'backgroundStyle': backgroundStyle.name,
    'patternOpacity': patternOpacity,
    'textColor': textColor.value,
    'headingColor': headingColor.value,
    'linkColor': linkColor.value,
    'codeCellBackground': codeCellBackground.value,
    'codeCellBorder': codeCellBorder.value,
    'executionCountColor': executionCountColor.value,
    'outputBackground': outputBackground.value,
    'syntaxComment': syntaxComment.value,
    'syntaxString': syntaxString.value,
    'syntaxKeyword': syntaxKeyword.value,
    'syntaxNumber': syntaxNumber.value,
    'syntaxFunction': syntaxFunction.value,
    'syntaxVariable': syntaxVariable.value,
    'outputText': outputText.value,
    'errorBackground': errorBackground.value,
    'errorText': errorText.value,
    'warningText': warningText.value,
    'tableHeaderBackground': tableHeaderBackground.value,
    'tableHeaderText': tableHeaderText.value,
    'tableBorder': tableBorder.value,
    'tableRowAlt': tableRowAlt.value,
  };

  factory CustomTheme.fromJson(Map<String, dynamic> json) {
    return CustomTheme(
      name: json['name'] as String,
      backgroundColor: Color(json['backgroundColor'] as int),
      backgroundColorSecondary: json['backgroundColorSecondary'] != null 
          ? Color(json['backgroundColorSecondary'] as int) 
          : null,
      backgroundStyle: BackgroundStyle.values.firstWhere(
        (e) => e.name == json['backgroundStyle'],
        orElse: () => BackgroundStyle.solid,
      ),
      patternOpacity: (json['patternOpacity'] as num?)?.toDouble() ?? 0.05,
      textColor: Color(json['textColor'] as int),
      headingColor: Color(json['headingColor'] as int),
      linkColor: Color(json['linkColor'] as int),
      codeCellBackground: Color(json['codeCellBackground'] as int),
      codeCellBorder: Color(json['codeCellBorder'] as int),
      executionCountColor: Color(json['executionCountColor'] as int),
      outputBackground: Color(json['outputBackground'] as int),
      syntaxComment: Color(json['syntaxComment'] as int),
      syntaxString: Color(json['syntaxString'] as int),
      syntaxKeyword: Color(json['syntaxKeyword'] as int),
      syntaxNumber: Color(json['syntaxNumber'] as int),
      syntaxFunction: Color(json['syntaxFunction'] as int),
      syntaxVariable: Color(json['syntaxVariable'] as int),
      outputText: Color(json['outputText'] as int),
      errorBackground: Color(json['errorBackground'] as int),
      errorText: Color(json['errorText'] as int),
      warningText: Color(json['warningText'] as int),
      tableHeaderBackground: Color(json['tableHeaderBackground'] as int),
      tableHeaderText: Color(json['tableHeaderText'] as int),
      tableBorder: Color(json['tableBorder'] as int),
      tableRowAlt: Color(json['tableRowAlt'] as int),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  
  static CustomTheme fromJsonString(String jsonString) => 
      CustomTheme.fromJson(jsonDecode(jsonString));

  /// Generate CSS for this custom theme
  String toCss() {
    final bgStyle = _generateBackgroundCss();
    
    return '''
/* Custom Theme: $name */
body {
  $bgStyle
  color: ${_colorToHex(textColor)};
}

.markdown-content h1, .markdown-content h2, .markdown-content h3,
.markdown-content h4, .markdown-content h5, .markdown-content h6 {
  color: ${_colorToHex(headingColor)};
}

.markdown-content a { color: ${_colorToHex(linkColor)}; }
.markdown-content code { background: ${_colorToHex(codeCellBackground)}; color: ${_colorToHex(textColor)}; }

.code-cell { background: ${_colorToHex(codeCellBackground)}; border: 1px solid ${_colorToHex(codeCellBorder)}; }
.cell-input { border-bottom: 1px solid ${_colorToHex(codeCellBorder)}; }
.execution-count { background: ${_colorToHex(codeCellBackground)}; color: ${_colorToHex(executionCountColor)}; }
.cell-output { background: ${_colorToHex(outputBackground)}; }
.output-count { color: ${_colorToHex(errorText)}; }

.hljs-comment { color: ${_colorToHex(syntaxComment)}; font-style: italic; }
.hljs-string { color: ${_colorToHex(syntaxString)}; }
.hljs-keyword { color: ${_colorToHex(syntaxKeyword)}; }
.hljs-number { color: ${_colorToHex(syntaxNumber)}; }
.hljs-built_in, .hljs-title { color: ${_colorToHex(syntaxFunction)}; }
.hljs-function { color: ${_colorToHex(syntaxFunction)}; }
.hljs-params { color: ${_colorToHex(syntaxVariable)}; }

.output-item pre { color: ${_colorToHex(outputText)}; }
.output-stderr pre { color: ${_colorToHex(warningText)}; }
.output-error { background: ${_colorToHex(errorBackground)}; border-left: 4px solid ${_colorToHex(errorText)}; }
.error-header { color: ${_colorToHex(errorText)}; }

.output-html table th, .dataframe th { background: ${_colorToHex(tableHeaderBackground)}; color: ${_colorToHex(tableHeaderText)}; }
.output-html table td, .dataframe td { border-bottom: 1px solid ${_colorToHex(tableBorder)}; }
.output-html tr:nth-child(even), .dataframe tr:nth-child(even) { background: ${_colorToHex(tableRowAlt)}; }

.markdown-content blockquote { border-left-color: ${_colorToHex(headingColor)}; color: ${_colorToHex(syntaxComment)}; }
.markdown-content table th { background: ${_colorToHex(codeCellBackground)}; }
.markdown-content th, .markdown-content td { border-color: ${_colorToHex(codeCellBorder)}; }
''';
  }

  String _generateBackgroundCss() {
    final bg1 = _colorToHex(backgroundColor);
    final bg2 = backgroundColorSecondary != null 
        ? _colorToHex(backgroundColorSecondary!) 
        : bg1;
    
    switch (backgroundStyle) {
      case BackgroundStyle.solid:
        return 'background: $bg1;';
      
      case BackgroundStyle.gradient:
        return 'background: linear-gradient(135deg, $bg1 0%, $bg2 100%);';
      
      case BackgroundStyle.dots:
        return '''
background-color: $bg1;
background-image: radial-gradient(${_colorToHex(codeCellBorder)} 1px, transparent 1px);
background-size: 20px 20px;
''';
      
      case BackgroundStyle.grid:
        return '''
background-color: $bg1;
background-image: 
  linear-gradient(${_colorToRgba(codeCellBorder, patternOpacity)} 1px, transparent 1px),
  linear-gradient(90deg, ${_colorToRgba(codeCellBorder, patternOpacity)} 1px, transparent 1px);
background-size: 20px 20px;
''';
      
      case BackgroundStyle.diagonalLines:
        return '''
background-color: $bg1;
background-image: repeating-linear-gradient(
  45deg,
  transparent,
  transparent 10px,
  ${_colorToRgba(codeCellBorder, patternOpacity)} 10px,
  ${_colorToRgba(codeCellBorder, patternOpacity)} 11px
);
''';
      
      case BackgroundStyle.noise:
        return '''
background-color: $bg1;
background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='${patternOpacity}'/%3E%3C/svg%3E");
''';
      
      case BackgroundStyle.paper:
        return '''
background-color: $bg1;
background-image: 
  linear-gradient(${_colorToRgba(codeCellBorder, patternOpacity * 0.5)} 1px, transparent 1px),
  linear-gradient(90deg, ${_colorToRgba(codeCellBorder, patternOpacity * 0.5)} 1px, transparent 1px),
  linear-gradient(${_colorToRgba(codeCellBorder, patternOpacity * 0.3)} 1px, transparent 1px),
  linear-gradient(90deg, ${_colorToRgba(codeCellBorder, patternOpacity * 0.3)} 1px, transparent 1px);
background-size: 100px 100px, 100px 100px, 20px 20px, 20px 20px;
''';
      
      case BackgroundStyle.blueprint:
        return '''
background-color: $bg1;
background-image: 
  linear-gradient(${_colorToRgba(headingColor, patternOpacity)} 2px, transparent 2px),
  linear-gradient(90deg, ${_colorToRgba(headingColor, patternOpacity)} 2px, transparent 2px),
  linear-gradient(${_colorToRgba(headingColor, patternOpacity * 0.5)} 1px, transparent 1px),
  linear-gradient(90deg, ${_colorToRgba(headingColor, patternOpacity * 0.5)} 1px, transparent 1px);
background-size: 100px 100px, 100px 100px, 20px 20px, 20px 20px;
''';
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  String _colorToRgba(Color color, double opacity) {
    return 'rgba(${color.red}, ${color.green}, ${color.blue}, $opacity)';
  }
}

/// Preset starter themes for customization
class CustomThemePresets {
  static const oceanBreeze = CustomTheme(
    name: 'Ocean Breeze',
    backgroundColor: Color(0xFF0a1929),
    backgroundColorSecondary: Color(0xFF001e3c),
    backgroundStyle: BackgroundStyle.gradient,
    textColor: Color(0xFFb2bac2),
    headingColor: Color(0xFF5090d3),
    codeCellBackground: Color(0xFF0d2137),
    codeCellBorder: Color(0xFF1e4976),
    executionCountColor: Color(0xFF5090d3),
    syntaxComment: Color(0xFF5c7a99),
    syntaxString: Color(0xFF66bb6a),
    syntaxKeyword: Color(0xFF29b6f6),
    syntaxNumber: Color(0xFFffb74d),
    syntaxFunction: Color(0xFF5090d3),
    tableHeaderBackground: Color(0xFF1e4976),
  );

  static const sunsetWarm = CustomTheme(
    name: 'Sunset Warm',
    backgroundColor: Color(0xFF2d1b2d),
    backgroundColorSecondary: Color(0xFF1a1a2e),
    backgroundStyle: BackgroundStyle.gradient,
    textColor: Color(0xFFe8d5d5),
    headingColor: Color(0xFFf4a261),
    codeCellBackground: Color(0xFF3d2b3d),
    codeCellBorder: Color(0xFF5d4b5d),
    executionCountColor: Color(0xFFf4a261),
    syntaxComment: Color(0xFF8b7b8b),
    syntaxString: Color(0xFFa8e6cf),
    syntaxKeyword: Color(0xFFe76f51),
    syntaxNumber: Color(0xFFf4a261),
    syntaxFunction: Color(0xFF2a9d8f),
    tableHeaderBackground: Color(0xFFe76f51),
  );

  static const mintFresh = CustomTheme(
    name: 'Mint Fresh',
    backgroundColor: Color(0xFFf0fff4),
    textColor: Color(0xFF2d3748),
    headingColor: Color(0xFF276749),
    codeCellBackground: Color(0xFFffffff),
    codeCellBorder: Color(0xFFc6f6d5),
    executionCountColor: Color(0xFF38a169),
    outputBackground: Color(0xFFf0fff4),
    syntaxComment: Color(0xFF718096),
    syntaxString: Color(0xFF276749),
    syntaxKeyword: Color(0xFF9f7aea),
    syntaxNumber: Color(0xFFdd6b20),
    syntaxFunction: Color(0xFF3182ce),
    tableHeaderBackground: Color(0xFF38a169),
    tableHeaderText: Color(0xFFffffff),
  );

  static const cyberpunk = CustomTheme(
    name: 'Cyberpunk',
    backgroundColor: Color(0xFF0d0221),
    backgroundStyle: BackgroundStyle.grid,
    patternOpacity: 0.1,
    textColor: Color(0xFF00ff9f),
    headingColor: Color(0xFFff00ff),
    linkColor: Color(0xFF00ffff),
    codeCellBackground: Color(0xFF1a0a2e),
    codeCellBorder: Color(0xFFff00ff),
    executionCountColor: Color(0xFF00ffff),
    syntaxComment: Color(0xFF6b6b8d),
    syntaxString: Color(0xFF00ff9f),
    syntaxKeyword: Color(0xFFff00ff),
    syntaxNumber: Color(0xFFffff00),
    syntaxFunction: Color(0xFF00ffff),
    errorText: Color(0xFFff3366),
    tableHeaderBackground: Color(0xFFff00ff),
  );

  static List<CustomTheme> get all => [
    oceanBreeze,
    sunsetWarm,
    mintFresh,
    cyberpunk,
  ];
}

