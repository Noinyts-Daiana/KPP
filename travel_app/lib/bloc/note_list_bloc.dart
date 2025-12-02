import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/notes_repository.dart';
import '../models/travel_models.dart';
import 'note_list_state.dart'; 

abstract class NoteListEvent {
  const NoteListEvent();
}

class FetchNotesEvent extends NoteListEvent {
  const FetchNotesEvent();
}

class NotesUpdatedEvent extends NoteListEvent {
  final List<Note> notes;
  const NotesUpdatedEvent(this.notes);
}

class NotesLoadingFailedEvent extends NoteListEvent {
  final String error;
  const NotesLoadingFailedEvent(this.error);
}

class NoteListBloc extends Bloc<NoteListEvent, NoteState> {
  final NotesRepository _repository;
  final String userId; 
  StreamSubscription? _notesSubscription;

  NoteListBloc(this._repository, this.userId) : super(NoteInitialState()) {
    on<FetchNotesEvent>(_onFetchNotes);
    on<NotesUpdatedEvent>(_onNotesUpdated);
    on<NotesLoadingFailedEvent>(_onNotesLoadingFailed);
    add(const FetchNotesEvent()); 
  }

  Future<void> _onFetchNotes(
    FetchNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoadingState(data: state.data));
    await _notesSubscription?.cancel();

    try {
      _notesSubscription = _repository.getNotes(userId)
          .listen(
        (notes) {
          add(NotesUpdatedEvent(notes));
        },
        onError: (e) {
          add(NotesLoadingFailedEvent(e.toString()));
        },
      );
    } catch (e) {
      emit(NoteErrorState(error: e.toString(), data: state.data));
    }
  }

  void _onNotesUpdated(
    NotesUpdatedEvent event,
    Emitter<NoteState> emit,
  ) {
    emit(NoteDataState(data: event.notes));
  }

  void _onNotesLoadingFailed(
    NotesLoadingFailedEvent event,
    Emitter<NoteState> emit,
  ) {
    emit(NoteErrorState(error: event.error, data: state.data));
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}