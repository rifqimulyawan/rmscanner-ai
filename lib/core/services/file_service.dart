import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';

class FileService {
  static const String _filesKey = 'rmscanner_files';
  Future<String> get _appDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final rmscannerDir = Directory('${directory.path}/Rmscanner');
    if (!await rmscannerDir.exists()) {
      await rmscannerDir.create(recursive: true);
    }
    return rmscannerDir.path;
  }

  Future<List<FileModel>> getAllFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = prefs.getStringList(_filesKey) ?? [];
    return filesJson
        .map((json) => FileModel.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<FileModel>> getFilesByType(FileType type) async {
    final files = await getAllFiles();
    return files.where((file) => file.type == type).toList();
  }

  Future<void> saveFile(FileModel file) async {
    final files = await getAllFiles();
    files.add(file);
    await _saveFiles(files);
  }

  Future<void> deleteFile(String fileId) async {
    final files = await getAllFiles();
    final file = files.firstWhere((f) => f.id == fileId);

    // Delete actual file
    final actualFile = File(file.path);
    if (await actualFile.exists()) {
      await actualFile.delete();
    }

    // Delete thumbnail if exists
    if (file.thumbnailPath != null) {
      final thumbnail = File(file.thumbnailPath!);
      if (await thumbnail.exists()) {
        await thumbnail.delete();
      }
    }
    files.removeWhere((f) => f.id == fileId);
    await _saveFiles(files);
  }

  Future<void> renameFile(String fileId, String newName) async {
    final files = await getAllFiles();
    final index = files.indexWhere((f) => f.id == fileId);
    if (index != -1) {
      final file = files[index];
      final oldFile = File(file.path);
      if (await oldFile.exists()) {
        final dir = oldFile.parent.path;
        final extension = file.path.split('.').last;
        final safeName = newName.endsWith('.$extension')
            ? newName
            : '$newName.$extension';
        final newPath = '$dir/$safeName';

        // Rename the file on disk
        await oldFile.rename(newPath);

        // Create updated model with new name and path
        final updatedFile = FileModel(
          id: file.id,
          name: safeName,
          path: newPath,
          type: file.type,
          createdAt: file.createdAt,
          sizeInBytes: file.sizeInBytes,
          thumbnailPath: file.thumbnailPath,
          tags: file.tags,
        );
        files[index] = updatedFile;
        await _saveFiles(files);
      }
    }
  }

  Future<List<FileModel>> searchFiles(String query) async {
    final files = await getAllFiles();
    final lowerQuery = query.toLowerCase();
    return files
        .where(
          (file) =>
              file.name.toLowerCase().contains(lowerQuery) ||
              (file.tags?.any(
                    (tag) => tag.toLowerCase().contains(lowerQuery),
                  ) ??
                  false),
        )
        .toList();
  }

  Future<void> _saveFiles(List<FileModel> files) async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = files.map((file) => jsonEncode(file.toJson())).toList();
    await prefs.setStringList(_filesKey, filesJson);
  }

  Future<String> getUniqueFilePath(String fileName) async {
    final dir = await _appDirectory;
    String filePath = '$dir/$fileName';
    int counter = 1;
    while (await File(filePath).exists()) {
      final extension = fileName.split('.').last;
      final nameWithoutExt = fileName.substring(
        0,
        fileName.length - extension.length - 1,
      );
      filePath = '$dir/${nameWithoutExt}_$counter.$extension';
      counter++;
    }
    return filePath;
  }

  Future<int> getCacheSize() async {
    final dir = await _appDirectory;
    final directory = Directory(dir);
    int totalSize = 0;
    if (await directory.exists()) {
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }
    return totalSize;
  }

  Future<void> clearCache() async {
    final dir = await _appDirectory;
    final directory = Directory(dir);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_filesKey);
  }
}
