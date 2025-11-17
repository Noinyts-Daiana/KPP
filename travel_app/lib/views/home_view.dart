// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Імпортуємо ВСІ BLoC'и, які нам потрібно передати
import '../bloc/trip_list_bloc.dart';
import '../bloc/note_list_bloc.dart';
import '../bloc/item_list_bloc.dart';
// Імпортуємо ВСІ екрани
import 'trip_list_view.dart';
import 'note_list_view.dart'; // 👈 ДОДАНО
import 'item_list_view.dart'; // 👈 ДОДАНО

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Widget _buildMainButton(BuildContext context, String text, Widget destinationView, BlocBase blocToProvide) {
    // 1. Читаємо BLoC, який був наданий у main.dart
    //    final tripListBloc = context.read<TripListBloc>();
    //    ^ Це не потрібно, якщо ми передаємо BLoC у функцію

    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (routeContext) {
              // 2. Використовуємо BlocProvider.value, щоб передати ВІДПОВІДНИЙ BLoC
              //    на новий маршрут (TripListView, NoteListView, ItemListView)
              return BlocProvider.value(
                value: blocToProvide, // Передаємо BLoC, який потрібен цьому екрану
                child: destinationView, 
              );
            },
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xB700295E),
        minimumSize: const Size(289, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Створюємо екземпляри ВСІХ екранів
    final tripListView = const TripListView(); 
    final noteListView = const NoteListView(); // 👈 ДОДАНО
    final itemListView = const ItemListView(); // 👈 ДОДАНО

    // Отримуємо ВСІ BLoC'и з контексту
    final tripListBloc = context.read<TripListBloc>();
    final noteListBloc = context.read<NoteListBloc>(); // 👈 ДОДАНО
    final itemListBloc = context.read<ItemListBloc>(); // 👈 ДОДАНО
    
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/HomeScreenBack.jpg', 
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Container( /* Header GRAB AND GO */
                height: 100,
                color: const Color(0xFF00295E),
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'GRAB AND GO',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'HoltwoodOneSC',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(children: [
                      Icon(Icons.person, color: Colors.white, size: 28),
                      SizedBox(width: 16),
                      Icon(Icons.logout, color: Colors.white, size: 28),
                    ]),
                  ],
                ),
              ),
              Container( /* Scheduled trips info */
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(children: [
                      Icon(Icons.flight, color: Color(0xFF00295E)),
                      SizedBox(width: 8),
                      Text('Scheduled trips:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.calendar_today, color: Color(0xFF00295E)),
                      SizedBox(width: 8),
                      Text('No planned trips', style: TextStyle(color: Color(0xFF00295E))),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center( /* Main Buttons */
                child: Column(
                  children: [
                    // 👇 ВИПРАВЛЕНО: Передаємо правильний BLoC та правильний View
                    _buildMainButton(context, 'Open a list of trip', tripListView, tripListBloc),
                    const SizedBox(height: 20),
                    _buildMainButton(context, 'Open a list of items', itemListView, itemListBloc),
                    const SizedBox(height: 20),
                    _buildMainButton(context, 'Open notes', noteListView, noteListBloc),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}