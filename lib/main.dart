import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocky/services/notification_service.dart';
import 'package:stocky/views/app_loader_view.dart';
import 'package:stocky/views/home_view.dart';
import 'package:stocky/views/shopping_list_view.dart';
import 'package:stocky/models/route_arguments.dart';
import 'services/hive_service.dart';

late HiveService hiveServiceGlobal;
late NotificationService notificationServiceGlobal;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  hiveServiceGlobal = HiveService();
  await hiveServiceGlobal.init();

  notificationServiceGlobal = NotificationService();
  await notificationServiceGlobal.init();

  runApp(
    Provider<HiveService>.value(value: hiveServiceGlobal, child: const MyApp()),
  );
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            final args = settings.arguments as HomeArguments?;
            return MaterialPageRoute(
              builder: (_) => HomeView(
                userName: args?.userName ?? '',
                hiveService: hiveServiceGlobal,
              ),
            );

          case '/shopping-list':
            return MaterialPageRoute(builder: (_) => const ShoppingListView());

          default:
            return MaterialPageRoute(builder: (_) => const AppLoaderView());
        }
      },
    );
  }
}
