// lib/views/trip_details_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travel_models.dart';

const Color primaryColor = Color(0xFF0D47A1); 
const Color textColor = Color(0xFF0D47A1); 
const Color labelColor = Colors.black; 

class TripDetailsView extends StatelessWidget {
  final Trip trip;
  const TripDetailsView({required this.trip, super.key});

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: labelColor),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: labelColor, fontSize: 16),
          ),
          const Divider(),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/HomeScreenBack.jpg'), 
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSection(
                  title: 'TRIP DETAILS',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailField('TRIP NAME', trip.name),
                      _buildDetailField('DATES', '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}'),
                      _buildDetailField('TRANSPORTATION', trip.transportation),
                      _buildDetailField('ACCOMMODATION', trip.accommodation),
                      _buildDetailField('BUDGET', '\$${trip.budget.toStringAsFixed(2)}'),
                      
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('РЕДАГУВАТИ'),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}