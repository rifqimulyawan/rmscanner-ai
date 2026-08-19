import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final FileService fileService;
  List<FileModel> _allFiles = [];
  FilesBloc({required this.fileService}) : super(FilesInitial()) {
    on<LoadFiles>(_onLoadFiles);
    on<LoadFilesByType>(_onLoadFilesByType);
    on<SearchFiles>(_onSearchFiles);
    on<SortFiles>(_onSortFiles);
    on<DeleteFile>(_onDeleteFile);
    on<RenameFile>(_onRenameFile);
    on<AddFile>(_onAddFile);
  }
  Future<void> _onLoadFiles(LoadFiles event, Emitter<FilesState> emit) async {
    emit(FilesLoading());
    try {
      _allFiles = await fileService.getAllFiles();
      emit(FilesLoaded(_allFiles));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> _onLoadFilesByType(
    LoadFilesByType event,
    Emitter<FilesState> emit,
  ) async {
    emit(FilesLoading());
    try {
      final files = await fileService.getFilesByType(event.type);
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> _onSearchFiles(
    SearchFiles event,
    Emitter<FilesState> emit,
  ) async {
    emit(FilesLoading());
    try {
      final files = await fileService.searchFiles(event.query);
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  void _onSortFiles(SortFiles event, Emitter<FilesState> emit) {
    if (state is FilesLoaded) {
      final currentFiles = List<FileModel>.from((state as FilesLoaded).files);
      switch (event.sortType) {
        case FileSortType.date:
          currentFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case FileSortType.name:
          currentFiles.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          break;
        case FileSortType.size:
          currentFiles.sort((a, b) => b.sizeInBytes.compareTo(a.sizeInBytes));
          break;
      }
      emit(FilesLoaded(currentFiles));
    }
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<FilesState> emit) async {
    try {
      await fileService.deleteFile(event.fileId);
      add(LoadFiles());
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> _onRenameFile(RenameFile event, Emitter<FilesState> emit) async {
    try {
      await fileService.renameFile(event.fileId, event.newName);
      add(LoadFiles());
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> _onAddFile(AddFile event, Emitter<FilesState> emit) async {
    try {
      await fileService.saveFile(event.file);
      add(LoadFiles());
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }
}
