import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocky/services/hive_service.dart';
import 'package:stocky/views/welcome_view.dart';
import 'package:stocky/models/route_arguments.dart';

class AppLoaderView extends StatefulWidget {
  const AppLoaderView({super.key});

  @override
  State<AppLoaderView> createState() => _AppLoaderViewState();
}

class _AppLoaderViewState extends State<AppLoaderView> {
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final hiveService = Provider.of<HiveService>(context, listen: false);
    _userName = hiveService.getUserName();
    setState(() => _isLoading = false);
  }

  void _handleNameSaved(String name) {
    setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    final hiveService = Provider.of<HiveService>(context, listen: false);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (_userName == null || _userName!.isEmpty) {
      return WelcomeView(
        hiveService: hiveService,
        onNameSaved: _handleNameSaved,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: HomeArguments(_userName!),
      );
    });

    return const Scaffold(
      body: Center(
        child: Text(
          'Cargando...',
          style: TextStyle(fontSize: 18, color: Colors.green),
        ),
      ),
    );
  }
}
