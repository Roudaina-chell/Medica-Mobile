// main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/SplashPage.dart';
import 'pages/database_helper.dart';
import 'pages/addP.dart';
import 'pages/profilAd.dart';
import 'pages/Madmin.dart';
import 'pages/viewPa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('users');

  final dbHelper = DatabaseHelper();
  await dbHelper.initializeSingleAdmin();

  debugPrint('');
  debugPrint('=' * 50);
  debugPrint('IDENTIFIANTS ADMINISTRATEUR');
  debugPrint('=' * 50);
  debugPrint('Carte Nationale: 1234567890');
  debugPrint('Email: admin@hospital.dz');
  debugPrint('Mot de passe: admin123');
  debugPrint('=' * 50);
  debugPrint('');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medica Mobile',
      theme: ThemeData(
        fontFamily: 'Georgia',
        primaryColor: const Color(0xFF2DB4F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DB4F6),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2DB4F6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2DB4F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF2DB4F6),
              width: 2,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/addP': (context) => const AddPatient(),
        '/Madmin': (context) => const ModifierAdmin(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/profilAd') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ProfilAdmin(userData: args),
          );
        }

        if (settings.name == '/viewPa') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ViewPa(userData: args),
          );
        }

        return MaterialPageRoute(
          builder: (context) => const SplashPage(),
        );
      },
    );
  }
}
