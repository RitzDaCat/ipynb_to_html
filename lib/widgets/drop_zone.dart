import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DropZone extends StatelessWidget {
  final bool isDragging;
  final VoidCallback onSelectFiles;
  final VoidCallback onSelectFolder;

  const DropZone({
    super.key,
    required this.isDragging,
    required this.onSelectFiles,
    required this.onSelectFolder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: isDragging
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDragging
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isDragging ? 3 : 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDragging
                    ? colorScheme.primary.withOpacity(0.2)
                    : colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDragging ? Icons.file_download : Icons.upload_file,
                size: 64,
                color: isDragging
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            )
                .animate(target: isDragging ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
                .then()
                .shake(hz: 2, rotation: 0.02),

            const SizedBox(height: 32),

            // Title
            Text(
              isDragging
                  ? 'Drop your notebooks here!'
                  : 'Drag & Drop Notebooks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDragging
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Drop .ipynb files or folders here, or use the buttons below',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

            const SizedBox(height: 32),

            // Buttons
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onSelectFiles,
                  icon: const Icon(Icons.file_open),
                  label: const Text('Select Files'),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2),
                
                OutlinedButton.icon(
                  onPressed: onSelectFolder,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select Folder'),
                ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2),
              ],
            ),

            const SizedBox(height: 32),

            // Supported formats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Supports .ipynb (Jupyter Notebook) files',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

