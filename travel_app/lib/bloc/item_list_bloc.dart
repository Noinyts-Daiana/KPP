// lib/bloc/item_list_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/items_repository.dart';
import '../models/travel_models.dart';
import 'item_list_state.dart'; 

// --- ПОДІЇ ---
abstract class ItemListEvent {
  const ItemListEvent();
}

class FetchItemsEvent extends ItemListEvent {
  const FetchItemsEvent();
}

class ItemsUpdatedEvent extends ItemListEvent {
  final List<Item> items;
  const ItemsUpdatedEvent(this.items);
}

class ItemsLoadingFailedEvent extends ItemListEvent {
  final String error;
  const ItemsLoadingFailedEvent(this.error);
}

// --- BLoC ---
class ItemListBloc extends Bloc<ItemListEvent, ItemState> {
  final ItemsRepository _repository;
  final String userId; // 👈 Зберігаємо реальний UID
  StreamSubscription? _itemsSubscription;

  // 💡 ОНОВЛЕНО: BLoC тепер вимагає userId
  ItemListBloc(this._repository, this.userId) : super(ItemInitialState()) {
    on<FetchItemsEvent>(_onFetchItems);
    on<ItemsUpdatedEvent>(_onItemsUpdated);
    on<ItemsLoadingFailedEvent>(_onItemsLoadingFailed);
    add(const FetchItemsEvent()); // Початкове завантаження
  }

  Future<void> _onFetchItems(
    FetchItemsEvent event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoadingState(data: state.data));
    await _itemsSubscription?.cancel();

    try {
      // 💡 ОНОВЛЕНО: Використовуємо реальний 'userId'
      _itemsSubscription = _repository.getItems(userId)
          .listen(
        (items) {
          add(ItemsUpdatedEvent(items));
        },
        onError: (e) {
          add(ItemsLoadingFailedEvent(e.toString()));
        },
      );
    } catch (e) {
      emit(ItemErrorState(error: e.toString(), data: state.data));
    }
  }

  void _onItemsUpdated(
    ItemsUpdatedEvent event,
    Emitter<ItemState> emit,
  ) {
    emit(ItemDataState(data: event.items));
  }

  void _onItemsLoadingFailed(
    ItemsLoadingFailedEvent event,
    Emitter<ItemState> emit,
  ) {
    emit(ItemErrorState(error: event.error, data: state.data));
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    return super.close();
  }
}