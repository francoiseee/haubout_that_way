import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/presentation/map_page.dart';
import 'package:hau_navigation_app/presentation/admin_login_page.dart';
import 'package:hau_navigation_app/widgets/custom_app_bar.dart';

class VisitorAdminPage extends StatelessWidget {
  const VisitorAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      appBar: const CustomAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/campus.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [              
                  // Visitor Button
                  _buildOptionButton(
                    text: 'Visitor',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPage(isAdmin: false)),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Admin Button
                  _buildOptionButton(
                    text: 'Admin',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}