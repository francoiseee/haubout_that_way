// main.dart
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/core/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  // Supabase initialization
  await Supabase.initialize(
    url: 'https://mmbiqztsbfzlirocgnaz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1tYmlxenRzYmZ6bGlyb2NnbmF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5ODUzMzMsImV4cCI6MjA3NDU2MTMzM30.zYbN6-pY5LAiigqtw1ejiEbXlH9VWXl8UNMFD2nLrwA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HAUbout That Way',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      routes: AppRoutes.routes,
    );
  }
}