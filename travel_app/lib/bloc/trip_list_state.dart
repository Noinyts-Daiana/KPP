import '../models/travel_models.dart';

abstract class TripState {
  final List<Trip> data;
  const TripState({required this.data});
}

class TripInitialState extends TripState {
  TripInitialState() : super(data: []);
}

class TripLoadingState extends TripState {
  const TripLoadingState({required super.data});
}

class TripDataState extends TripState {
  const TripDataState({required super.data});
}

class TripErrorState extends TripState {
  final String error;
  const TripErrorState({required this.error, required super.data});
}