import 'package:flutter/material.dart';
import 'package:hau_navigation_app/presentation/home_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static const String routeName = 'Start';
  static const String routePath = '/start';

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}