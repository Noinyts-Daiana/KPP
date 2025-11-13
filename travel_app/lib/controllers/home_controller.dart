import 'package:flutter/material.dart';
import '../views/register_view.dart';

class HomeController {
  final BuildContext context;

  HomeController(this.context);

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
    );
  }
}
