import 'package:flutter/material.dart';
import 'trip_list_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  Widget _buildMainButton(BuildContext context, String text, Widget destinationView) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => destinationView,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xB700295E), 
        minimumSize: const Size(289, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), 
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const tripListView = TripListView(); 
    
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
                        Icon(Icons.flight, color: Color(0xFF00295E)),
                        SizedBox(width: 8),
                        Text('Scheduled trips:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFF00295E)),
                        SizedBox(width: 8),
                        Text('No planned trips', style: TextStyle(color: Color(0xFF00295E))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    _buildMainButton(
                      context, 
                      'Open a list of trip', 
                      tripListView
                    ),
                    const SizedBox(height: 20),

                    _buildMainButton(
                      context, 
                      'Open a list of items', 
                      tripListView 
                    ),
                    const SizedBox(height: 20),

                    _buildMainButton(
                      context, 
                      'Open notes', 
                      tripListView 
                    ),
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