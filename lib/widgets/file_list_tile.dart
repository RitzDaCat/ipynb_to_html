import 'package:flutter/material.dart';
import '../services/conversion_state.dart';

class FileListTile extends StatelessWidget {
  final ConversionFile file;
  final VoidCallback onRemove;
  final VoidCallback? onOpen;

  const FileListTile({
    super.key,
    required this.file,
    required this.onRemove,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status icon
            _buildStatusIcon(colorScheme),
            
            const SizedBox(width: 12),
            
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getStatusText(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(colorScheme),
                        ),
                  ),
                  if (file.error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      file.error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            if (file.status == ConversionStatus.completed && onOpen != null)
              IconButton(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Open HTML',
                color: colorScheme.primary,
              ),
            
            if (file.status != ConversionStatus.converting)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
                tooltip: 'Remove',
                color: colorScheme.outline,
              ),
            
            if (file.status == ConversionStatus.converting)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (file.status) {
      case ConversionStatus.pending:
        icon = Icons.schedule;
        color = colorScheme.outline;
        bgColor = colorScheme.surfaceContainerHigh;
        break;
      case ConversionStatus.converting:
        icon = Icons.sync;
        color = colorScheme.primary;
        bgColor = colorScheme.primaryContainer;
        break;
      case ConversionStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        break;
      case ConversionStatus.failed:
        icon = Icons.error;
        color = colorScheme.error;
        bgColor = colorScheme.errorContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _getStatusText() {
    switch (file.status) {
      case ConversionStatus.pending:
        return 'Pending conversion';
      case ConversionStatus.converting:
        return 'Converting...';
      case ConversionStatus.completed:
        return 'Converted successfully';
      case ConversionStatus.failed:
        return 'Conversion failed';
    }
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    switch (file.status) {
      case ConversionStatus.pending:
        return colorScheme.outline;
      case ConversionStatus.converting:
        return colorScheme.primary;
      case ConversionStatus.completed:
        return Colors.green;
      case ConversionStatus.failed:
        return colorScheme.error;
    }
  }
}

