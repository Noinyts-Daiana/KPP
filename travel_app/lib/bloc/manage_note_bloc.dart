import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/travel_models.dart';
import '../repositories/notes_repository.dart';

abstract class ManageNoteState {}
class ManageNoteInitial extends ManageNoteState {} 
class ManageNoteProcessing extends ManageNoteState {} 
class ManageNoteSuccess extends ManageNoteState {}
class ManageNoteFailure extends ManageNoteState {
  final String error;
  ManageNoteFailure(this.error);
}

abstract class ManageNoteEvent {}

class SaveNoteEvent extends ManageNoteEvent {
  final Note note;
  final bool isNew; 
  SaveNoteEvent(this.note, {required this.isNew});
}


class ManageNoteBloc extends Bloc<ManageNoteEvent, ManageNoteState> {
  final NotesRepository _repository;
  final String userId; 

  ManageNoteBloc(this._repository, this.userId) : super(ManageNoteInitial()) {
    on<SaveNoteEvent>(_onSaveNote);
  }

  Future<void> _onSaveNote(
    SaveNoteEvent event,
    Emitter<ManageNoteState> emit,
  ) async {
    emit(ManageNoteProcessing()); 
    await Future.delayed(const Duration(milliseconds: 500)); 

    try {
      if (event.isNew) {
        await _repository.addNote(event.note, userId); 
      } else {
        await _repository.updateNote(event.note);
      }
      emit(ManageNoteSuccess()); 
    } catch (e) {
      emit(ManageNoteFailure('Failed to save note: ${e.toString()}')); 
    }
  }
}