import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/conversion_state.dart';
import '../screens/theme_editor_screen.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConversionState>();
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.tune, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Output directory
          Text(
            'Output Directory',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectOutputDir(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.outputDirectory ?? 'Same as source file',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: state.outputDirectory != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (state.outputDirectory != null)
                    IconButton(
                      onPressed: () => state.setOutputDirectory(null),
                      icon: const Icon(Icons.clear, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Conversion options
          Text(
            'Conversion Options',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          // Embed images
          _SettingsSwitch(
            title: 'Embed Images',
            subtitle: 'Include images as base64 in HTML (larger file, but self-contained)',
            value: state.embedImages,
            onChanged: state.setEmbedImages,
          ),

          const SizedBox(height: 12),

          // Include code cells
          _SettingsSwitch(
            title: 'Include Code Cells',
            subtitle: 'Show source code in the output',
            value: state.includeInput,
            onChanged: state.setIncludeInput,
          ),

          const SizedBox(height: 12),

          // Append theme name to filename
          _SettingsSwitch(
            title: 'Append Theme to Filename',
            subtitle: 'Save as notebook_themeName.html to compare themes',
            value: state.appendThemeName,
            onChanged: state.setAppendThemeName,
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Theme selection
          Text(
            'Color Theme',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a color scheme for the HTML output',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),

          // Dark themes section
          Text(
            'Dark Themes',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HtmlTheme.values
                .where((t) => t.isDark)
                .map((theme) => _ThemeChip(
                      theme: theme,
                      isSelected: state.theme == theme,
                      onSelected: () => state.setTheme(theme),
                    ))
                .toList(),
          ),

          const SizedBox(height: 16),

          // Light themes section
          Text(
            'Light Themes',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HtmlTheme.values
                .where((t) => !t.isDark)
                .map((theme) => _ThemeChip(
                      theme: theme,
                      isSelected: state.theme == theme && !state.useCustomTheme,
                      onSelected: () {
                        state.setUseCustomTheme(false);
                        state.setTheme(theme);
                      },
                    ))
                .toList(),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Custom Themes Section
          Row(
            children: [
              Text(
                'Custom Themes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openThemeEditor(context, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (state.savedCustomThemes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create custom themes with your own colors and backgrounds!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.savedCustomThemes.map((customTheme) {
                final isSelected = state.useCustomTheme && 
                    state.customTheme?.name == customTheme.name;
                return _CustomThemeChip(
                  customTheme: customTheme,
                  isSelected: isSelected,
                  onSelected: () => state.setCustomTheme(customTheme),
                  onEdit: () => _openThemeEditor(context, customTheme),
                  onDelete: () => _confirmDeleteTheme(context, state, customTheme),
                );
              }).toList(),
            ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // About section
          Text(
            'About',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.tertiary],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.transform,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notebook Converter',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Convert Jupyter notebooks to beautiful, standalone HTML files with full output preservation.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectOutputDir(BuildContext context) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && context.mounted) {
      context.read<ConversionState>().setOutputDirectory(result);
    }
  }

  Future<void> _openThemeEditor(BuildContext context, CustomTheme? theme) async {
    final result = await Navigator.of(context).push<CustomTheme>(
      MaterialPageRoute(
        builder: (context) => ThemeEditorScreen(initialTheme: theme),
      ),
    );
    
    if (result != null && context.mounted) {
      context.read<ConversionState>().saveCustomTheme(result);
    }
  }

  Future<void> _confirmDeleteTheme(BuildContext context, ConversionState state, CustomTheme theme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Theme?'),
        content: Text('Are you sure you want to delete "${theme.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      state.deleteCustomTheme(theme);
    }
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final HtmlTheme theme;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ThemeChip({
    required this.theme,
    required this.isSelected,
    required this.onSelected,
  });

  // Get preview colors for each theme
  Color _getThemeBgColor() {
    switch (theme) {
      case HtmlTheme.tokyoNight:
        return const Color(0xFF1a1b26);
      case HtmlTheme.githubLight:
        return const Color(0xFFffffff);
      case HtmlTheme.dracula:
        return const Color(0xFF282a36);
      case HtmlTheme.nord:
        return const Color(0xFF2e3440);
      case HtmlTheme.solarizedLight:
        return const Color(0xFFfdf6e3);
      case HtmlTheme.monokai:
        return const Color(0xFF272822);
      case HtmlTheme.oneDark:
        return const Color(0xFF282c34);
      case HtmlTheme.catppuccin:
        return const Color(0xFF1e1e2e);
      case HtmlTheme.gruvboxDark:
        return const Color(0xFF282828);
      case HtmlTheme.paperLight:
        return const Color(0xFFf5f5f5);
    }
  }

  Color _getThemeAccentColor() {
    switch (theme) {
      case HtmlTheme.tokyoNight:
        return const Color(0xFF7aa2f7);
      case HtmlTheme.githubLight:
        return const Color(0xFF0969da);
      case HtmlTheme.dracula:
        return const Color(0xFFbd93f9);
      case HtmlTheme.nord:
        return const Color(0xFF88c0d0);
      case HtmlTheme.solarizedLight:
        return const Color(0xFF268bd2);
      case HtmlTheme.monokai:
        return const Color(0xFF66d9ef);
      case HtmlTheme.oneDark:
        return const Color(0xFF61afef);
      case HtmlTheme.catppuccin:
        return const Color(0xFF89b4fa);
      case HtmlTheme.gruvboxDark:
        return const Color(0xFF83a598);
      case HtmlTheme.paperLight:
        return const Color(0xFF1976d2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = _getThemeBgColor();
    final accentColor = _getThemeAccentColor();

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Theme color preview
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade400, width: 0.5),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              theme.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomThemeChip extends StatelessWidget {
  final CustomTheme customTheme;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomThemeChip({
    required this.customTheme,
    required this.isSelected,
    required this.onSelected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom theme color preview
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: customTheme.backgroundColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade400, width: 0.5),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: customTheme.headingColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              customTheme.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            const SizedBox(width: 4),
            // Edit button
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.edit,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Delete button
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: colorScheme.error,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
