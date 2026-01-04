// pages/database_helper.dart
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

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

  // ==================== VÉRIFICATIONS ====================

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

  // ==================== AJOUTER UTILISATEURS ====================

  // Ajouter un utilisateur avec ID carte nationale (NUMBER)
  Future<void> addUser(String email, Map<String, dynamic> userData) async {
    final box = await usersBox;

    // Vérifier si l'ID carte nationale existe déjà
    if (await carteIdExists(userData['carte_id'])) {
      throw Exception('Ce numéro de carte nationale est déjà utilisé');
    }

    await box.put(email, userData);
  }

  // Insérer un utilisateur (patient ou médecin) - Version simplifiée
  Future<void> insertUser(Map<String, dynamic> user) async {
    final box = await usersBox;
    final carteId = user['carte_id'];

    // Vérifier si carte_id existe déjà
    if (await carteIdExists(carteId)) {
      throw Exception('Ce numéro de carte nationale est déjà utilisé');
    }

    // Générer un email unique si pas fourni
    String email = user['email'] ?? 'user_${carteId}@hospital.dz';

    // Ajouter timestamp de création
    user['createdAt'] = DateTime.now().toIso8601String();

    await box.put(email, user);
  }

  // ==================== RÉCUPÉRATION ====================

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

  // Récupérer un patient par carte_id (alias pour compatibilité)
  Future<Map<String, dynamic>?> getPatientByCarteId(int carteId) async {
    final user = await getUserByCarteId(carteId);
    if (user != null && user['role'] == 'patient') {
      return user;
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

  // Récupérer tous les patients
  Future<List<Map<String, dynamic>>> getAllPatients() async {
    return await getUsersByRole('patient');
  }

  // Récupérer tous les médecins
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    return await getUsersByRole('medecin');
  }

  // ==================== MISE À JOUR ====================

  // Mettre à jour un utilisateur
  Future<void> updateUser(String email, Map<String, dynamic> userData) async {
    final box = await usersBox;
    userData['updatedAt'] = DateTime.now().toIso8601String();
    await box.put(email, userData);
  }

  // Mettre à jour un utilisateur par carte_id
  Future<void> updateUserByCarteId(
      int carteId, Map<String, dynamic> updatedData) async {
    final box = await usersBox;
    final allUsers = box.toMap();

    for (var entry in allUsers.entries) {
      if (entry.value['carte_id'] == carteId) {
        final userData = Map<String, dynamic>.from(entry.value);
        userData.addAll(updatedData);
        userData['updatedAt'] = DateTime.now().toIso8601String();
        await box.put(entry.key, userData);
        return;
      }
    }
  }

  // ==================== SUPPRESSION ====================

  // Supprimer un utilisateur par email
  Future<void> deleteUser(String email) async {
    final box = await usersBox;
    await box.delete(email);
  }

  // Supprimer un utilisateur par carte_id
  Future<void> deleteUserByCarteId(int carteId) async {
    final box = await usersBox;
    final allUsers = box.toMap();

    for (var entry in allUsers.entries) {
      if (entry.value['carte_id'] == carteId) {
        await box.delete(entry.key);
        return;
      }
    }
  }

  // ==================== RECHERCHE ====================

  // Rechercher des patients par nom ou prénom
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final allPatients = await getAllPatients();
    final searchQuery = query.toLowerCase();

    return allPatients.where((patient) {
      final nom = patient['nom']?.toString().toLowerCase() ?? '';
      final prenom = patient['prenom']?.toString().toLowerCase() ?? '';
      final fullName = patient['fullName']?.toString().toLowerCase() ?? '';

      return nom.contains(searchQuery) ||
          prenom.contains(searchQuery) ||
          fullName.contains(searchQuery);
    }).toList();
  }

  // Rechercher des médecins par nom
  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    final allDoctors = await getAllDoctors();
    final searchQuery = query.toLowerCase();

    return allDoctors.where((doctor) {
      final nom = doctor['nom']?.toString().toLowerCase() ?? '';
      final prenom = doctor['prenom']?.toString().toLowerCase() ?? '';
      final fullName = doctor['fullName']?.toString().toLowerCase() ?? '';
      final speciality = doctor['speciality']?.toString().toLowerCase() ?? '';

      return nom.contains(searchQuery) ||
          prenom.contains(searchQuery) ||
          fullName.contains(searchQuery) ||
          speciality.contains(searchQuery);
    }).toList();
  }

  // ==================== STATISTIQUES ====================

  // Obtenir le nombre total d'utilisateurs
  Future<int> getUserCount() async {
    final box = await usersBox;
    return box.length;
  }

  // Obtenir le nombre d'utilisateurs par rôle
  Future<int> getUserCountByRole(String role) async {
    final users = await getUsersByRole(role);
    return users.length;
  }

  // Obtenir le nombre total de patients
  Future<int> getTotalPatients() async {
    final patients = await getAllPatients();
    return patients.length;
  }

  // Obtenir le nombre total de médecins
  Future<int> getTotalDoctors() async {
    final doctors = await getAllDoctors();
    return doctors.length;
  }

  // ==================== ADMIN ====================

  /// Initialiser le compte administrateur unique
  /// Cet admin gère tout : patients, médecins, et toutes les opérations
  Future<void> initializeSingleAdmin() async {
    final box = await usersBox;

    // Identifiants de l'admin unique (STABLE - Ne jamais modifier)
    const String adminCarteId = '1234567890';
    const String adminEmail = 'admin@hospital.dz';
    const String adminPassword = 'admin123';
    const String adminName = 'Administrateur Principal';

    // Vérifier si l'admin existe déjà
    if (box.containsKey(adminEmail)) {
      debugPrint('ℹ️  Le compte administrateur existe déjà');
      return;
    }

    // Créer le compte admin unique
    await box.put(adminEmail, {
      'carte_id': int.parse(adminCarteId),
      'fullName': adminName,
      'email': adminEmail,
      'password': adminPassword,
      'role': 'admin', // Rôle unique pour l'admin principal
      'phone': '',
      'dateOfBirth': '',
      'address': '',
      'rememberMe': true,
      'createdAt': DateTime.now().toIso8601String(),
    });

    debugPrint('✅ Compte administrateur créé avec succès');
    debugPrint('📋 Identifiants:');
    debugPrint('   Carte Nationale: $adminCarteId');
    debugPrint('   Email: $adminEmail');
    debugPrint('   Mot de passe: $adminPassword');
  }

  // ==================== UTILITAIRES ====================

  // Connexion (alias pour authenticateUser)
  Future<Map<String, dynamic>?> login(
      String identifier, String password) async {
    return await authenticateUser(identifier, password);
  }

  // Vérifier si un utilisateur est admin
  Future<bool> isAdmin(String email) async {
    final box = await usersBox;
    final userData = box.get(email);
    return userData != null && userData['role'] == 'admin';
  }

  // Effacer tous les utilisateurs (pour les tests uniquement)
  Future<void> clearAllUsers() async {
    final box = await usersBox;
    await box.clear();
    debugPrint('⚠️ Tous les utilisateurs ont été supprimés');
  }

  // Réinitialiser la base de données (supprimer tout sauf admin)
  Future<void> resetDatabase() async {
    final box = await usersBox;
    await box.clear();
    await initializeSingleAdmin();
    debugPrint('🔄 Base de données réinitialisée avec le compte admin');
  }

  // Afficher tous les utilisateurs (debug)
  Future<void> debugPrintAllUsers() async {
    final users = await getAllUsers();
    debugPrint('\n📊 === LISTE DE TOUS LES UTILISATEURS ===');
    debugPrint('Total: ${users.length}');
    for (var user in users) {
      debugPrint('\n---');
      debugPrint(
          'Nom: ${user['fullName'] ?? user['nom']} ${user['prenom'] ?? ''}');
      debugPrint('Email: ${user['email']}');
      debugPrint('Carte ID: ${user['carte_id']}');
      debugPrint('Rôle: ${user['role']}');
    }
    debugPrint('\n=====================================\n');
  }

  // Fermer la box
  Future<void> closeBox() async {
    if (_usersBox != null && _usersBox!.isOpen) {
      await _usersBox!.close();
      _usersBox = null;
    }
  }
}
