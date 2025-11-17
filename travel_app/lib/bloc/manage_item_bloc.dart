// lib/bloc/manage_item_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/travel_models.dart';
import '../repositories/items_repository.dart';

// --- СТАНИ ---
abstract class ManageItemState {}
class ManageItemInitial extends ManageItemState {} 
class ManageItemProcessing extends ManageItemState {} 
class ManageItemSuccess extends ManageItemState {}
class ManageItemFailure extends ManageItemState {
  final String error;
  ManageItemFailure(this.error);
}

// --- ПОДІЇ ---
abstract class ManageItemEvent {}

class SaveItemEvent extends ManageItemEvent {
  final Item item;
  final bool isNew; 
  SaveItemEvent(this.item, {required this.isNew});
}


class ManageItemBloc extends Bloc<ManageItemEvent, ManageItemState> {
  final ItemsRepository _repository;
  final String userId; // 👈 Потрібен для addItem

  ManageItemBloc(this._repository, this.userId) : super(ManageItemInitial()) {
    on<SaveItemEvent>(_onSaveItem);
  }

  Future<void> _onSaveItem(
    SaveItemEvent event,
    Emitter<ManageItemState> emit,
  ) async {
    emit(ManageItemProcessing()); 
    await Future.delayed(const Duration(milliseconds: 500)); 

    try {
      if (event.isNew) {
        // 💡 ВИПРАВЛЕНО: Передаємо userId в addItem
        await _repository.addItem(event.item, userId); 
      } else {
        await _repository.updateItem(event.item);
      }
      emit(ManageItemSuccess()); 
    } catch (e) {
      emit(ManageItemFailure('Failed to save item: ${e.toString()}')); 
    }
  }
}