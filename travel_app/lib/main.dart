import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/firebase_options.dart';

// Репозиторії
import 'repositories/auth_repository.dart';
import 'repositories/trips_repository.dart';
import 'repositories/notes_repository.dart';
import 'repositories/items_repository.dart';

// Екрани
import 'views/main_view.dart';
import 'views/sign_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),

        RepositoryProvider<TripsRepository>(
          create: (_) => FirestoreTripsRepository(),
        ),

        RepositoryProvider<NotesRepository>(
          create: (_) => FirestoreNotesRepository(),
        ),

        RepositoryProvider<ItemsRepository>(
          create: (_) => FirestoreItemsRepository(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,   
      title: 'Travel App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: context.read<AuthRepository>().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            return MainView(userId: user.uid);
          }

          return const SignView();
        },
      ),
    );
  }
}
