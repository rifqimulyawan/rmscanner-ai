import 'package:equatable/equatable.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';

enum FileType { pdf, image, text }

class FileModel extends Equatable {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final DateTime createdAt;
  final int sizeInBytes;
  final String? thumbnailPath;
  final List<String>? tags;
  const FileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.createdAt,
    required this.sizeInBytes,
    this.thumbnailPath,
    this.tags,
  });
  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String formattedDate(AppLocalizations loc) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) return loc.tr('just_now');
        return '${difference.inMinutes} ${loc.tr('min_ago')}';
      }
      return '${difference.inHours} ${loc.tr('hours_ago')}';
    } else if (difference.inDays == 1) {
      return loc.tr('yesterday');
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${loc.tr('days_ago')}';
    }
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'sizeInBytes': sizeInBytes,
    'thumbnailPath': thumbnailPath,
    'tags': tags,
  };
  factory FileModel.fromJson(Map<String, dynamic> json) => FileModel(
    id: json['id'],
    name: json['name'],
    path: json['path'],
    type: FileType.values.firstWhere((e) => e.name == json['type']),
    createdAt: DateTime.parse(json['createdAt']),
    sizeInBytes: json['sizeInBytes'],
    thumbnailPath: json['thumbnailPath'],
    tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
  );
  @override
  List<Object?> get props => [id, name, path, type, createdAt, sizeInBytes];
}
