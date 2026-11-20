import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/file_storage_service.dart';

class AttachmentPreviewCard extends StatefulWidget {
  final File? localFile;
  final String? relativeFilePath;
  final String? fileType;
  final VoidCallback? onRemove;
  final bool isInteractive;

  const AttachmentPreviewCard({
    super.key,
    this.localFile,
    this.relativeFilePath,
    this.fileType,
    this.onRemove,
    this.isInteractive = true,
  });

  @override
  State<AttachmentPreviewCard> createState() => _AttachmentPreviewCardState();
}

class _AttachmentPreviewCardState extends State<AttachmentPreviewCard> {
  File? _resolvedFile;
  int? _fileSizeBytes;
  bool _isLoading = true;
  bool _fileMissing = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  @override
  void didUpdateWidget(covariant AttachmentPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localFile != oldWidget.localFile ||
        widget.relativeFilePath != oldWidget.relativeFilePath) {
      _loadFile();
    }
  }

  Future<void> _loadFile() async {
    // Bumped for every load so a slow earlier disk read cannot overwrite the
    // result of a newer one when the attachment changes in quick succession.
    final generation = ++_loadGeneration;

    _resolvedFile = null;
    _fileSizeBytes = null;
    _fileMissing = false;
    setState(() => _isLoading = true);

    File? resolved;
    int? sizeBytes;
    var missing = false;

    final localFile = widget.localFile;
    if (localFile != null) {
      resolved = localFile;
      if (await localFile.exists()) {
        sizeBytes = await localFile.length();
      } else {
        missing = true;
      }
    } else if (widget.relativeFilePath != null) {
      final file = await FileStorageService.instance.resolveFile(widget.relativeFilePath!);
      if (await file.exists()) {
        resolved = file;
        sizeBytes = await file.length();
      } else {
        missing = true;
      }
    } else {
      missing = true;
    }

    if (!mounted || generation != _loadGeneration) return;

    setState(() {
      _resolvedFile = missing ? null : resolved;
      _fileSizeBytes = missing ? null : sizeBytes;
      _fileMissing = missing;
      _isLoading = false;
    });
  }

  Future<void> _openFile() async {
    if (!widget.isInteractive) return;

    if (_fileMissing || _resolvedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attached file could not be found on device storage.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final result = await OpenFilex.open(_resolvedFile!.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open document: ${result.message}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_fileMissing) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.broken_image_outlined, color: AppColors.error),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Document attachment is missing from storage.',
                style: TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ),
            if (widget.onRemove != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: widget.onRemove,
              ),
          ],
        ),
      );
    }

    final filePath = _resolvedFile!.path;
    final fileName = p.basename(filePath);
    final ext = p.extension(filePath).toLowerCase();
    final isPdf = ext == '.pdf' || widget.fileType?.toLowerCase() == 'pdf';
    final sizeText = _fileSizeBytes != null ? FileStorageService.formatBytes(_fileSizeBytes!) : '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _openFile,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Thumbnail / Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 52,
                  height: 52,
                  color: isPdf ? AppColors.errorContainer : AppColors.primaryContainer,
                  child: isPdf
                      ? const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: AppColors.error,
                          size: 28,
                        )
                      : Image.file(
                          _resolvedFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.image_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and file details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          isPdf ? 'PDF Document' : 'Image File',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (sizeText.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: 6),
                          Text(
                            sizeText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action button or remove button
              if (widget.onRemove != null)
                IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.textMuted, size: 20),
                  tooltip: 'Remove Attachment',
                  onPressed: widget.onRemove,
                )
              else if (widget.isInteractive)
                const Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
