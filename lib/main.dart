import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tqbluetoothprinter/Layout/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register SharedPreferencesPlugin only once
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UIScreen(),
    );
  }
}



