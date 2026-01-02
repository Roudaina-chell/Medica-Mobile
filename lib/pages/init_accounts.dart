// pages/init_accounts.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'database_helper.dart';

class InitAccounts {
  static Future<void> initialize() async {
    // Initialiser Hive
    await Hive.initFlutter();

    // Créer l'instance de DatabaseHelper
    final dbHelper = DatabaseHelper();

    // Initialiser les comptes système
    await dbHelper.initializeSystemAccounts();

    print('✅ Comptes système initialisés avec succès');
    print('📋 Comptes créés:');
    print('   - Système: 1111111111 / system@hospital.dz');
    print('   - Infirmière Admin: 2222222222 / admin@hospital.dz');
  }

  // Fonction pour vérifier si les comptes système existent
  static Future<bool> systemAccountsExist() async {
    final dbHelper = DatabaseHelper();

    bool systemExists = await dbHelper.emailExists('system@hospital.dz');
    bool adminExists = await dbHelper.emailExists('admin@hospital.dz');

    return systemExists && adminExists;
  }

  // Fonction pour réinitialiser les comptes système (si nécessaire)
  static Future<void> resetSystemAccounts() async {
    final dbHelper = DatabaseHelper();
    final box = await dbHelper.usersBox;

    // Supprimer les anciens comptes
    await box.delete('system@hospital.dz');
    await box.delete('admin@hospital.dz');

    // Réinitialiser
    await dbHelper.initializeSystemAccounts();

    print('🔄 Comptes système réinitialisés');
  }
}
