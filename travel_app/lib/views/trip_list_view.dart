import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../bloc/trip_list_bloc.dart';
import '../bloc/trip_list_event.dart';
import '../bloc/trip_list_state.dart';
import '../models/travel_models.dart';
import '../repositories/trips_repository.dart';
import './trip_details_view.dart';
import 'trip_form_view.dart'; 

const Color primaryColor = Color(0xFF0D47A1); 
const Color accentColor = Color(0xFFF5F5F5); 

class TripListView extends StatelessWidget {
  const TripListView({super.key});

  // МЕТОД ФОРМИ: Тепер він приймає TripsRepository, щоб його можна було передати.
  void _showTripForm(BuildContext context, TripsRepository tripsRepository, {Trip? trip}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        // ЯВНО НАДАЄМО TripsRepository у контекст модального вікна
        return RepositoryProvider.value(
          value: tripsRepository,
          child: TripFormView(initialTrip: trip),
        );
      },
    );
  }

  // МЕТОД ЕЛЕМЕНТУ СПИСКУ: Приймає репозиторій для виклику форми
  Widget _buildTripListItem(BuildContext context, Trip trip, {required TripsRepository tripsRepository}) {
    final dateFormat = DateFormat('d.MM.yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        title: Text(
          trip.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        subtitle: Text(
          dateFormat.format(trip.startDate),
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TripDetailsView(trip: trip)),
          );
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: primaryColor), 
              onPressed: () {
                // ВИКЛИК: Передаємо репозиторій
                _showTripForm(context, tripsRepository, trip: trip); 
              }
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red), 
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Імітація видалення поїздки')),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIST OF TRIP', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined), 
            onPressed: () {
              // ЧИТАЄМО РЕПОЗИТОРІЙ З НАЙБІЛЬШ БЕЗПЕЧНОГО КОНТЕКСТУ (build методу)
              final tripsRepository = context.read<TripsRepository>(); 
              _showTripForm(context, tripsRepository); 
            }
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/HomeScreenBack.jpg'), 
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
          ),
        ),
        child: BlocBuilder<TripListBloc, TripState>(
          builder: (builderContext, state) { 
            
            final tripListBloc = builderContext.read<TripListBloc>();
            // ЧИТАЄМО РЕПОЗИТОРІЙ ТУТ (де він гарантовано доступний)
            final tripsRepository = builderContext.read<TripsRepository>(); 

            if (state is TripLoadingState && state.data.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }

            if (state is TripErrorState && state.data.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Помилка завантаження даних!',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(state.error, textAlign: TextAlign.center), 
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => tripListBloc.add(const FetchTripsEvent()), 
                        child: const Text('СПРОБУВАТИ ЩЕ'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.data.isNotEmpty) {
              return ListView.builder(
                itemCount: state.data.length,
                itemBuilder: (context, index) {
                  final trip = state.data[index];
                  // Передаємо репозиторій у кожну картку
                  return _buildTripListItem(context, trip, tripsRepository: tripsRepository);
                },
              );
            }

            return const Center(
              child: Text(
                'Наразі немає запланованих поїздок.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}