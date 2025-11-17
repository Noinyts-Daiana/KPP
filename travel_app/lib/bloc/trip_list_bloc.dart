// lib/bloc/trip_list_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/trips_repository.dart';
import 'trip_list_event.dart';
import '/models/travel_models.dart';
import 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripState> {
  final TripsRepository repository; // тепер публічний
  final String userId;
  StreamSubscription<List<Trip>>? _tripsSubscription;

  // ✅ Використовуємо іменовані параметри, щоб не було помилок у BlocProvider
  TripListBloc({
    required this.repository,
    required this.userId,
  }) : super(TripInitialState()) {
    on<FetchTripsEvent>(_onFetchTrips);
    on<TripsUpdatedEvent>(_onTripsUpdated);
    on<TripsLoadingFailedEvent>(_onTripsLoadingFailed);
  }

  Future<void> _onFetchTrips(
    FetchTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoadingState(data: state.data));

    await _tripsSubscription?.cancel(); // відписуємося від попереднього стріму

    try {
      _tripsSubscription = repository.getTrips(userId).listen(
        (trips) {
          add(TripsUpdatedEvent(trips));
        },
        onError: (e) {
          add(TripsLoadingFailedEvent(e.toString()));
        },
      );
    } catch (e) {
      emit(TripErrorState(error: e.toString(), data: state.data));
    }
  }

  void _onTripsUpdated(
    TripsUpdatedEvent event,
    Emitter<TripState> emit,
  ) {
    emit(TripDataState(data: event.trips));
  }

  void _onTripsLoadingFailed(
    TripsLoadingFailedEvent event,
    Emitter<TripState> emit,
  ) {
    emit(TripErrorState(error: event.error, data: state.data));
  }

  @override
  Future<void> close() {
    _tripsSubscription?.cancel();
    return super.close();
  }
}
