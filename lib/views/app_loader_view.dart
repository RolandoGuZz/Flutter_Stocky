import 'package:flutter/material.dart';
import 'package:stocky/services/hive_service.dart';
import 'package:stocky/views/home_view.dart';
import 'package:stocky/views/welcome_view.dart';

class AppLoaderView extends StatefulWidget {
  const AppLoaderView({super.key});

  @override
  State<AppLoaderView> createState() => _AppLoaderViewtate();
}

class _AppLoaderViewtate extends State<AppLoaderView> {
  late HiveService _hiveService;
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    _hiveService = HiveService();
    await _hiveService.init();
    _userName = _hiveService.getUserName();
    setState(() => _isLoading = false);
  }

  void _handleNameSaved(String name) {
    setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userName == null || _userName!.isEmpty) {
      return WelcomeView(
        hiveService: _hiveService,
        onNameSaved: _handleNameSaved,
      );
    }

    return HomeView(userName: _userName!, hiveService: _hiveService);
  }

  @override
  void dispose() {
    _hiveService.close();
    super.dispose();
  }
}
