import 'dart:io'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart'; 
import '../models/travel_models.dart';

abstract class ItemsRepository {
  Stream<List<Item>> getItems(String userId);
  
  Future<void> addItem(Item item, String userId, {XFile? imageFile});
  Future<void> updateItem(Item item, {XFile? imageFile});

  Future<void> deleteItem(String itemId);
}

class FirestoreItemsRepository implements ItemsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<List<Item>> getItems(String userId) {
    return _firestore
        .collection('all_items')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('items_images/$fileName');

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        final task = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        return await task.ref.getDownloadURL();
      } else {
        final task = await ref.putFile(File(image.path));
        return await task.ref.getDownloadURL();
      }
    } catch (e) {
      print("Помилка завантаження фото: $e");
      rethrow;
    }
  }

  @override
  Future<void> addItem(Item item, String userId, {XFile? imageFile}) async {
    String? imageUrl = item.imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    final docRef = _firestore.collection('all_items').doc();
    await docRef.set(item.toFirestore()
      ..['userId'] = userId
      ..['imageUrl'] = imageUrl);
  }

  @override
  Future<void> updateItem(Item item, {XFile? imageFile}) async {
    String? imageUrl = item.imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    await _firestore.collection('all_items').doc(item.id).update({
      ...item.toFirestore(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('all_items').doc(itemId).delete();
  }
}