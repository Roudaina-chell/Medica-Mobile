// pages/database_helper.dart
import 'package:hive/hive.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Box? _usersBox;

  Future<Box> get usersBox async {
    if (_usersBox != null && _usersBox!.isOpen) return _usersBox!;
    _usersBox = await Hive.openBox('users');
    return _usersBox!;
  }

  // Vérifier si l'ID carte nationale existe déjà (NUMBER)
  Future<bool> carteIdExists(int carteId) async {
    final box = await usersBox;
    final allUsers = box.values;

    for (var user in allUsers) {
      if (user['carte_id'] == carteId) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'email existe déjà
  Future<bool> emailExists(String email) async {
    final box = await usersBox;
    return box.containsKey(email);
  }

  // Ajouter un utilisateur avec ID carte nationale (NUMBER)
  Future<void> addUser(String email, Map<String, dynamic> userData) async {
    final box = await usersBox;

    // Vérifier si l'ID carte nationale existe déjà
    if (await carteIdExists(userData['carte_id'])) {
      throw Exception('Ce numéro de carte nationale est déjà utilisé');
    }

    await box.put(email, userData);
  }

  // Authentification avec email OU carte_id (NUMBER)
  Future<Map<String, dynamic>?> authenticateUser(
      String identifier, String password) async {
    final box = await usersBox;

    // Essayer d'abord avec email
    var userData = box.get(identifier);

    // Si pas trouvé, chercher par carte_id (convertir en int si possible)
    if (userData == null) {
      int? carteIdSearch = int.tryParse(identifier);
      if (carteIdSearch != null) {
        final allUsers = box.values;
        for (var user in allUsers) {
          if (user['carte_id'] == carteIdSearch &&
              user['password'] == password) {
            return Map<String, dynamic>.from(user);
          }
        }
      }
      return null;
    }

    // Vérifier le mot de passe
    if (userData['password'] == password) {
      return Map<String, dynamic>.from(userData);
    }

    return null;
  }

  // Récupérer un utilisateur par carte_id (NUMBER)
  Future<Map<String, dynamic>?> getUserByCarteId(int carteId) async {
    final box = await usersBox;
    final allUsers = box.values;

    for (var user in allUsers) {
      if (user['carte_id'] == carteId) {
        return Map<String, dynamic>.from(user);
      }
    }
    return null;
  }

  // Récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final box = await usersBox;
    final users = box.values.toList();
    return users.map((user) => Map<String, dynamic>.from(user)).toList();
  }

  // Récupérer les utilisateurs par rôle
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final box = await usersBox;
    final allUsers = box.values;

    List<Map<String, dynamic>> filteredUsers = [];
    for (var user in allUsers) {
      if (user['role'] == role) {
        filteredUsers.add(Map<String, dynamic>.from(user));
      }
    }
    return filteredUsers;
  }

  // Initialiser les comptes système (appeler au démarrage de l'app)
  Future<void> initializeSystemAccounts() async {
    final box = await usersBox;

    // Compte SYSTÈME - Contrôle total
    if (!box.containsKey('system@hospital.dz')) {
      await box.put('system@hospital.dz', {
        'carte_id': 1111111111, // NUMBER: 10 chiffres
        'email': 'system@hospital.dz',
        'password': 'System@2025', // À changer en production
        'fullName': 'Système Principal',
        'role': 'system',
        'phone': '',
        'dateOfBirth': '',
        'address': '',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    // Compte INFIRMIÈRE ADMINISTRATIVE - Gestion administrative
    if (!box.containsKey('admin@hospital.dz')) {
      await box.put('admin@hospital.dz', {
        'carte_id': 2222222222, // NUMBER: 10 chiffres
        'email': 'admin@hospital.dz',
        'password': 'Admin@2025', // À changer en production
        'fullName': 'Infirmière Administrative',
        'role': 'nurse_admin',
        'phone': '',
        'dateOfBirth': '',
        'address': '',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String email, Map<String, dynamic> userData) async {
    final box = await usersBox;
    await box.put(email, userData);
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String email) async {
    final box = await usersBox;
    await box.delete(email);
  }

  // Effacer tous les utilisateurs (pour les tests uniquement)
  Future<void> clearAllUsers() async {
    final box = await usersBox;
    await box.clear();
  }
}
