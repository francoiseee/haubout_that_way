import 'package:flutter/material.dart';

class StartModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> navigateToHome(BuildContext context) async {
    try {
      setLoading(true);
      clearError();
      
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      
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