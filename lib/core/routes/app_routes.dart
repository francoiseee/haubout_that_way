import 'package:flutter/material.dart';
import 'package:hau_navigation_app/presentation/home_page.dart';
import 'package:hau_navigation_app/presentation/start_page.dart';
import 'package:hau_navigation_app/presentation/visitor_admin_page.dart';
import 'package:hau_navigation_app/presentation/admin_login_page.dart';

class AppRoutes {
  static const String startRoute = '/start';
  static const String homeRoute = '/home';
  static const String visitorAdminRoute = '/visitor-admin';
  static const String adminLoginRoute = '/admin-login';

  static Map<String, WidgetBuilder> get routes {
    return {
      startRoute: (context) => const StartPage(),
      homeRoute: (context) => const HomePage(),
      visitorAdminRoute: (context) => const VisitorAdminPage(),
      adminLoginRoute: (context) => const AdminLoginPage(),
    };
  }

  static String get initialRoute => startRoute;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case startRoute:
        return MaterialPageRoute(builder: (_) => const StartPage());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case visitorAdminRoute:
        return MaterialPageRoute(builder: (_) => const VisitorAdminPage());
      case adminLoginRoute:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());
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