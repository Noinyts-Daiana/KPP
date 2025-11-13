import 'package:flutter/material.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  Widget buildMainButton(BuildContext context, String text) {
    return ElevatedButton(
      onPressed: () {
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xB700295E),
        minimumSize: const Size(289, 60),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    buildMainButton(context, 'Open a list of trip'),
                    const SizedBox(height: 20),
                    buildMainButton(context, 'Open a list of items'),
                    const SizedBox(height: 20),
                    buildMainButton(context, 'Open notes'),
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
