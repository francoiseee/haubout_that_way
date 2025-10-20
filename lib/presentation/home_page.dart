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
              body: SafeArea(
                top: true,
                child: _buildBodyWithGradient(context, model),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyWithGradient(BuildContext context, StartModel model) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryRed,
            Colors.black,
          ],
          stops: [0.3, 1.0],
        ),
      ),
      child: _buildBody(context, model),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogoSection(),
                  _buildWelcomeTextSection(context),
                  const Spacer(),
                  _buildStartButtonSection(model),
                  if (model.errorMessage != null) _buildErrorSection(model),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return const Padding(
      padding: EdgeInsets.only(top: 0.0),
      child: HauLogoWidget(),
    );
  }

  Widget _buildWelcomeTextSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Welcome to \nHAUbout That Way!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          
          Text(
            'Your ultimate guide to exploring Holy Angel University with ease. '
            'Find the quickest routes to classrooms, offices, and campus spots—'
            'so you\'ll never feel lost again. Whether you\'re a freshman, visitor, '
            'or just discovering new corners of HAU, we\'ll help you get there the smart way.',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButtonSection(StartModel model) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: model.isLoading ? null : _handleStartButtonPress,
              child: model.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text('Start'),
            ),
          ),
        ),
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