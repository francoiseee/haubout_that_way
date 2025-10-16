// presentation/admin_login_page.dart
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/presentation/map_page.dart';
import 'package:hau_navigation_app/widgets/custom_app_bar.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    setState(() {
      _isLoading = true;
    });

    // Simulate login process
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to map page after successful login (as admin)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapPage(isAdmin: true)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Blurred background image
          _buildBlurredBackground(),
          
          // Content overlay
          _buildLoginContent(),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hau_campus_background.jpg'), // Add your background image
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          Colors.black.withOpacity(0.5), // Dark overlay
          BlendMode.darken,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3), // Additional blur effect
        ),
      ),
    );
  }

  Widget _buildLoginContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60), // Space from top
            
            // App Title
            Text(
              'HAUbout That Way',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 10),
            
            // Subtitle
            Text(
              'Campus Navigation Made Easy',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w300,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 80), // Space before form
            
            // Login Card
            Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Title
                  Text(
                    'Admin Login',
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Subtitle
                  Text(
                    'Enter your credentials to continue',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Institutional Email',
                    hintText: 'employee@hau.edu.ph',
                    icon: Icons.email,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ID field
                  _buildTextField(
                    controller: _idController,
                    label: 'Employee ID',
                    hintText: 'Enter your employee ID',
                    icon: Icons.badge,
                    isPassword: true,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Login button
                  _buildLoginButton(),
                  
                  const SizedBox(height: 20),
                  
                  // Forgot password link
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: AppTheme.primaryRed),
              suffixIcon: isPassword 
                  ? IconButton(
                      icon: Icon(Icons.visibility, color: Colors.grey[500]),
                      onPressed: () {
                        // Toggle password visibility
                      },
                    )
                  : null,
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: AppTheme.primaryRed.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

 


  Widget _buildAlternativeButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryYellow : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppTheme.primaryYellow : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.black : AppTheme.primaryRed,
                size: 24,
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: TextStyle(
                  color: isActive ? Colors.black : AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}