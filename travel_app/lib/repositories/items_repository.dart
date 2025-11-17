// lib/repositories/items_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_models.dart';

abstract class ItemsRepository {
  Stream<List<Item>> getItems(String userId);
  Future<void> addItem(Item item, String userId); // Потрібен userId
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String itemId);
}

class FirestoreItemsRepository implements ItemsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Item>> getItems(String userId) {
    // 💡 ВИПРАВЛЕНО: Використовуємо реальний userId
    return _firestore
        .collection('all_items') 
        .where('userId', isEqualTo: userId) 
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Item.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addItem(Item item, String userId) async {
    final docRef = _firestore.collection('all_items').doc();
    // 💡 ВИПРАВЛЕНО: Додаємо реальний userId
    await docRef.set(item.toFirestore()..['userId'] = userId);
  }

  @override
  Future<void> updateItem(Item item) async {
    await _firestore.collection('all_items').doc(item.id).update(item.toFirestore());
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('all_items').doc(itemId).delete();
  }
}