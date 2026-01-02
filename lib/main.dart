// main.dart
import 'package:flutter/material.dart';
import 'pages/SplashPage.dart';
import 'pages/init_accounts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InitAccounts.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
      ),
      home: const SplashPage(),
    );
  }
}
