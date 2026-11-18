import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  FileStorageService._internal();
  static final FileStorageService instance = FileStorageService._internal();

  static const String _recordsDirectoryName = 'medical_records_files';

  /// Returns the base directory for storing managed records files.
  Future<Directory> _getRecordsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final recordsDir = Directory(p.join(appDocDir.path, _recordsDirectoryName));
    if (!await recordsDir.exists()) {
      await recordsDir.create(recursive: true);
    }
    return recordsDir;
  }

  /// Copies a user-selected file into the managed application documents directory.
  /// Returns the *relative path* from the application documents directory (e.g. `medical_records_files/record_123_test.pdf`).
  /// Storing relative paths protects against sandbox path changes across iOS/Android reboots or updates.
  Future<String> saveDocumentFile({
    required File sourceFile,
    required String originalFileName,
  }) async {
    final recordsDir = await _getRecordsDirectory();

    // Sanitize file name and create unique timestamped name
    final extension = p.extension(originalFileName);
    final baseName = p.basenameWithoutExtension(originalFileName).replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final uniqueFileName = '${baseName}_${DateTime.now().millisecondsSinceEpoch}$extension';

    final targetPath = p.join(recordsDir.path, uniqueFileName);
    await sourceFile.copy(targetPath);

    // Return relative path
    return p.join(_recordsDirectoryName, uniqueFileName);
  }

  /// Resolves a stored relative path into an absolute [File] object for reading/opening.
  Future<File> resolveFile(String relativePath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final absolutePath = p.join(appDocDir.path, relativePath);
    return File(absolutePath);
  }

  /// Checks if a file exists on disk given its relative path.
  Future<bool> fileExists(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) return false;
    try {
      final file = await resolveFile(relativePath);
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  /// Deletes a file from the managed storage if it exists.
  Future<void> deleteFile(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) return;
    try {
      final file = await resolveFile(relativePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore deletion failure if file is already missing
    }
  }

  /// Formats byte size into human readable string (e.g. 1.2 MB).
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
