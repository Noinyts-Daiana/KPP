import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeController(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.goToRegister,
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox.expand(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/HomeScreen.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Grab and Go',
                    style: TextStyle(
                      fontFamily: 'HoltwoodOneSC',
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
