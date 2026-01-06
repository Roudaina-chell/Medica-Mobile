// main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/SplashPage.dart';
import 'pages/database_helper.dart';
import 'pages/addP.dart';
import 'pages/addD.dart';
import 'pages/profilAd.dart';
import 'pages/Madmin.dart';
import 'pages/dashbordAd.dart';
import 'pages/notificationAd.dart';
import 'pages/ProfileM.dart';
import 'pages/Profile.dart';
import 'pages/Doctors.dart';

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
            borderSide: const BorderSide(color: Color(0xFF2DB4F6), width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/':
            page = const SplashPage();
            break;

          // Routes Admin
          case '/dashbordAd':
            page = const DashboardAdmin();
            break;
          case '/profilAd':
            page = ProfilAdmin(userData: args);
            break;
          case '/notificationAd':
            page = NotificationAd(userData: args);
            break;
          case '/addP':
            page = const AddPatient();
            break;
          case '/addD':
            page = const AddDoctor();
            break;
          case '/Madmin':
            page = const ModifierAdmin();
            break;

          // Routes Patient
          case '/Profile':
            page = Profile(userData: args);
            break;
          case '/Mpatient':
            page = ProfileM(userData: args);
            break;
          case '/Doctors':
            page = Doctors(userData: args);
            break;

          // Routes de navigation patient - Placeholder
          case '/p_md_record':
            page = const PlaceholderPage(
              title: 'Dossiers Médicaux',
              description: 'Vos dossiers médicaux',
            );
            break;
          case '/history_consu':
            page = const PlaceholderPage(
              title: 'Historique',
              description: 'Historique des consultations',
            );
            break;
          case '/Schedul_appo':
            page = const PlaceholderPage(
              title: 'Rendez-vous',
              description: 'Planifier un rendez-vous',
            );
            break;
          case '/notificationPa':
            page = const PlaceholderPage(
              title: 'Notifications',
              description: 'Vos notifications',
            );
            break;
          case '/viewPa':
            page = const PlaceholderPage(
              title: 'Voir Profile',
              description: 'Détails du profil',
            );
            break;

          default:
            page = ErrorPage(routeName: settings.name ?? 'Unknown');
        }

        return MaterialPageRoute(builder: (context) => page);
      },
    );
  }
}

// Page placeholder pour les fonctionnalités en développement
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;

  const PlaceholderPage({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2DB4F6),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF89CFF0),
              const Color(0xFFB0E0E6),
              const Color(0xFF89CFF0).withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône animée
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DB4F6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 64,
                    color: Color(0xFF2DB4F6),
                  ),
                ),
                const SizedBox(height: 32),

                // Titre
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2DB4F6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF2DB4F6),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Page en cours de développement',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton retour
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Retour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DB4F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Page d'erreur pour les routes non trouvées
class ErrorPage extends StatelessWidget {
  final String routeName;

  const ErrorPage({
    Key? key,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF6B6B).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '404',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Route "$routeName" non trouvée',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cette page n\'existe pas dans l\'application',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Retour à l\'accueil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DB4F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
