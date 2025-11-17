// lib/repositories/notes_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_models.dart';

abstract class NotesRepository {
  Stream<List<Note>> getNotes(String userId);
  Future<void> addNote(Note note, String userId); // 👈 Потрібен userId для запису
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String noteId);
}

class FirestoreNotesRepository implements NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Note>> getNotes(String userId) {
    // 💡 ВИПРАВЛЕНО: Використовуємо реальний userId
    return _firestore
        .collection('all_notes') 
        .where('userId', isEqualTo: userId) 
        .orderBy('creationDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addNote(Note note, String userId) async {
    final docRef = _firestore.collection('all_notes').doc();
    // 💡 ВИПРАВЛЕНО: Додаємо реальний userId при створенні
    // (Припускаємо, що модель Note не має 'userId', тому додаємо його тут)
    await docRef.set(note.toFirestore()..['userId'] = userId);
  }

  @override
  Future<void> updateNote(Note note) async {
    // (Припускаємо, що оновлення не змінює userId)
    await _firestore.collection('all_notes').doc(note.id).update(note.toFirestore());
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('all_notes').doc(noteId).delete();
  }
}