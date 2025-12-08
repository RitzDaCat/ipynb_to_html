import 'package:flutter/material.dart';
import '../models/custom_theme.dart';

class ThemeEditorScreen extends StatefulWidget {
  final CustomTheme? initialTheme;
  
  const ThemeEditorScreen({super.key, this.initialTheme});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  late CustomTheme _theme;
  final _nameController = TextEditingController();
  int _selectedSection = 0;

  final _sections = [
    'Background',
    'Text & Headings',
    'Code Cells',
    'Syntax Highlighting',
    'Output & Errors',
    'Tables',
  ];

  @override
  void initState() {
    super.initState();
    _theme = widget.initialTheme ?? const CustomTheme(name: 'My Custom Theme');
    _nameController.text = _theme.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Theme Editor'),
        actions: [
          TextButton.icon(
            onPressed: _saveTheme,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Section navigation
          Container(
            width: 200,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              children: [
                // Theme name
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Theme Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _theme = _theme.copyWith(name: value);
                      });
                    },
                  ),
                ),
                const Divider(),
                // Section list
                Expanded(
                  child: ListView.builder(
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedSection == index;
                      return ListTile(
                        title: Text(_sections[index]),
                        selected: isSelected,
                        selectedTileColor: colorScheme.primaryContainer,
                        onTap: () => setState(() => _selectedSection = index),
                      );
                    },
                  ),
                ),
                const Divider(),
                // Presets
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Start from Preset',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: CustomThemePresets.all.map((preset) {
                          return ActionChip(
                            label: Text(preset.name),
                            onPressed: () {
                              setState(() {
                                _theme = preset.copyWith(name: _nameController.text);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Color editors
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildSection(),
            ),
          ),
          // Preview
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: _buildPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection() {
    switch (_selectedSection) {
      case 0:
        return _buildBackgroundSection();
      case 1:
        return _buildTextSection();
      case 2:
        return _buildCodeCellSection();
      case 3:
        return _buildSyntaxSection();
      case 4:
        return _buildOutputSection();
      case 5:
        return _buildTableSection();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBackgroundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Background', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ColorPicker(
          label: 'Primary Background',
          color: _theme.backgroundColor,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(backgroundColor: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Secondary Background (for gradients)',
          color: _theme.backgroundColorSecondary ?? _theme.backgroundColor,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(backgroundColorSecondary: c)),
        ),
        const SizedBox(height: 24),
        Text('Background Style', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BackgroundStyle.values.map((style) {
            final isSelected = _theme.backgroundStyle == style;
            return ChoiceChip(
              label: Text(style.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _theme = _theme.copyWith(backgroundStyle: style));
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Pattern Opacity: ${(_theme.patternOpacity * 100).round()}%'),
        Slider(
          value: _theme.patternOpacity,
          min: 0.01,
          max: 0.3,
          onChanged: (v) => setState(() => _theme = _theme.copyWith(patternOpacity: v)),
        ),
      ],
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Text & Headings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ColorPicker(
          label: 'Text Color',
          color: _theme.textColor,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(textColor: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Heading Color',
          color: _theme.headingColor,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(headingColor: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Link Color',
          color: _theme.linkColor,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(linkColor: c)),
        ),
      ],
    );
  }

  Widget _buildCodeCellSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Code Cells', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ColorPicker(
          label: 'Code Cell Background',
          color: _theme.codeCellBackground,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(codeCellBackground: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Code Cell Border',
          color: _theme.codeCellBorder,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(codeCellBorder: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Execution Count (In [1]:)',
          color: _theme.executionCountColor,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(executionCountColor: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Output Background',
          color: _theme.outputBackground,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(outputBackground: c)),
        ),
      ],
    );
  }

  Widget _buildSyntaxSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Syntax Highlighting', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ColorPicker(
          label: 'Comments',
          color: _theme.syntaxComment,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(syntaxComment: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Strings',
          color: _theme.syntaxString,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(syntaxString: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Keywords',
          color: _theme.syntaxKeyword,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(syntaxKeyword: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Numbers',
          color: _theme.syntaxNumber,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(syntaxNumber: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Functions',
          color: _theme.syntaxFunction,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(syntaxFunction: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Variables',
          color: _theme.syntaxVariable,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(syntaxVariable: c)),
        ),
      ],
    );
  }

  Widget _buildOutputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Output & Errors', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ColorPicker(
          label: 'Output Text',
          color: _theme.outputText,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(outputText: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Warning Text',
          color: _theme.warningText,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(warningText: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Error Background',
          color: _theme.errorBackground,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(errorBackground: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Error Text',
          color: _theme.errorText,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(errorText: c)),
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tables', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ColorPicker(
          label: 'Header Background',
          color: _theme.tableHeaderBackground,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(tableHeaderBackground: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Header Text',
          color: _theme.tableHeaderText,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(tableHeaderText: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Border Color',
          color: _theme.tableBorder,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(tableBorder: c)),
        ),
        const SizedBox(height: 16),
        _ColorPicker(
          label: 'Alternate Row Color',
          color: _theme.tableRowAlt,
          onChanged: (c) => setState(() => _theme = _theme.copyWith(tableRowAlt: c)),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return CustomPaint(
      painter: _BackgroundPatternPainter(
        backgroundColor: _theme.backgroundColor,
        secondaryColor: _theme.backgroundColorSecondary ?? _theme.backgroundColor,
        patternColor: _theme.codeCellBorder,
        accentColor: _theme.headingColor,
        style: _theme.backgroundStyle,
        opacity: _theme.patternOpacity,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Preview',
              style: TextStyle(
                color: _theme.headingColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This is regular text that shows how your content will look.',
              style: TextStyle(color: _theme.textColor),
            ),
            const SizedBox(height: 16),
            // Code cell preview
            Container(
              decoration: BoxDecoration(
                color: _theme.codeCellBackground,
                border: Border.all(color: _theme.codeCellBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: _theme.codeCellBorder),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'In [1]:',
                          style: TextStyle(
                            color: _theme.executionCountColor,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                              children: [
                                TextSpan(text: '# Comment\n', style: TextStyle(color: _theme.syntaxComment, fontStyle: FontStyle.italic)),
                                TextSpan(text: 'def ', style: TextStyle(color: _theme.syntaxKeyword)),
                                TextSpan(text: 'hello', style: TextStyle(color: _theme.syntaxFunction)),
                                TextSpan(text: '(', style: TextStyle(color: _theme.textColor)),
                                TextSpan(text: 'name', style: TextStyle(color: _theme.syntaxVariable)),
                                TextSpan(text: '):\n', style: TextStyle(color: _theme.textColor)),
                                TextSpan(text: '    print', style: TextStyle(color: _theme.syntaxFunction)),
                                TextSpan(text: '(', style: TextStyle(color: _theme.textColor)),
                                TextSpan(text: '"Hello "', style: TextStyle(color: _theme.syntaxString)),
                                TextSpan(text: ' + name)\n', style: TextStyle(color: _theme.textColor)),
                                TextSpan(text: '    return ', style: TextStyle(color: _theme.syntaxKeyword)),
                                TextSpan(text: '42', style: TextStyle(color: _theme.syntaxNumber)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Output
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: _theme.outputBackground,
                    child: Text(
                      'Hello World',
                      style: TextStyle(
                        color: _theme.outputText,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Error preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _theme.errorBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border(
                  left: BorderSide(color: _theme.errorText, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TypeError: example error',
                    style: TextStyle(
                      color: _theme.errorText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Warning message',
                    style: TextStyle(color: _theme.warningText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Table preview
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Table(
                border: TableBorder.all(color: _theme.tableBorder),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: _theme.tableHeaderBackground),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Column A', style: TextStyle(color: _theme.tableHeaderText, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Column B', style: TextStyle(color: _theme.tableHeaderText, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text('Data 1', style: TextStyle(color: _theme.textColor))),
                      Padding(padding: const EdgeInsets.all(8), child: Text('Data 2', style: TextStyle(color: _theme.textColor))),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(color: _theme.tableRowAlt),
                    children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text('Data 3', style: TextStyle(color: _theme.textColor))),
                      Padding(padding: const EdgeInsets.all(8), child: Text('Data 4', style: TextStyle(color: _theme.textColor))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _saveTheme() {
    Navigator.of(context).pop(_theme);
  }
}

class _ColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorPicker({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => _showColorPicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: color,
        onColorSelected: onChanged,
      ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late double _hue;
  late double _saturation;
  late double _lightness;
  late double _alpha;

  @override
  void initState() {
    super.initState();
    final hsl = HSLColor.fromColor(widget.initialColor);
    _hue = hsl.hue;
    _saturation = hsl.saturation;
    _lightness = hsl.lightness;
    _alpha = widget.initialColor.alpha / 255;
  }

  Color get _currentColor => HSLColor.fromAHSL(_alpha, _hue, _saturation, _lightness).toColor();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a Color'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            // Hue slider
            _buildSlider('Hue', _hue, 0, 360, (v) => setState(() => _hue = v)),
            _buildSlider('Saturation', _saturation, 0, 1, (v) => setState(() => _saturation = v)),
            _buildSlider('Lightness', _lightness, 0, 1, (v) => setState(() => _lightness = v)),
            _buildSlider('Opacity', _alpha, 0, 1, (v) => setState(() => _alpha = v)),
            const SizedBox(height: 16),
            // Quick colors
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
                Colors.black,
                Colors.white,
              ].map((c) => InkWell(
                onTap: () {
                  final hsl = HSLColor.fromColor(c);
                  setState(() {
                    _hue = hsl.hue;
                    _saturation = hsl.saturation;
                    _lightness = hsl.lightness;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onColorSelected(_currentColor);
            Navigator.pop(context);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            max > 1 ? value.round().toString() : value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for background patterns
class _BackgroundPatternPainter extends CustomPainter {
  final Color backgroundColor;
  final Color secondaryColor;
  final Color patternColor;
  final Color accentColor;
  final BackgroundStyle style;
  final double opacity;

  _BackgroundPatternPainter({
    required this.backgroundColor,
    required this.secondaryColor,
    required this.patternColor,
    required this.accentColor,
    required this.style,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    switch (style) {
      case BackgroundStyle.solid:
        canvas.drawRect(rect, Paint()..color = backgroundColor);
        break;

      case BackgroundStyle.gradient:
        final gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, secondaryColor],
        );
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;

      case BackgroundStyle.dots:
        canvas.drawRect(rect, Paint()..color = backgroundColor);
        final dotPaint = Paint()
          ..color = patternColor.withOpacity(opacity * 3)
          ..style = PaintingStyle.fill;
        const spacing = 20.0;
        for (double x = 0; x < size.width; x += spacing) {
          for (double y = 0; y < size.height; y += spacing) {
            canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
          }
        }
        break;

      case BackgroundStyle.grid:
        canvas.drawRect(rect, Paint()..color = backgroundColor);
        final gridPaint = Paint()
          ..color = patternColor.withOpacity(opacity)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        const spacing = 20.0;
        // Vertical lines
        for (double x = 0; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
        }
        // Horizontal lines
        for (double y = 0; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        }
        break;

      case BackgroundStyle.diagonalLines:
        canvas.drawRect(rect, Paint()..color = backgroundColor);
        final linePaint = Paint()
          ..color = patternColor.withOpacity(opacity)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        const spacing = 15.0;
        for (double i = -size.height; i < size.width + size.height; i += spacing) {
          canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), linePaint);
        }
        break;

      case BackgroundStyle.noise:
        canvas.drawRect(rect, Paint()..color = backgroundColor);
        // Simulate noise with random dots
        final noisePaint = Paint()
          ..color = patternColor.withOpacity(opacity * 0.5)
          ..style = PaintingStyle.fill;
        final random = DateTime.now().millisecond;
        for (int i = 0; i < 500; i++) {
          final x = ((i * 17 + random) % size.width.toInt()).toDouble();
          final y = ((i * 31 + random) % size.height.toInt()).toDouble();
          canvas.drawCircle(Offset(x, y), 0.5, noisePaint);
        }
        break;

      case BackgroundStyle.paper:
        canvas.drawRect(rect, Paint()..color = backgroundColor);
        // Large grid
        final largePaint = Paint()
          ..color = patternColor.withOpacity(opacity * 0.5)
          ..strokeWidth = 1;
        const largeSpacing = 100.0;
        for (double x = 0; x < size.width; x += largeSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), largePaint);
        }
        for (double y = 0; y < size.height; y += largeSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), largePaint);
        }
        // Small grid
        final smallPaint = Paint()
          ..color = patternColor.withOpacity(opacity * 0.3)
          ..strokeWidth = 0.5;
        const smallSpacing = 20.0;
        for (double x = 0; x < size.width; x += smallSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), smallPaint);
        }
        for (double y = 0; y < size.height; y += smallSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), smallPaint);
        }
        break;

      case BackgroundStyle.blueprint:
        canvas.drawRect(rect, Paint()..color = backgroundColor);
        // Large grid with accent color
        final largeBluePaint = Paint()
          ..color = accentColor.withOpacity(opacity)
          ..strokeWidth = 2;
        const largeSpacing = 100.0;
        for (double x = 0; x < size.width; x += largeSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), largeBluePaint);
        }
        for (double y = 0; y < size.height; y += largeSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), largeBluePaint);
        }
        // Small grid
        final smallBluePaint = Paint()
          ..color = accentColor.withOpacity(opacity * 0.5)
          ..strokeWidth = 0.5;
        const smallSpacing = 20.0;
        for (double x = 0; x < size.width; x += smallSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), smallBluePaint);
        }
        for (double y = 0; y < size.height; y += smallSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), smallBluePaint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.patternColor != patternColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.style != style ||
        oldDelegate.opacity != opacity;
  }
}

