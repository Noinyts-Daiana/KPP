// lib/bloc/manage_trip_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 Потрібен для UID
import '../models/travel_models.dart';
import '../repositories/trips_repository.dart';


// --- СТАНИ ---
abstract class ManageTripState {}
class ManageTripInitial extends ManageTripState {} 
class ManageTripProcessing extends ManageTripState {} 
class ManageTripSuccess extends ManageTripState {}
class ManageTripFailure extends ManageTripState {
  final String error;
  ManageTripFailure(this.error);
}

// --- ПОДІЇ ---
abstract class ManageTripEvent {}

class SaveTripEvent extends ManageTripEvent {
  final Trip trip; // Дані з форми
  final bool isNew;  // Це нова поїздка чи редагування?
  
  SaveTripEvent(this.trip, {required this.isNew});
}


class ManageTripBloc extends Bloc<ManageTripEvent, ManageTripState> {
  final TripsRepository _repository;
  // 💡 Отримуємо UID з Firebase Auth (це безпечніше, ніж передавати)
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

    // 👇 ВИПРАВЛЕНО: Додано блок try...catch для обробки помилок
    try {
      // Переконуємося, що userId встановлено коректно
      final tripToSave = event.trip.copyWith(userId: _userId);

      if (event.isNew) {
        await _repository.addTrip(tripToSave);
      } else {
        await _repository.updateTrip(tripToSave);
      }
      emit(ManageTripSuccess()); 
    } catch (e) {
      // Обробка помилки, якщо Firestore/Репозиторій не спрацював
      emit(ManageTripFailure('Failed to save trip: ${e.toString()}')); 
    }
  }
}