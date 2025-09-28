// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/core/routes/app_routes.dart';
import 'package:hau_navigation_app/viewmodels/campus_route_viewmodel.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CampusRouteViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HAUbout That Way',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.initialRoute,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        routes: AppRoutes.routes,
      ),
    );
  }
}