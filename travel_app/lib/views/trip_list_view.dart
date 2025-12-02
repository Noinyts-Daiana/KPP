// lib/views/trip_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/bloc/manage_trip_bloc.dart';
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
  final String userId;

  const TripListView({super.key, required this.userId});

void _showTripForm(BuildContext context, TripsRepository tripsRepository, {Trip? trip}) {
  final tripListBloc = context.read<TripListBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: tripListBloc), // ❗ передаємо існуючий TripListBloc
          BlocProvider(
            create: (_) => ManageTripBloc(tripsRepository),
          ),
        ],
        child: TripFormView(initialTrip: trip),
      );
    },
  );
}

  Widget _buildTripListItem(BuildContext context, Trip trip, TripsRepository tripsRepository) {
    final dateFormat = DateFormat('d.MM.yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        title: Text(trip.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        subtitle: Text(dateFormat.format(trip.startDate),
            style: const TextStyle(color: Colors.grey)),
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
                _showTripForm(context, tripsRepository, trip: trip);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Імітація видалення поїздки')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripsRepository = context.read<TripsRepository>();

    return BlocProvider<TripListBloc>(
      create: (_) => TripListBloc(tripsRepository, userId)..add(const FetchTripsEvent()),
      child: Builder(builder: (blocContext) {
        final tripListBloc = blocContext.read<TripListBloc>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('LIST OF TRIP', style: TextStyle(color: Colors.white)),
            backgroundColor: primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () {
                    _showTripForm(blocContext, tripsRepository);
                  }),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/HomeScreenBack.jpg'),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
              ),
            ),
            child: BlocBuilder<TripListBloc, TripState>(
              builder: (context, state) {
                if (state is TripLoadingState && state.data.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: primaryColor));
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
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(state.error, textAlign: TextAlign.center),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () =>
                                tripListBloc.add(const FetchTripsEvent()),
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
                      return _buildTripListItem(blocContext, trip, tripsRepository);
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
      }),
    );
  }
}
