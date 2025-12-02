import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/trips_repository.dart';
import '../repositories/notes_repository.dart';
import '../repositories/items_repository.dart';
import 'trip_list_view.dart';
import 'note_list_view.dart';
import 'item_list_view.dart';
import '../bloc/trip_list_bloc.dart';
import '../bloc/note_list_bloc.dart';
import '../bloc/item_list_bloc.dart';
import '../bloc/trip_list_event.dart';

class MainView extends StatelessWidget {
  final String userId;
  const MainView({super.key, required this.userId});

  Widget _buildMainButton(BuildContext context, String text, Widget destinationView) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => destinationView),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xB700295E),
        minimumSize: const Size(289, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripsRepository = context.read<TripsRepository>();
    final notesRepository = context.read<NotesRepository>();
    final itemsRepository = context.read<ItemsRepository>();

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
              Container(
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
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 28),
                        SizedBox(width: 16),
                        Icon(Icons.logout, color: Colors.white, size: 28),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.flight),
                        SizedBox(width: 8),
                        Text('Scheduled trips:'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('No planned trips'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    // Trips
                    _buildMainButton(
                      context,
                      'Open a list of trip',
                      BlocProvider(
                        create: (_) => TripListBloc(tripsRepository, userId)
                          ..add(FetchTripsEvent()), // без const
                        child: TripListView(userId: userId),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Items
                    _buildMainButton(
                      context,
                      'Open a list of items',
                      BlocProvider(
                        create: (_) => ItemListBloc(itemsRepository, userId)
                          ..add(FetchItemsEvent()), // без const
                        child: ItemListView(userId: userId),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Notes
                    _buildMainButton(
                      context,
                      'Open notes',
                      BlocProvider(
                        create: (_) => NoteListBloc(notesRepository, userId)
                          ..add(FetchNotesEvent()), // без const
                        child: NoteListView(userId: userId),
                      ),
                    ),
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
