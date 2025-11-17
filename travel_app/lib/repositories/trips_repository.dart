// lib/repositories/trips_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_models.dart';

abstract class TripsRepository {
  Stream<List<Trip>> getTrips(String userId); 
  Future<void> addTrip(Trip trip);
  Future<void> updateTrip(Trip trip);
  Future<void> deleteTrip(String tripId);
}

class FirestoreTripsRepository implements TripsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ❌ ХАРДКОД-КОНСТАНТУ ВИДАЛЕНО
  // static const String TEST_OWNER_UID = 'Daiana'; 

  @override
  Stream<List<Trip>> getTrips(String userId) {
    // 💡 ВИПРАВЛЕНО: Використовуємо 'userId', переданий як аргумент
    return _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId) // 👈 Фільтруємо за РЕАЛЬНИМ ID
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Trip.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addTrip(Trip trip) async {
    final docRef = _firestore.collection('trips').doc();
    // 💡 ВИПРАВЛЕНО: Ми очікуємо, що 'trip' вже містить коректний 'userId', 
    // який був встановлений у ManageTripBloc/TripFormView
    Trip newTrip = trip.copyWith(id: docRef.id); 
    await docRef.set(newTrip.toFirestore());
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toFirestore());
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).delete();
  }
}