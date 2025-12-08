import 'dart:convert';
import 'package:markdown/markdown.dart' as md;
import 'package:highlight/highlight.dart' show highlight;
import 'package:highlight/languages/python.dart' as python_lang;
import 'package:highlight/languages/javascript.dart' as js_lang;
import 'package:highlight/languages/sql.dart' as sql_lang;
import 'package:highlight/languages/bash.dart' as bash_lang;
import 'package:highlight/languages/json.dart' as json_lang;
import '../models/notebook.dart';
import '../models/custom_theme.dart';

/// Available themes for HTML output
enum HtmlTheme {
  tokyoNight('Tokyo Night', true),
  githubLight('GitHub Light', false),
  dracula('Dracula', true),
  nord('Nord', true),
  solarizedLight('Solarized Light', false),
  monokai('Monokai', true),
  oneDark('One Dark', true),
  catppuccin('Catppuccin Mocha', true),
  gruvboxDark('Gruvbox Dark', true),
  paperLight('Paper Light', false);

  final String displayName;
  final bool isDark;
  const HtmlTheme(this.displayName, this.isDark);
}

/// Settings for notebook conversion
class ConversionSettings {
  final bool embedImages;
  final bool includeInput;
  final HtmlTheme theme;
  final CustomTheme? customTheme;  // If set, use this instead of preset theme
  final String? customCss;

  const ConversionSettings({
    this.embedImages = true,
    this.includeInput = true,
    this.theme = HtmlTheme.tokyoNight,
    this.customTheme,
    this.customCss,
  });
}

/// Pure Dart notebook to HTML converter
class NotebookConverter {
  final ConversionSettings settings;

  NotebookConverter({this.settings = const ConversionSettings()});

  /// Parse notebook JSON string into Notebook object
  Notebook parseNotebook(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Notebook.fromJson(json);
  }

  /// Convert notebook to HTML
  String convertToHtml(Notebook notebook, {String? title}) {
    final buffer = StringBuffer();
    
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('  <title>${_escapeHtml(title ?? 'Jupyter Notebook')}</title>');
    buffer.writeln(_getStyles());
    // Add custom theme CSS if provided
    if (settings.customTheme != null) {
      buffer.writeln('<style>');
      buffer.writeln(settings.customTheme!.toCss());
      buffer.writeln('</style>');
    }
    buffer.writeln('</head>');
    final themeClass = settings.customTheme != null ? 'theme-custom' : 'theme-${settings.theme.name}';
    buffer.writeln('<body class="$themeClass">');
    buffer.writeln('  <div class="notebook-container">');
    
    for (var i = 0; i < notebook.cells.length; i++) {
      final cell = notebook.cells[i];
      buffer.writeln(_convertCell(cell, i));
    }
    
    buffer.writeln('  </div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');
    
    return buffer.toString();
  }

  String _convertCell(Cell cell, int index) {
    switch (cell.cellType) {
      case CellType.markdown:
        return _convertMarkdownCell(cell, index);
      case CellType.code:
        return _convertCodeCell(cell, index);
      case CellType.raw:
        return _convertRawCell(cell, index);
    }
  }

  String _convertMarkdownCell(Cell cell, int index) {
    final html = md.markdownToHtml(
      cell.sourceText,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );
    
    return '''
    <div class="cell markdown-cell" data-cell-index="$index">
      <div class="cell-content markdown-content">
        $html
      </div>
    </div>
    ''';
  }

  String _convertCodeCell(Cell cell, int index) {
    final buffer = StringBuffer();
    
    buffer.writeln('<div class="cell code-cell" data-cell-index="$index">');
    
    if (settings.includeInput) {
      final executionNum = cell.executionCount?.toString() ?? ' ';
      final highlightedCode = _highlightCode(cell.sourceText, 'python');
      
      buffer.writeln('  <div class="cell-input">');
      buffer.writeln('    <div class="execution-count">In [$executionNum]:</div>');
      buffer.writeln('    <div class="code-content">');
      buffer.writeln('      <pre><code class="language-python">$highlightedCode</code></pre>');
      buffer.writeln('    </div>');
      buffer.writeln('  </div>');
    }
    
    if (cell.outputs != null && cell.outputs!.isNotEmpty) {
      buffer.writeln('  <div class="cell-output">');
      
      for (final output in cell.outputs!) {
        buffer.writeln(_convertOutput(output, cell.executionCount));
      }
      
      buffer.writeln('  </div>');
    }
    
    buffer.writeln('</div>');
    return buffer.toString();
  }

  String _convertRawCell(Cell cell, int index) {
    return '''
    <div class="cell raw-cell" data-cell-index="$index">
      <div class="cell-content raw-content">
        <pre>${_escapeHtml(cell.sourceText)}</pre>
      </div>
    </div>
    ''';
  }

  String _convertOutput(CellOutput output, int? executionCount) {
    switch (output.outputType) {
      case OutputType.stream:
        return _convertStreamOutput(output);
      case OutputType.displayData:
      case OutputType.executeResult:
        return _convertDisplayOutput(output, executionCount);
      case OutputType.error:
        return _convertErrorOutput(output);
    }
  }

  String _convertStreamOutput(CellOutput output) {
    final isError = output.name == 'stderr';
    final cssClass = isError ? 'output-stderr' : 'output-stdout';
    
    return '''
    <div class="output-item $cssClass">
      <pre>${_escapeHtml(output.text ?? '')}</pre>
    </div>
    ''';
  }

  String _convertDisplayOutput(CellOutput output, int? executionCount) {
    final buffer = StringBuffer();
    
    if (output.outputType == OutputType.executeResult && executionCount != null) {
      buffer.writeln('<div class="execution-count output-count">Out [$executionCount]:</div>');
    }
    
    final images = output.getImageData();
    if (images.isNotEmpty) {
      for (final entry in images.entries) {
        final mimeType = entry.key;
        final data = entry.value.trim();
        
        if (mimeType == 'image/svg+xml') {
          buffer.writeln('<div class="output-item output-image">');
          buffer.writeln(data);
          buffer.writeln('</div>');
        } else {
          buffer.writeln('<div class="output-item output-image">');
          buffer.writeln('  <img src="data:$mimeType;base64,$data" alt="Output">');
          buffer.writeln('</div>');
        }
      }
      return buffer.toString();
    }
    
    final htmlContent = output.getHtmlContent();
    if (htmlContent != null) {
      buffer.writeln('<div class="output-item output-html">');
      buffer.writeln(htmlContent);
      buffer.writeln('</div>');
      return buffer.toString();
    }
    
    final textContent = output.getTextContent();
    if (textContent != null) {
      buffer.writeln('<div class="output-item output-text">');
      buffer.writeln('<pre>${_escapeHtml(textContent)}</pre>');
      buffer.writeln('</div>');
      return buffer.toString();
    }
    
    return buffer.toString();
  }

  String _convertErrorOutput(CellOutput output) {
    final buffer = StringBuffer();
    
    buffer.writeln('<div class="output-item output-error">');
    buffer.writeln('  <div class="error-header">${_escapeHtml(output.ename ?? 'Error')}: ${_escapeHtml(output.evalue ?? '')}</div>');
    
    if (output.traceback != null && output.traceback!.isNotEmpty) {
      buffer.writeln('  <pre class="error-traceback">');
      for (final line in output.traceback!) {
        buffer.writeln(_stripAnsi(_escapeHtml(line)));
      }
      buffer.writeln('  </pre>');
    }
    
    buffer.writeln('</div>');
    return buffer.toString();
  }

  String _highlightCode(String code, String language) {
    try {
      highlight.registerLanguage('python', python_lang.python);
      highlight.registerLanguage('javascript', js_lang.javascript);
      highlight.registerLanguage('sql', sql_lang.sql);
      highlight.registerLanguage('bash', bash_lang.bash);
      highlight.registerLanguage('json', json_lang.json);
      
      final result = highlight.parse(code, language: language);
      return result.toHtml();
    } catch (e) {
      return _escapeHtml(code);
    }
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _stripAnsi(String text) {
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');
  }

  String _getStyles() {
    return '''
<style>
/* ========== BASE STYLES ========== */
* { box-sizing: border-box; }

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  line-height: 1.6;
  margin: 0;
  padding: 0;
}

.notebook-container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}

.cell {
  margin-bottom: 1.5rem;
  border-radius: 8px;
  overflow: hidden;
}

/* ========== TOKYO NIGHT ========== */
.theme-tokyoNight {
  background: #1a1b26;
  color: #c0caf5;
}
.theme-tokyoNight .code-cell { background: #1f2335; border: 1px solid #3b4261; }
.theme-tokyoNight .cell-input { border-bottom: 1px solid #3b4261; }
.theme-tokyoNight .execution-count { background: #24283b; color: #7aa2f7; }
.theme-tokyoNight .cell-output { background: #1a1b26; }
.theme-tokyoNight .output-count { color: #f7768e; }
.theme-tokyoNight .markdown-content h1, .theme-tokyoNight .markdown-content h2,
.theme-tokyoNight .markdown-content h3 { color: #7aa2f7; }
.theme-tokyoNight .markdown-content code { background: #24283b; color: #c0caf5; }
.theme-tokyoNight .markdown-content blockquote { border-left-color: #7aa2f7; color: #9aa5ce; }
.theme-tokyoNight .hljs-comment { color: #565f89; font-style: italic; }
.theme-tokyoNight .hljs-string { color: #9ece6a; }
.theme-tokyoNight .hljs-keyword { color: #bb9af7; }
.theme-tokyoNight .hljs-number { color: #ff9e64; }
.theme-tokyoNight .hljs-built_in, .theme-tokyoNight .hljs-title { color: #7aa2f7; }
.theme-tokyoNight .hljs-function { color: #7aa2f7; }
.theme-tokyoNight .output-error { background: rgba(247,118,142,0.15); border-left: 4px solid #f7768e; }
.theme-tokyoNight .error-header { color: #f7768e; }
.theme-tokyoNight .output-stderr pre { color: #e0af68; }
.theme-tokyoNight table th { background: #7aa2f7; color: #1a1b26; }
.theme-tokyoNight table td { border-bottom: 1px solid #3b4261; }

/* ========== GITHUB LIGHT ========== */
.theme-githubLight {
  background: #ffffff;
  color: #24292f;
}
.theme-githubLight .code-cell { background: #f6f8fa; border: 1px solid #d0d7de; }
.theme-githubLight .cell-input { border-bottom: 1px solid #d0d7de; }
.theme-githubLight .execution-count { background: #eaeef2; color: #0969da; }
.theme-githubLight .cell-output { background: #ffffff; }
.theme-githubLight .output-count { color: #cf222e; }
.theme-githubLight .markdown-content h1, .theme-githubLight .markdown-content h2,
.theme-githubLight .markdown-content h3 { color: #24292f; border-bottom-color: #d0d7de; }
.theme-githubLight .markdown-content code { background: #f6f8fa; color: #24292f; }
.theme-githubLight .markdown-content blockquote { border-left-color: #0969da; color: #57606a; }
.theme-githubLight .hljs-comment { color: #6e7781; font-style: italic; }
.theme-githubLight .hljs-string { color: #0a3069; }
.theme-githubLight .hljs-keyword { color: #cf222e; }
.theme-githubLight .hljs-number { color: #0550ae; }
.theme-githubLight .hljs-built_in, .theme-githubLight .hljs-title { color: #8250df; }
.theme-githubLight .hljs-function { color: #8250df; }
.theme-githubLight .output-error { background: #ffebe9; border-left: 4px solid #cf222e; }
.theme-githubLight .error-header { color: #cf222e; }
.theme-githubLight .output-stderr pre { color: #9a6700; }
.theme-githubLight table th { background: #0969da; color: #ffffff; }
.theme-githubLight table td { border-bottom: 1px solid #d0d7de; }

/* ========== DRACULA ========== */
.theme-dracula {
  background: #282a36;
  color: #f8f8f2;
}
.theme-dracula .code-cell { background: #21222c; border: 1px solid #44475a; }
.theme-dracula .cell-input { border-bottom: 1px solid #44475a; }
.theme-dracula .execution-count { background: #343746; color: #bd93f9; }
.theme-dracula .cell-output { background: #282a36; }
.theme-dracula .output-count { color: #ff79c6; }
.theme-dracula .markdown-content h1, .theme-dracula .markdown-content h2,
.theme-dracula .markdown-content h3 { color: #bd93f9; }
.theme-dracula .markdown-content code { background: #343746; color: #f8f8f2; }
.theme-dracula .markdown-content blockquote { border-left-color: #bd93f9; color: #6272a4; }
.theme-dracula .hljs-comment { color: #6272a4; font-style: italic; }
.theme-dracula .hljs-string { color: #f1fa8c; }
.theme-dracula .hljs-keyword { color: #ff79c6; }
.theme-dracula .hljs-number { color: #bd93f9; }
.theme-dracula .hljs-built_in, .theme-dracula .hljs-title { color: #8be9fd; }
.theme-dracula .hljs-function { color: #50fa7b; }
.theme-dracula .output-error { background: rgba(255,85,85,0.15); border-left: 4px solid #ff5555; }
.theme-dracula .error-header { color: #ff5555; }
.theme-dracula .output-stderr pre { color: #ffb86c; }
.theme-dracula table th { background: #bd93f9; color: #282a36; }
.theme-dracula table td { border-bottom: 1px solid #44475a; }

/* ========== NORD ========== */
.theme-nord {
  background: #2e3440;
  color: #eceff4;
}
.theme-nord .code-cell { background: #3b4252; border: 1px solid #4c566a; }
.theme-nord .cell-input { border-bottom: 1px solid #4c566a; }
.theme-nord .execution-count { background: #434c5e; color: #88c0d0; }
.theme-nord .cell-output { background: #2e3440; }
.theme-nord .output-count { color: #bf616a; }
.theme-nord .markdown-content h1, .theme-nord .markdown-content h2,
.theme-nord .markdown-content h3 { color: #88c0d0; }
.theme-nord .markdown-content code { background: #3b4252; color: #eceff4; }
.theme-nord .markdown-content blockquote { border-left-color: #88c0d0; color: #d8dee9; }
.theme-nord .hljs-comment { color: #616e88; font-style: italic; }
.theme-nord .hljs-string { color: #a3be8c; }
.theme-nord .hljs-keyword { color: #81a1c1; }
.theme-nord .hljs-number { color: #b48ead; }
.theme-nord .hljs-built_in, .theme-nord .hljs-title { color: #8fbcbb; }
.theme-nord .hljs-function { color: #88c0d0; }
.theme-nord .output-error { background: rgba(191,97,106,0.15); border-left: 4px solid #bf616a; }
.theme-nord .error-header { color: #bf616a; }
.theme-nord .output-stderr pre { color: #ebcb8b; }
.theme-nord table th { background: #5e81ac; color: #eceff4; }
.theme-nord table td { border-bottom: 1px solid #4c566a; }

/* ========== SOLARIZED LIGHT ========== */
.theme-solarizedLight {
  background: #fdf6e3;
  color: #657b83;
}
.theme-solarizedLight .code-cell { background: #eee8d5; border: 1px solid #93a1a1; }
.theme-solarizedLight .cell-input { border-bottom: 1px solid #93a1a1; }
.theme-solarizedLight .execution-count { background: #e4ddc8; color: #268bd2; }
.theme-solarizedLight .cell-output { background: #fdf6e3; }
.theme-solarizedLight .output-count { color: #dc322f; }
.theme-solarizedLight .markdown-content h1, .theme-solarizedLight .markdown-content h2,
.theme-solarizedLight .markdown-content h3 { color: #073642; }
.theme-solarizedLight .markdown-content code { background: #eee8d5; color: #657b83; }
.theme-solarizedLight .markdown-content blockquote { border-left-color: #268bd2; color: #93a1a1; }
.theme-solarizedLight .hljs-comment { color: #93a1a1; font-style: italic; }
.theme-solarizedLight .hljs-string { color: #2aa198; }
.theme-solarizedLight .hljs-keyword { color: #859900; }
.theme-solarizedLight .hljs-number { color: #d33682; }
.theme-solarizedLight .hljs-built_in, .theme-solarizedLight .hljs-title { color: #268bd2; }
.theme-solarizedLight .hljs-function { color: #268bd2; }
.theme-solarizedLight .output-error { background: rgba(220,50,47,0.1); border-left: 4px solid #dc322f; }
.theme-solarizedLight .error-header { color: #dc322f; }
.theme-solarizedLight .output-stderr pre { color: #b58900; }
.theme-solarizedLight table th { background: #268bd2; color: #fdf6e3; }
.theme-solarizedLight table td { border-bottom: 1px solid #93a1a1; }

/* ========== MONOKAI ========== */
.theme-monokai {
  background: #272822;
  color: #f8f8f2;
}
.theme-monokai .code-cell { background: #1e1f1c; border: 1px solid #49483e; }
.theme-monokai .cell-input { border-bottom: 1px solid #49483e; }
.theme-monokai .execution-count { background: #3e3d32; color: #66d9ef; }
.theme-monokai .cell-output { background: #272822; }
.theme-monokai .output-count { color: #f92672; }
.theme-monokai .markdown-content h1, .theme-monokai .markdown-content h2,
.theme-monokai .markdown-content h3 { color: #f8f8f2; }
.theme-monokai .markdown-content code { background: #3e3d32; color: #f8f8f2; }
.theme-monokai .markdown-content blockquote { border-left-color: #66d9ef; color: #75715e; }
.theme-monokai .hljs-comment { color: #75715e; font-style: italic; }
.theme-monokai .hljs-string { color: #e6db74; }
.theme-monokai .hljs-keyword { color: #f92672; }
.theme-monokai .hljs-number { color: #ae81ff; }
.theme-monokai .hljs-built_in, .theme-monokai .hljs-title { color: #a6e22e; }
.theme-monokai .hljs-function { color: #66d9ef; }
.theme-monokai .output-error { background: rgba(249,38,114,0.15); border-left: 4px solid #f92672; }
.theme-monokai .error-header { color: #f92672; }
.theme-monokai .output-stderr pre { color: #fd971f; }
.theme-monokai table th { background: #66d9ef; color: #272822; }
.theme-monokai table td { border-bottom: 1px solid #49483e; }

/* ========== ONE DARK ========== */
.theme-oneDark {
  background: #282c34;
  color: #abb2bf;
}
.theme-oneDark .code-cell { background: #21252b; border: 1px solid #3e4451; }
.theme-oneDark .cell-input { border-bottom: 1px solid #3e4451; }
.theme-oneDark .execution-count { background: #2c313c; color: #61afef; }
.theme-oneDark .cell-output { background: #282c34; }
.theme-oneDark .output-count { color: #e06c75; }
.theme-oneDark .markdown-content h1, .theme-oneDark .markdown-content h2,
.theme-oneDark .markdown-content h3 { color: #61afef; }
.theme-oneDark .markdown-content code { background: #2c313c; color: #abb2bf; }
.theme-oneDark .markdown-content blockquote { border-left-color: #61afef; color: #5c6370; }
.theme-oneDark .hljs-comment { color: #5c6370; font-style: italic; }
.theme-oneDark .hljs-string { color: #98c379; }
.theme-oneDark .hljs-keyword { color: #c678dd; }
.theme-oneDark .hljs-number { color: #d19a66; }
.theme-oneDark .hljs-built_in, .theme-oneDark .hljs-title { color: #e5c07b; }
.theme-oneDark .hljs-function { color: #61afef; }
.theme-oneDark .output-error { background: rgba(224,108,117,0.15); border-left: 4px solid #e06c75; }
.theme-oneDark .error-header { color: #e06c75; }
.theme-oneDark .output-stderr pre { color: #e5c07b; }
.theme-oneDark table th { background: #61afef; color: #282c34; }
.theme-oneDark table td { border-bottom: 1px solid #3e4451; }

/* ========== CATPPUCCIN MOCHA ========== */
.theme-catppuccin {
  background: #1e1e2e;
  color: #cdd6f4;
}
.theme-catppuccin .code-cell { background: #181825; border: 1px solid #45475a; }
.theme-catppuccin .cell-input { border-bottom: 1px solid #45475a; }
.theme-catppuccin .execution-count { background: #313244; color: #89b4fa; }
.theme-catppuccin .cell-output { background: #1e1e2e; }
.theme-catppuccin .output-count { color: #f38ba8; }
.theme-catppuccin .markdown-content h1, .theme-catppuccin .markdown-content h2,
.theme-catppuccin .markdown-content h3 { color: #cba6f7; }
.theme-catppuccin .markdown-content code { background: #313244; color: #cdd6f4; }
.theme-catppuccin .markdown-content blockquote { border-left-color: #cba6f7; color: #a6adc8; }
.theme-catppuccin .hljs-comment { color: #6c7086; font-style: italic; }
.theme-catppuccin .hljs-string { color: #a6e3a1; }
.theme-catppuccin .hljs-keyword { color: #cba6f7; }
.theme-catppuccin .hljs-number { color: #fab387; }
.theme-catppuccin .hljs-built_in, .theme-catppuccin .hljs-title { color: #f9e2af; }
.theme-catppuccin .hljs-function { color: #89b4fa; }
.theme-catppuccin .output-error { background: rgba(243,139,168,0.15); border-left: 4px solid #f38ba8; }
.theme-catppuccin .error-header { color: #f38ba8; }
.theme-catppuccin .output-stderr pre { color: #f9e2af; }
.theme-catppuccin table th { background: #89b4fa; color: #1e1e2e; }
.theme-catppuccin table td { border-bottom: 1px solid #45475a; }

/* ========== GRUVBOX DARK ========== */
.theme-gruvboxDark {
  background: #282828;
  color: #ebdbb2;
}
.theme-gruvboxDark .code-cell { background: #1d2021; border: 1px solid #504945; }
.theme-gruvboxDark .cell-input { border-bottom: 1px solid #504945; }
.theme-gruvboxDark .execution-count { background: #3c3836; color: #83a598; }
.theme-gruvboxDark .cell-output { background: #282828; }
.theme-gruvboxDark .output-count { color: #fb4934; }
.theme-gruvboxDark .markdown-content h1, .theme-gruvboxDark .markdown-content h2,
.theme-gruvboxDark .markdown-content h3 { color: #fabd2f; }
.theme-gruvboxDark .markdown-content code { background: #3c3836; color: #ebdbb2; }
.theme-gruvboxDark .markdown-content blockquote { border-left-color: #83a598; color: #a89984; }
.theme-gruvboxDark .hljs-comment { color: #928374; font-style: italic; }
.theme-gruvboxDark .hljs-string { color: #b8bb26; }
.theme-gruvboxDark .hljs-keyword { color: #fb4934; }
.theme-gruvboxDark .hljs-number { color: #d3869b; }
.theme-gruvboxDark .hljs-built_in, .theme-gruvboxDark .hljs-title { color: #fabd2f; }
.theme-gruvboxDark .hljs-function { color: #83a598; }
.theme-gruvboxDark .output-error { background: rgba(251,73,52,0.15); border-left: 4px solid #fb4934; }
.theme-gruvboxDark .error-header { color: #fb4934; }
.theme-gruvboxDark .output-stderr pre { color: #fe8019; }
.theme-gruvboxDark table th { background: #83a598; color: #282828; }
.theme-gruvboxDark table td { border-bottom: 1px solid #504945; }

/* ========== PAPER LIGHT ========== */
.theme-paperLight {
  background: #f5f5f5;
  color: #333333;
}
.theme-paperLight .code-cell { background: #ffffff; border: 1px solid #e0e0e0; }
.theme-paperLight .cell-input { border-bottom: 1px solid #e0e0e0; }
.theme-paperLight .execution-count { background: #fafafa; color: #1976d2; }
.theme-paperLight .cell-output { background: #f5f5f5; }
.theme-paperLight .output-count { color: #d32f2f; }
.theme-paperLight .markdown-content h1, .theme-paperLight .markdown-content h2,
.theme-paperLight .markdown-content h3 { color: #1565c0; border-bottom-color: #e0e0e0; }
.theme-paperLight .markdown-content code { background: #f5f5f5; color: #333333; }
.theme-paperLight .markdown-content blockquote { border-left-color: #1976d2; color: #757575; }
.theme-paperLight .hljs-comment { color: #9e9e9e; font-style: italic; }
.theme-paperLight .hljs-string { color: #43a047; }
.theme-paperLight .hljs-keyword { color: #7b1fa2; }
.theme-paperLight .hljs-number { color: #0288d1; }
.theme-paperLight .hljs-built_in, .theme-paperLight .hljs-title { color: #f57c00; }
.theme-paperLight .hljs-function { color: #1976d2; }
.theme-paperLight .output-error { background: #ffebee; border-left: 4px solid #d32f2f; }
.theme-paperLight .error-header { color: #d32f2f; }
.theme-paperLight .output-stderr pre { color: #ff8f00; }
.theme-paperLight table th { background: #1976d2; color: #ffffff; }
.theme-paperLight table td { border-bottom: 1px solid #e0e0e0; }

/* ========== COMMON ELEMENT STYLES ========== */
.markdown-cell { background: transparent; }
.markdown-content { padding: 1rem 0; }
.markdown-content h1 { font-size: 2em; border-bottom: 2px solid; padding-bottom: 0.3em; margin-top: 1.5em; margin-bottom: 0.5em; }
.markdown-content h2 { font-size: 1.5em; border-bottom: 1px solid; padding-bottom: 0.3em; margin-top: 1.5em; margin-bottom: 0.5em; }
.markdown-content h3 { font-size: 1.25em; margin-top: 1.5em; margin-bottom: 0.5em; }
.markdown-content code { padding: 0.2em 0.4em; border-radius: 4px; font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace; font-size: 0.9em; }
.markdown-content pre code { display: block; padding: 1rem; overflow-x: auto; }
.markdown-content blockquote { border-left-width: 4px; border-left-style: solid; margin: 1rem 0; padding-left: 1rem; }
.markdown-content table { border-collapse: collapse; width: 100%; margin: 1rem 0; }
.markdown-content th, .markdown-content td { padding: 0.5rem 1rem; text-align: left; }

.cell-input { display: flex; }
.execution-count { min-width: 80px; padding: 1rem; font-family: 'JetBrains Mono', monospace; font-size: 0.85em; text-align: right; display: flex; align-items: flex-start; justify-content: flex-end; }
.code-content { flex: 1; overflow-x: auto; }
.code-content pre { margin: 0; padding: 1rem; }
.code-content code { font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace; font-size: 0.9em; line-height: 1.5; }

.cell-output { padding: 0.5rem 0; }
.output-item { padding: 0.5rem 1rem 0.5rem calc(80px + 1rem); }
.output-item pre { margin: 0; white-space: pre-wrap; word-wrap: break-word; font-family: 'JetBrains Mono', monospace; font-size: 0.9em; }
.output-error { margin: 0.5rem 1rem 0.5rem calc(80px + 1rem); padding: 1rem; border-radius: 0 4px 4px 0; }
.error-header { font-weight: bold; margin-bottom: 0.5rem; }
.error-traceback { font-size: 0.85em; opacity: 0.9; }

.output-image { text-align: center; }
.output-image img, .output-image svg { max-width: 100%; height: auto; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.2); }

.output-html table, .dataframe { border-collapse: collapse; margin: 0.5rem 0; font-size: 0.9em; }
.output-html th, .dataframe th { padding: 0.6rem 1rem; text-align: left; font-weight: 600; }
.output-html td, .dataframe td { padding: 0.5rem 1rem; }
.output-html tr:nth-child(even), .dataframe tr:nth-child(even) { opacity: 0.9; }

.raw-cell { border: 1px dashed; }
.raw-content pre { margin: 0; padding: 1rem; font-family: 'JetBrains Mono', monospace; }

@media print {
  body { background: white !important; color: black !important; }
  .notebook-container { max-width: none; padding: 0; }
  .cell { page-break-inside: avoid; }
}
</style>
    ''';
  }
}
