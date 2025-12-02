import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; 
import '../models/travel_models.dart';
import '../repositories/items_repository.dart';

abstract class ManageItemEvent {}

class SaveItemEvent extends ManageItemEvent {
  final Item item;
  final bool isNew;
  
  final XFile? imageFile; 

  SaveItemEvent(this.item, {required this.isNew, this.imageFile});
}

abstract class ManageItemState {}
class ManageItemInitial extends ManageItemState {}
class ManageItemProcessing extends ManageItemState {}
class ManageItemSuccess extends ManageItemState {}
class ManageItemFailure extends ManageItemState {
  final String error;
  ManageItemFailure(this.error);
}

class ManageItemBloc extends Bloc<ManageItemEvent, ManageItemState> {
  final ItemsRepository repository;
  final String userId;

  ManageItemBloc(this.repository, this.userId) : super(ManageItemInitial()) {
    on<SaveItemEvent>((event, emit) async {
      emit(ManageItemProcessing());
      try {
        if (event.isNew) {
          await repository.addItem(event.item, userId, imageFile: event.imageFile);
        } else {
          await repository.updateItem(event.item, imageFile: event.imageFile);
        }
        emit(ManageItemSuccess());
      } catch (e) {
        emit(ManageItemFailure(e.toString()));
      }
    });
  }
}