import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/conversion_state.dart';
import '../widgets/file_list_tile.dart';
import '../widgets/settings_panel.dart';
import '../widgets/drop_zone.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConversionState>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    return Scaffold(
      body: DropTarget(
        onDragDone: (details) {
          final paths = details.files.map((f) => f.path).toList();
          state.addFiles(paths);
          setState(() => _isDragging = false);
        },
        onDragEntered: (_) => setState(() => _isDragging = true),
        onDragExited: (_) => setState(() => _isDragging = false),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Main content
              Expanded(
                child: Row(
                  children: [
                    // File list / Drop zone
                    Expanded(
                      flex: 3,
                      child: _buildMainContent(context, state),
                    ),
                    
                    // Settings sidebar (desktop only)
                    if (isDesktop && MediaQuery.of(context).size.width > 800)
                      Container(
                        width: 320,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        child: const SettingsPanel(),
                      ),
                  ],
                ),
              ),
              
              // Bottom action bar
              _buildActionBar(context, state),
            ],
          ),
        ),
      ),
      
      // FAB for mobile settings
      floatingActionButton: (!isDesktop || MediaQuery.of(context).size.width <= 800)
          ? FloatingActionButton(
              onPressed: () => _showSettingsSheet(context),
              child: const Icon(Icons.settings),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          // Logo/Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.tertiary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.transform,
              color: Colors.white,
              size: 24,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          
          const SizedBox(width: 16),
          
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notebook Converter',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
              Text(
                'Convert Jupyter notebooks to HTML',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            ],
          ),
          
          const Spacer(),
          
          // Theme toggle
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Theme toggle would need app-level state
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme follows system settings')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ConversionState state) {
    if (!state.hasFiles) {
      return DropZone(
        isDragging: _isDragging,
        onSelectFiles: () => _selectFiles(context),
        onSelectFolder: () => _selectFolder(context),
      );
    }

    return Column(
      children: [
        // File list header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${state.files.length} file(s) selected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _selectFiles(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add More'),
              ),
              const SizedBox(width: 8),
              if (state.completedCount > 0)
                TextButton.icon(
                  onPressed: state.resetAllForReconversion,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: state.clearFiles,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear All'),
              ),
            ],
          ),
        ),
        
        // File list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.files.length,
            itemBuilder: (context, index) {
              final file = state.files[index];
              return FileListTile(
                file: file,
                onRemove: () => state.removeFile(file),
                onOpen: file.outputPath != null
                    ? () => _openFile(file.outputPath!)
                    : null,
              ).animate().fadeIn(
                duration: 200.ms,
                delay: (50 * index).ms,
              ).slideX(begin: 0.05);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context, ConversionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicators
          if (state.hasFiles) ...[
            _StatusChip(
              icon: Icons.pending,
              label: '${state.pendingCount} pending',
              color: colorScheme.outline,
            ),
            const SizedBox(width: 8),
            _StatusChip(
              icon: Icons.check_circle,
              label: '${state.completedCount} done',
              color: Colors.green,
            ),
            if (state.failedCount > 0) ...[
              const SizedBox(width: 8),
              _StatusChip(
                icon: Icons.error,
                label: '${state.failedCount} failed',
                color: colorScheme.error,
              ),
            ],
          ],
          
          const Spacer(),
          
          // Convert button
          FilledButton.icon(
            onPressed: state.hasFiles && !state.isConverting
                ? () => state.convertAll()
                : null,
            icon: state.isConverting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.rocket_launch),
            label: Text(state.isConverting ? 'Converting...' : 'Convert All'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ipynb'],
      allowMultiple: true,
    );

    if (result != null && mounted) {
      final paths = result.files
          .where((f) => f.path != null)
          .map((f) => f.path!)
          .toList();
      context.read<ConversionState>().addFiles(paths);
    }
  }

  Future<void> _selectFolder(BuildContext context) async {
    final result = await FilePicker.platform.getDirectoryPath();

    if (result != null && mounted) {
      context.read<ConversionState>().addFiles([result]);
    }
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const SettingsPanel(),
        ),
      ),
    );
  }

  Future<void> _openFile(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

