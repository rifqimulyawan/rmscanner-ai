import 'package:equatable/equatable.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';

enum FileSortType { date, name, size }

abstract class FilesEvent extends Equatable {
  const FilesEvent();
  @override
  List<Object?> get props => [];
}

class LoadFiles extends FilesEvent {}

class LoadFilesByType extends FilesEvent {
  final FileType type;
  const LoadFilesByType(this.type);
  @override
  List<Object?> get props => [type];
}

class SearchFiles extends FilesEvent {
  final String query;
  const SearchFiles(this.query);
  @override
  List<Object?> get props => [query];
}

class SortFiles extends FilesEvent {
  final FileSortType sortType;
  const SortFiles(this.sortType);
  @override
  List<Object?> get props => [sortType];
}

class DeleteFile extends FilesEvent {
  final String fileId;
  const DeleteFile(this.fileId);
  @override
  List<Object?> get props => [fileId];
}

class RenameFile extends FilesEvent {
  final String fileId;
  final String newName;
  const RenameFile(this.fileId, this.newName);
  @override
  List<Object?> get props => [fileId, newName];
}

class AddFile extends FilesEvent {
  final FileModel file;
  const AddFile(this.file);
  @override
  List<Object?> get props => [file];
}
