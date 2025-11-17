// lib/models/travel_models.dart
import 'package:cloud_firestore/cloud_firestore.dart'; 

class Item {
  final String id;
  final String name;
  final String category;
  final bool isPacked;

  Item({required this.id, required this.name, required this.category, this.isPacked = false});

  factory Item.fromFirestore(Map<String, dynamic> data, String id) {
    return Item(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      isPacked: data['isPacked'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'category': category, 'isPacked': isPacked};
  }
}

class Note {
  final String id;
  final String text;
  final DateTime creationDate;

  Note({required this.id, required this.text, required this.creationDate});

  factory Note.fromFirestore(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      text: data['text'] ?? '',
      creationDate: (data['creationDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'text': text, 'creationDate': creationDate};
  }
}

class Trip {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  
  final String transportation;
  final String accommodation;
  final double budget;

  Trip({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.destination = '',
    this.transportation = '',
    this.accommodation = '',
    this.budget = 0.0,
  });

  factory Trip.fromFirestore(Map<String, dynamic> data, String id) {
    return Trip(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Untitled Trip',
      startDate: (data['startDate'] as Timestamp).toDate(), 
      endDate: (data['endDate'] as Timestamp).toDate(),
      destination: data['destination'] ?? '',
      
      transportation: data['transportation'] ?? '',
      accommodation: data['accommodation'] ?? '',
      budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
      
      
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'destination': destination,
      
      'transportation': transportation,
      'accommodation': accommodation,
      'budget': budget,
      
    };
  }

  Trip copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    String? transportation, 
    String? accommodation,  
    double? budget,         
    String? plannedActivities, // ДОДАНО
    String? documents,         // ДОДАНО
    List<Item>? packingList,
    List<Note>? notes,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      
      transportation: transportation ?? this.transportation,
      accommodation: accommodation ?? this.accommodation,
      budget: budget ?? this.budget,
      
    );
  }
}