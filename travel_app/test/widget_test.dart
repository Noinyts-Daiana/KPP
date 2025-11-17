import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:travel_app/main.dart';
// Import ALL necessary repositories
import 'package:travel_app/repositories/trips_repository.dart';
import 'package:travel_app/repositories/notes_repository.dart'; 
import 'package:travel_app/repositories/items_repository.dart'; 

// Import ALL necessary BLoCs and States
import 'package:travel_app/bloc/trip_list_bloc.dart';
import 'package:travel_app/bloc/trip_list_event.dart';
import 'package:travel_app/bloc/trip_list_state.dart';
import 'package:travel_app/bloc/note_list_bloc.dart';
import 'package:travel_app/bloc/note_list_state.dart';
import 'package:travel_app/bloc/item_list_bloc.dart';
import 'package:travel_app/bloc/item_list_state.dart';

import 'package:travel_app/views/trip_list_view.dart';
import 'package:travel_app/views/home_view.dart';

// --- 1. MOCK CLASSES ---
class MockTripsRepository extends Mock implements TripsRepository {}
class MockNotesRepository extends Mock implements NotesRepository {} // Mock for Notes
class MockItemsRepository extends Mock implements ItemsRepository {} // Mock for Items

// Mocks for BLoCs
class MockTripListBloc extends MockBloc<TripListEvent, TripState> implements TripListBloc {}
class MockNoteListBloc extends MockBloc<NoteListEvent, NoteState> implements NoteListBloc {}
class MockItemListBloc extends MockBloc<ItemListEvent, ItemState> implements ItemListBloc {}

// Generic MockBloc helper
class MockBloc<Event, State> extends Mock implements Bloc<Event, State> {}

void main() {
  // --- 2. DECLARATIONS ---
  late MockTripsRepository mockTripsRepository;
  late MockNotesRepository mockNotesRepository; // 👈 FIX: Declare
  late MockItemsRepository mockItemsRepository; // 👈 FIX: Declare
  
  // BLoC Mocks
  late MockTripListBloc mockTripListBloc;
  late MockNoteListBloc mockNoteListBloc;
  late MockItemListBloc mockItemListBloc;

  setUp(() {
    // --- 3. INITIALIZATION ---
    mockTripsRepository = MockTripsRepository();
    mockNotesRepository = MockNotesRepository(); // 👈 FIX: Initialize
    mockItemsRepository = MockItemsRepository(); // 👈 FIX: Initialize

    mockTripListBloc = MockTripListBloc();
    mockNoteListBloc = MockNoteListBloc();
    mockItemListBloc = MockItemListBloc();

    // Setup default mock behavior for TripListBloc
    when(() => mockTripListBloc.state).thenReturn(TripDataState(data: [])); 
    when(() => mockTripListBloc.stream).thenAnswer((_) => Stream.value(TripDataState(data: [])));
    when(() => mockTripListBloc.add(any())).thenReturn(null);
    
    // Setup default mock behavior for NoteListBloc
    when(() => mockNoteListBloc.state).thenReturn(NoteDataState(data: [])); 
    when(() => mockNoteListBloc.stream).thenAnswer((_) => Stream.value(NoteDataState(data: [])));
    when(() => mockNoteListBloc.add(any())).thenReturn(null);
    
    // Setup default mock behavior for ItemListBloc
    when(() => mockItemListBloc.state).thenReturn(ItemDataState(data: [])); 
    when(() => mockItemListBloc.stream).thenAnswer((_) => Stream.value(ItemDataState(data: [])));
    when(() => mockItemListBloc.add(any())).thenReturn(null);
  });

  // Test navigation from HomeView to TripListView
  testWidgets('Should navigate from HomeView to TripListView on button tap', (WidgetTester tester) async {
    
    // 1. Build the app using the full provider structure from main.dart
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TripsRepository>.value(value: mockTripsRepository),
          RepositoryProvider<NotesRepository>.value(value: mockNotesRepository),
          RepositoryProvider<ItemsRepository>.value(value: mockItemsRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            // Provide the mock BLoCs
            BlocProvider<TripListBloc>.value(value: mockTripListBloc),
            BlocProvider<NoteListBloc>.value(value: mockNoteListBloc),
            BlocProvider<ItemListBloc>.value(value: mockItemListBloc),
          ],
          child: MyApp(
          ),
        ),
      ),
    );
    
    // 3. Verify we are on the HomeView
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('GRAB AND GO'), findsOneWidget); 

    // 4. Find and tap the button
    final tripListButton = find.widgetWithText(ElevatedButton, 'Open a list of trip');
    await tester.tap(tripListButton);
    await tester.pumpAndSettle(); // Wait for navigation

    // 5. Verify navigation was successful
    expect(find.byType(TripListView), findsOneWidget);
    expect(find.text('LIST OF TRIP'), findsOneWidget);
  });
}