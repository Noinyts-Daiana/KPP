import '../models/travel_models.dart';

abstract class TripListEvent {
  const TripListEvent();
}

class FetchTripsEvent extends TripListEvent {
  const FetchTripsEvent();
}

class TripsUpdatedEvent extends TripListEvent {
  final List<Trip> trips;
  const TripsUpdatedEvent(this.trips);
}

class TripsLoadingFailedEvent extends TripListEvent {
  final String error;
  const TripsLoadingFailedEvent(this.error);
}