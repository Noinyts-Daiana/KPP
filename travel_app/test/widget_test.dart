import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:travel_app/main.dart';
import 'package:travel_app/repositories/trips_repository.dart';
import 'package:travel_app/repositories/notes_repository.dart'; 
import 'package:travel_app/repositories/items_repository.dart'; 

import 'package:travel_app/bloc/trip_list_bloc.dart';
import 'package:travel_app/bloc/trip_list_event.dart';
import 'package:travel_app/bloc/trip_list_state.dart';
import 'package:travel_app/bloc/note_list_bloc.dart';
import 'package:travel_app/bloc/note_list_state.dart';
import 'package:travel_app/bloc/item_list_bloc.dart';

import 'package:travel_app/views/trip_list_view.dart';
import 'package:travel_app/views/home_view.dart';

class MockTripsRepository extends Mock implements TripsRepository {}
class MockNotesRepository extends Mock implements NotesRepository {}
class MockItemsRepository extends Mock implements ItemsRepository {}

class MockTripListBloc extends MockBloc<TripListEvent, TripState> implements TripListBloc {}
class MockNoteListBloc extends MockBloc<NoteListEvent, NoteState> implements NoteListBloc {}
class MockItemListBloc extends MockBloc<ItemEvent, ItemState> implements ItemListBloc {}

class MockBloc<Event, State> extends Mock implements Bloc<Event, State> {}

void main() {
  late MockTripsRepository mockTripsRepository;
  late MockNotesRepository mockNotesRepository; 
  late MockItemsRepository mockItemsRepository; 

  late MockTripListBloc mockTripListBloc;
  late MockNoteListBloc mockNoteListBloc;
  late MockItemListBloc mockItemListBloc;

  setUp(() {
    mockTripsRepository = MockTripsRepository();
    mockNotesRepository = MockNotesRepository(); 
    mockItemsRepository = MockItemsRepository(); 

    mockTripListBloc = MockTripListBloc();
    mockNoteListBloc = MockNoteListBloc();
    mockItemListBloc = MockItemListBloc();

    when(() => mockTripListBloc.state).thenReturn(TripDataState(data: [])); 
    when(() => mockTripListBloc.stream).thenAnswer((_) => Stream.value(TripDataState(data: [])));
    when(() => mockTripListBloc.add(any())).thenReturn(null);
    
    when(() => mockNoteListBloc.state).thenReturn(NoteDataState(data: [])); 
    when(() => mockNoteListBloc.stream).thenAnswer((_) => Stream.value(NoteDataState(data: [])));
    when(() => mockNoteListBloc.add(any())).thenReturn(null);
    
    when(() => mockItemListBloc.state).thenReturn(const ItemLoadedState([])); 
    when(() => mockItemListBloc.stream).thenAnswer((_) => Stream.value(const ItemLoadedState([])));
    when(() => mockItemListBloc.add(any())).thenReturn(null);
  });

  testWidgets('Should navigate from HomeView to TripListView on button tap', (WidgetTester tester) async {
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TripsRepository>.value(value: mockTripsRepository),
          RepositoryProvider<NotesRepository>.value(value: mockNotesRepository),
          RepositoryProvider<ItemsRepository>.value(value: mockItemsRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TripListBloc>.value(value: mockTripListBloc),
            BlocProvider<NoteListBloc>.value(value: mockNoteListBloc),
            BlocProvider<ItemListBloc>.value(value: mockItemListBloc),
          ],
          child: MyApp(
          ),
        ),
      ),
    );
    
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('GRAB AND GO'), findsOneWidget); 

    final tripListButton = find.widgetWithText(ElevatedButton, 'Open a list of trip');
    await tester.tap(tripListButton);
    await tester.pumpAndSettle();

    expect(find.byType(TripListView), findsOneWidget);
    expect(find.text('LIST OF TRIP'), findsOneWidget);
  });
}