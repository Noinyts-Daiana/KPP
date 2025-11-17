// lib/bloc/note_list_state.dart
import '../models/travel_models.dart';

abstract class NoteState {
  final List<Note> data;
  const NoteState({required this.data});
}

class NoteInitialState extends NoteState {
  NoteInitialState() : super(data: []);
}

class NoteLoadingState extends NoteState {
  const NoteLoadingState({required super.data});
}

class NoteDataState extends NoteState {
  const NoteDataState({required super.data});
}

class NoteErrorState extends NoteState {
  final String error;
  const NoteErrorState({required this.error, required super.data});
}