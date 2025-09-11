import 'package:flutter/material.dart';
import 'home_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static const String routeName = 'Start';
  static const String routePath = '/start';

  @override
  Widget build(BuildContext context) {
    return const HomePage(); // Redirect to HomePage which contains all the functionality
  }
}