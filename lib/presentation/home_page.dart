// presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/models/start_model.dart';
import 'package:hau_navigation_app/widgets/hau_logo.dart';
import 'package:provider/provider.dart';
import 'package:hau_navigation_app/presentation/visitor_admin_page.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';


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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VisitorAdminPage()),
    );
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
              backgroundColor: AppTheme.primaryRed,
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

    return SingleChildScrollView(
      child: Column(
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
      ),
    );
  }

  // ===========================================
  // UI COMPONENT SECTIONS
  // ===========================================

  Widget _buildLogoSection() {
    return const HauLogoWidget(
      padding: EdgeInsets.only(top: 70.0),
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
            'Welcome to \nHAUbout That Way!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        
        // App description
        Padding(
          padding: const EdgeInsets.fromLTRB(34, 30, 30, 0),
          child: Text(
            'Your ultimate guide to exploring Holy Angel University with ease. '
            'Find the quickest routes to classrooms, offices, and campus spots—'
            'so you\'ll never feel lost again. Whether you\'re a freshman, visitor,'
            'or just discovering new corners of HAU, we\'ll help you get there the smart way.',
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
          : const Text('Start'),
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