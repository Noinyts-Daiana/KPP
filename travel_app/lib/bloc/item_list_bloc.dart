import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/travel_models.dart';
import '../repositories/items_repository.dart';

abstract class ItemEvent {}
class FetchItemsEvent extends ItemEvent {}

abstract class ItemState {
  final List<Item> data;
  const ItemState(this.data);
}
class ItemLoadingState extends ItemState {
  const ItemLoadingState(List<Item> data) : super(data);
}
class ItemLoadedState extends ItemState {
  const ItemLoadedState(List<Item> data) : super(data);
}
class ItemErrorState extends ItemState {
  final String error;
  const ItemErrorState(this.error, List<Item> data) : super(data);
}

class ItemListBloc extends Bloc<ItemEvent, ItemState> {
  final ItemsRepository repository;
  final String userId;

  ItemListBloc(this.repository, this.userId) : super(const ItemLoadingState([])) {
    on<FetchItemsEvent>((event, emit) async {
      emit(const ItemLoadingState([]));
      try {
        repository.getItems(userId).listen((items) {
          add(_ItemsUpdatedEvent(items));
        });
      } catch (e) {
        emit(ItemErrorState(e.toString(), []));
      }
    });

    on<_ItemsUpdatedEvent>((event, emit) {
      emit(ItemLoadedState(event.items));
    });
  }
}

class _ItemsUpdatedEvent extends ItemEvent {
  final List<Item> items;
  _ItemsUpdatedEvent(this.items);
}
