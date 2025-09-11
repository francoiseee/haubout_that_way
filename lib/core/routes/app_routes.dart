import 'package:flutter/material.dart';
import 'package:hau_navigation_app/presentation/home_page.dart';
import 'package:hau_navigation_app/presentation/start_page.dart';

class AppRoutes {
  // Route constants
  static const String startRoute = '/start';
  static const String homeRoute = '/home';

  static Map<String, WidgetBuilder> get routes {
    return {
      startRoute: (context) => const StartPage(),
      homeRoute: (context) => const HomePage(),
    };
  }

  static String get initialRoute => startRoute;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case startRoute:
        return MaterialPageRoute(builder: (_) => const StartPage());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}