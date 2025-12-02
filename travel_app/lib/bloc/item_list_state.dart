import '../models/travel_models.dart';

abstract class ItemState {
  final List<Item> data;
  const ItemState({required this.data});
}

class ItemInitialState extends ItemState {
  ItemInitialState() : super(data: []);
}

class ItemLoadingState extends ItemState {
  const ItemLoadingState({required super.data});
}

class ItemDataState extends ItemState {
  const ItemDataState({required super.data});
}

class ItemErrorState extends ItemState {
  final String error;
  const ItemErrorState({required this.error, required super.data});
}