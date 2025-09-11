import 'package:flutter/material.dart';
import 'package:hau_navigation_app/models/start_model.dart';
import 'package:hau_navigation_app/widgets/hau_logo.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = 'Home';
  static const String routePath = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StartModel _model;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = StartModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _handleStartButtonPress() {
    // TODO: Navigate to main navigation page
    _model.navigateToHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StartModel>.value(
      value: _model,
      child: Consumer<StartModel>(
        builder: (context, model, child) {
          return GestureDetector(
            onTap: () => _dismissKeyboard(context),
            child: Scaffold(
              key: _scaffoldKey,
              body: SafeArea(
                top: true,
                child: _buildBody(context, model),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StartModel model) {
    if (model.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // HAU Logo Section
        _buildLogoSection(),
        
        // Welcome Text Section
        _buildWelcomeTextSection(context),
        
        // Start Button Section
        _buildStartButtonSection(model),
        
        // Error Message Section
        if (model.errorMessage != null) _buildErrorSection(model),
      ],
    );
  }

  // ===========================================
  // UI COMPONENT SECTIONS
  // ===========================================

  Widget _buildLogoSection() {
    return const HauLogoWidget(
      padding: EdgeInsets.only(top: _AppConstants.extraLargePadding),
    );
  }

  Widget _buildWelcomeTextSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Welcome title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
          child: Text(
            _AppConstants.welcomeMessage,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        
        // App description
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _AppConstants.largePadding + 4, 
            _AppConstants.largePadding, 
            _AppConstants.largePadding, 
            0
          ),
          child: Text(
            _AppConstants.appDescription,
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButtonSection(StartModel model) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: ElevatedButton(
        onPressed: model.isLoading ? null : _handleStartButtonPress,
        child: model.isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : const Text(_AppConstants.startButtonText),
      ),
    );
  }

  Widget _buildErrorSection(StartModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        model.errorMessage!,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

// ===========================================
// PRIVATE CONSTANTS CLASS
// ===========================================
class _AppConstants {
  // Asset paths
  static const String hauLogoPath = 'assets/images/hau_logo.png';
  
  // Text constants
  static const String appTitle = 'HAUbout That Way!';
  static const String welcomeMessage = 'Welcome to \nHAUbout That Way!';
  static const String appDescription = 
      'Your ultimate guide to exploring Holy Angel University with ease. '
      'Find the quickest routes to classrooms, offices, and campus spots—'
      'so you’ll never feel lost again. Whether you’re a freshman, visitor,'
      'or just discovering new corners of HAU, we’ll help you get there the smart way.'
      
      ;
  
  // Button texts
  static const String startButtonText = 'Start';
  
  // Dimensions
  static const double logoWidth = 212.97;
  static const double logoHeight = 200.0;
  
  // Spacing
  static const double defaultPadding = 16.0;
  static const double largePadding = 30.0;
  static const double extraLargePadding = 70.0;
  
  // Routes
  static const String startRoute = '/start';
  static const String homeRoute = '/home';
}