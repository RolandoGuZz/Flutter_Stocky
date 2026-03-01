import 'package:flutter/material.dart';
import 'package:stocky/views/app_loader_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stocky',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const AppLoaderView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
