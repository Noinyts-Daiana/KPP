import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/travel_models.dart';
import '../repositories/trips_repository.dart';

abstract class ManageTripState {}
class ManageTripInitial extends ManageTripState {} 
class ManageTripProcessing extends ManageTripState {} 
class ManageTripSuccess extends ManageTripState {}
class ManageTripFailure extends ManageTripState {
  final String error;
  ManageTripFailure(this.error);
}

abstract class ManageTripEvent {}

class SaveTripEvent extends ManageTripEvent {
  final Trip trip; 
  final bool isNew;  
  
  SaveTripEvent(this.trip, {required this.isNew});
}


class ManageTripBloc extends Bloc<ManageTripEvent, ManageTripState> {
  final TripsRepository _repository;
  final String _userId = FirebaseAuth.instance.currentUser!.uid; 

  ManageTripBloc(this._repository) : super(ManageTripInitial()) {
    on<SaveTripEvent>(_onSaveTrip);
  }

  Future<void> _onSaveTrip(
    SaveTripEvent event,
    Emitter<ManageTripState> emit,
  ) async {
    emit(ManageTripProcessing()); 
    await Future.delayed(const Duration(milliseconds: 500)); 

    try {
      final tripToSave = event.trip.copyWith(userId: _userId);

      if (event.isNew) {
        await _repository.addTrip(tripToSave);
      } else {
        await _repository.updateTrip(tripToSave);
      }
      emit(ManageTripSuccess()); 
    } catch (e) {
      emit(ManageTripFailure('Failed to save trip: ${e.toString()}')); 
    }
  }
}