import 'package:flutter/material.dart';

class StartModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Navigation method
  Future<void> navigateToHome(BuildContext context) async {
    try {
      setLoading(true);
      clearError();
      
      // Add any initialization logic here
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      
      // TODO: Navigate to main navigation/dashboard page
      // Navigator.pushNamed(context, '/dashboard');
      print('Navigating to main navigation page...');
      
    } catch (e) {
      setError('Failed to navigate: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}