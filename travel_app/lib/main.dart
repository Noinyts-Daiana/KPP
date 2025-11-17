import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Імпорти BLoC'ів та Репозиторіїв
import '../repositories/auth_repository.dart';
import '../repositories/items_repository.dart';
import '../repositories/notes_repository.dart';
import '../repositories/trips_repository.dart';
import '../bloc/item_list_bloc.dart';
import '../bloc/note_list_bloc.dart';
import '../bloc/trip_list_bloc.dart';
import '../bloc/trip_list_event.dart';

// Імпорти Екранів
import './views/home_view.dart'; // Ваш головний екран (MainView)
import './views/sign_view.dart'; // Ваш екран входу

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 1. Слухаємо потік стану автентифікації з AuthRepository
      stream: context.read<AuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        
        // Поки чекаємо на з'єднання
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Якщо користувач АВТЕНТИФІКОВАНИЙ (snapshot.hasData)
        if (snapshot.hasData) {
          final user = snapshot.data!;
          
          // 3. 💡 Надаємо BLoC'и для даних ТІЛЬКИ тут, 
          //    передаючи їм РЕАЛЬНИЙ UID
          return MultiBlocProvider(
            providers: [
              BlocProvider<TripListBloc>(
                create: (context) => TripListBloc(
                  context.read<TripsRepository>(),
                  user.uid, // 👈 Передаємо реальний UID
                )..add(const FetchTripsEvent()), 
              ),
              BlocProvider<NoteListBloc>( 
                create: (context) => NoteListBloc(
                  context.read<NotesRepository>(),
                  user.uid, // 👈 Передаємо реальний UID
                ),
              ),
              BlocProvider<ItemListBloc>( 
                create: (context) => ItemListBloc(
                  context.read<ItemsRepository>(),
                  user.uid, // 👈 Передаємо реальний UID
                ),
              ),
            ],
            // 4. Показуємо головний екран (HomeView/MainView)
            child: const HomeView(), 
          );
        }
        
        // 5. Якщо не автентифікований
        return const SignView(); // 👈 Використовуємо ваш SignView
      },
    );
  }
}