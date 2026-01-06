// pages/database_helper.dart
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Box? _usersBox;
  Box? _appointmentsBox;
  Box? _medicalRecordsBox;

  Future<Box> get usersBox async {
    if (_usersBox != null && _usersBox!.isOpen) return _usersBox!;
    _usersBox = await Hive.openBox('users');
    return _usersBox!;
  }

  Future<Box> get appointmentsBox async {
    if (_appointmentsBox != null && _appointmentsBox!.isOpen)
      return _appointmentsBox!;
    _appointmentsBox = await Hive.openBox('appointments');
    return _appointmentsBox!;
  }

  Future<Box> get medicalRecordsBox async {
    if (_medicalRecordsBox != null && _medicalRecordsBox!.isOpen)
      return _medicalRecordsBox!;
    _medicalRecordsBox = await Hive.openBox('medical_records');
    return _medicalRecordsBox!;
  }

  // ==================== MÉTHODES POUR DOSSIER MÉDICAL ====================

  // Sauvegarder les données médicales d'un patient
  Future<void> saveMedicalRecord(
      int patientCarteId, Map<String, dynamic> medicalData) async {
    final box = await medicalRecordsBox;
    final recordId = '$patientCarteId-${DateTime.now().millisecondsSinceEpoch}';

    medicalData['recordId'] = recordId;
    medicalData['patientCarteId'] = patientCarteId;
    medicalData['updatedAt'] = DateTime.now().toIso8601String();

    await box.put(recordId, medicalData);
    debugPrint('✅ Dossier médical sauvegardé pour patient $patientCarteId');
  }

  // Récupérer le dossier médical d'un patient
  Future<Map<String, dynamic>> getMedicalRecord(int patientCarteId) async {
    final box = await medicalRecordsBox;
    final allRecords = box.values.toList();

    for (var record in allRecords) {
      if (record['patientCarteId'] == patientCarteId) {
        return Map<String, dynamic>.from(record);
      }
    }

    // Retourner un dossier médical vide si non trouvé
    return {
      'patientCarteId': patientCarteId,
      'bloodType': 'Non spécifié',
      'height': '0',
      'weight': '0',
      'allergies': 'Aucune',
      'medications': 'Aucun',
      'chronicDiseases': 'Aucune',
      'previousSurgeries': 'Aucune',
      'familyHistory': 'Non spécifié',
      'smoking': false,
      'alcohol': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Mettre à jour les données médicales d'un patient
  Future<void> updateMedicalRecord(
      int patientCarteId, Map<String, dynamic> updatedData) async {
    final box = await medicalRecordsBox;
    final allRecords = box.toMap();

    for (var entry in allRecords.entries) {
      if (entry.value['patientCarteId'] == patientCarteId) {
        final recordData = Map<String, dynamic>.from(entry.value);
        recordData.addAll(updatedData);
        recordData['updatedAt'] = DateTime.now().toIso8601String();

        await box.put(entry.key, recordData);
        debugPrint('✅ Dossier médical mis à jour pour patient $patientCarteId');
        return;
      }
    }

    // Si aucun dossier n'existe, en créer un nouveau
    await saveMedicalRecord(patientCarteId, updatedData);
  }

  // ==================== MÉTHODES AMÉLIORÉES POUR UTILISATEURS ====================

  // Ajouter un utilisateur avec données médicales
  Future<void> insertUserWithMedicalData(Map<String, dynamic> user) async {
    final box = await usersBox;
    final carteId = user['carte_id'];

    if (await carteIdExists(carteId)) {
      throw Exception('Ce numéro de carte nationale est déjà utilisé');
    }

    String email = user['email'] ?? 'user_${carteId}@hospital.dz';

    // Données par défaut pour le dossier médical
    final medicalDefaults = {
      'bloodType': user['bloodType'] ?? 'Non spécifié',
      'height': user['height']?.toString() ?? '0',
      'weight': user['weight']?.toString() ?? '0',
      'allergies': user['allergies'] ?? 'Aucune',
      'medications': user['medications'] ?? 'Aucun',
      'chronicDiseases': user['chronicDiseases'] ?? 'Aucune',
      'previousSurgeries': user['previousSurgeries'] ?? 'Aucune',
      'familyHistory': user['familyHistory'] ?? 'Non spécifié',
      'smoking': user['smoking'] ?? false,
      'alcohol': user['alcohol'] ?? false,
    };

    user.addAll({
      'createdAt': DateTime.now().toIso8601String(),
      'medicalData': medicalDefaults,
    });

    if (user['fullName'] == null &&
        user['firstName'] != null &&
        user['lastName'] != null) {
      user['fullName'] = '${user['firstName']} ${user['lastName']}';
    }

    await box.put(email, user);

    // Créer aussi un dossier médical séparé
    await saveMedicalRecord(carteId, {
      ...medicalDefaults,
      'patientName': user['fullName'],
      'patientEmail': email,
    });

    debugPrint(
        '✅ Utilisateur ajouté avec dossier médical: ${user['fullName']}');
  }

  // Récupérer un utilisateur avec ses données médicales
  Future<Map<String, dynamic>> getUserWithMedicalData(String identifier) async {
    final user = await authenticateUser(identifier, '');
    if (user == null) return {};

    final carteId = user['carte_id'];
    final medicalRecord = await getMedicalRecord(carteId);

    return {
      ...user,
      'medicalData': medicalRecord,
    };
  }

  // Mettre à jour les données utilisateur ET médicales
  Future<void> updateUserWithMedicalData(
    String email,
    Map<String, dynamic> userData,
    Map<String, dynamic> medicalData,
  ) async {
    await updateUser(email, userData);

    final user = await getUserByEmail(email);
    if (user != null) {
      await updateMedicalRecord(user['carte_id'], medicalData);
    }
  }

  // ==================== MÉTHODES EXISTANTES AMÉLIORÉES ====================

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

  Future<bool> emailExists(String email) async {
    final box = await usersBox;
    return box.containsKey(email);
  }

  Future<void> addUser(String email, Map<String, dynamic> userData) async {
    final box = await usersBox;
    if (await carteIdExists(userData['carte_id'])) {
      throw Exception('Ce numéro de carte nationale est déjà utilisé');
    }
    await box.put(email, userData);
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final box = await usersBox;
    final carteId = user['carte_id'];

    if (await carteIdExists(carteId)) {
      throw Exception('Ce numéro de carte nationale est déjà utilisé');
    }

    String email = user['email'] ?? 'user_${carteId}@hospital.dz';
    user['createdAt'] = DateTime.now().toIso8601String();

    if (user['fullName'] == null &&
        user['firstName'] != null &&
        user['lastName'] != null) {
      user['fullName'] = '${user['firstName']} ${user['lastName']}';
    }

    await box.put(email, user);
    debugPrint('✅ Utilisateur ajouté: ${user['fullName']} (${user['role']})');
  }

  Future<Map<String, dynamic>?> authenticateUser(
      String identifier, String password) async {
    final box = await usersBox;
    var userData = box.get(identifier);

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

    if (userData['password'] == password) {
      return Map<String, dynamic>.from(userData);
    }
    return null;
  }

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

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final box = await usersBox;
    final user = box.get(email);
    return user != null ? Map<String, dynamic>.from(user) : null;
  }

  Future<Map<String, dynamic>?> getPatientByCarteId(int carteId) async {
    final user = await getUserByCarteId(carteId);
    if (user != null && user['role'] == 'patient') {
      return user;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final box = await usersBox;
    final users = box.values.toList();
    return users.map((user) => Map<String, dynamic>.from(user)).toList();
  }

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

  Future<List<Map<String, dynamic>>> getAllPatients() async {
    return await getUsersByRole('patient');
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final box = await usersBox;
    final allUsers = box.values;

    List<Map<String, dynamic>> doctors = [];
    for (var user in allUsers) {
      if (user['role'] == 'doctor' || user['role'] == 'medecin') {
        doctors.add(Map<String, dynamic>.from(user));
      }
    }
    return doctors;
  }

  Future<Map<String, dynamic>?> getDoctorByCarteId(int carteId) async {
    final user = await getUserByCarteId(carteId);
    if (user != null &&
        (user['role'] == 'doctor' || user['role'] == 'medecin')) {
      return user;
    }
    return null;
  }

  // ==================== MÉTHODES MANQUANTES ====================

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final box = await usersBox;
      final currentUser = box.values.firstWhere(
        (user) => user['role'] == 'patient',
        orElse: () => {},
      );

      if (currentUser.isNotEmpty) {
        final user = Map<String, dynamic>.from(currentUser);
        final carteId = user['carte_id'];

        // Récupérer les données médicales
        final medicalRecord = await getMedicalRecord(carteId);

        return {
          ...user,
          ...medicalRecord,
          'age': user['age'] ?? calculateAge(user['dateOfBirth']),
          'bloodType': medicalRecord['bloodType'] ?? 'Non spécifié',
          'height': medicalRecord['height'] ?? '0',
          'weight': medicalRecord['weight'] ?? '0',
          'allergies': medicalRecord['allergies'] ?? 'Aucune',
          'medications': medicalRecord['medications'] ?? 'Aucun',
          'conditions': medicalRecord['chronicDiseases'] ?? 'Aucune',
        };
      }

      return _getDefaultPatientData();
    } catch (e) {
      debugPrint('Erreur getUserData: $e');
      return _getDefaultPatientData();
    }
  }

  String calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null) return 'N/A';
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        return (age - 1).toString();
      }
      return age.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  Map<String, dynamic> _getDefaultPatientData() {
    return {
      'fullName': 'Roudaina Chelloug',
      'firstName': 'Roudaina',
      'lastName': 'Chelloug',
      'age': '26',
      'bloodType': 'AB+',
      'height': '1.68',
      'weight': '75',
      'allergies': 'Aucune',
      'medications': 'Aucun',
      'conditions': 'Aucune',
      'gender': 'Femme',
      'dateOfBirth': '1998-05-15',
      'phone': '+213 123 456 789',
      'address': 'Alger, Algérie',
      'emergencyContact': '+213 987 654 321',
      'carte_id': '123456789',
      'email': 'patient@hospital.dz',
    };
  }

  Future<Map<String, dynamic>> getDoctorData() async {
    final box = await usersBox;
    try {
      final doctor = box.values.firstWhere(
        (user) => user['role'] == 'doctor' || user['role'] == 'medecin',
        orElse: () => {},
      );
      return Map<String, dynamic>.from(doctor ?? {});
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final box = await appointmentsBox;
      final allAppointments = box.values.toList();
      return allAppointments
          .map((appt) => Map<String, dynamic>.from(appt))
          .toList();
    } catch (e) {
      debugPrint('Erreur getAppointments: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    return await getAllPatients();
  }

  Future<void> saveAppointment(Map<String, dynamic> appointmentData) async {
    final box = await appointmentsBox;
    final appointmentId = DateTime.now().millisecondsSinceEpoch;
    appointmentData['id'] = appointmentId;
    appointmentData['createdAt'] = DateTime.now().toIso8601String();

    await box.put(appointmentId, appointmentData);
    debugPrint('✅ Rendez-vous sauvegardé: $appointmentData');
  }

  // ==================== GESTION DES RENDEZ-VOUS ====================

  Future<List<Map<String, dynamic>>> getAppointmentsForUser(
      String userEmail) async {
    final box = await appointmentsBox;
    final allAppointments = box.values.toList();

    return allAppointments
        .where((appt) =>
            appt['patientEmail'] == userEmail ||
            appt['doctorEmail'] == userEmail)
        .map((appt) => Map<String, dynamic>.from(appt))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getDoctorAppointments(
      int doctorCarteId) async {
    final box = await appointmentsBox;
    final allAppointments = box.values.toList();

    return allAppointments
        .where((appt) => appt['doctorCarteId'] == doctorCarteId)
        .map((appt) => Map<String, dynamic>.from(appt))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPatientAppointments(
      int patientCarteId) async {
    final box = await appointmentsBox;
    final allAppointments = box.values.toList();

    return allAppointments
        .where((appt) => appt['patientCarteId'] == patientCarteId)
        .map((appt) => Map<String, dynamic>.from(appt))
        .toList();
  }

  // ==================== MISE À JOUR ====================

  Future<void> updateUser(String email, Map<String, dynamic> userData) async {
    final box = await usersBox;
    userData['updatedAt'] = DateTime.now().toIso8601String();
    await box.put(email, userData);
  }

  Future<void> updateUserByCarteId(
      int carteId, Map<String, dynamic> updatedData) async {
    final box = await usersBox;
    final allUsers = box.toMap();

    for (var entry in allUsers.entries) {
      if (entry.value['carte_id'] == carteId) {
        final userData = Map<String, dynamic>.from(entry.value);
        userData.addAll(updatedData);
        userData['updatedAt'] = DateTime.now().toIso8601String();

        if (updatedData.containsKey('firstName') ||
            updatedData.containsKey('lastName')) {
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          userData['fullName'] = '$firstName $lastName'.trim();
        }

        await box.put(entry.key, userData);
        return;
      }
    }
  }

  // ==================== SUPPRESSION ====================

  Future<void> deleteUser(String email) async {
    final box = await usersBox;
    await box.delete(email);
  }

  Future<void> deleteUserByCarteId(int carteId) async {
    final box = await usersBox;
    final allUsers = box.toMap();

    for (var entry in allUsers.entries) {
      if (entry.value['carte_id'] == carteId) {
        await box.delete(entry.key);
        debugPrint('🗑️ Utilisateur supprimé: ${entry.value['fullName']}');
        return;
      }
    }
  }

  // ==================== RECHERCHE ====================

  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final allPatients = await getAllPatients();
    final searchQuery = query.toLowerCase();

    return allPatients.where((patient) {
      final nom = patient['nom']?.toString().toLowerCase() ?? '';
      final prenom = patient['prenom']?.toString().toLowerCase() ?? '';
      final fullName = patient['fullName']?.toString().toLowerCase() ?? '';
      final firstName = patient['firstName']?.toString().toLowerCase() ?? '';
      final lastName = patient['lastName']?.toString().toLowerCase() ?? '';

      return nom.contains(searchQuery) ||
          prenom.contains(searchQuery) ||
          fullName.contains(searchQuery) ||
          firstName.contains(searchQuery) ||
          lastName.contains(searchQuery);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    final allDoctors = await getAllDoctors();
    final searchQuery = query.toLowerCase();

    return allDoctors.where((doctor) {
      final nom = doctor['nom']?.toString().toLowerCase() ?? '';
      final prenom = doctor['prenom']?.toString().toLowerCase() ?? '';
      final fullName = doctor['fullName']?.toString().toLowerCase() ?? '';
      final firstName = doctor['firstName']?.toString().toLowerCase() ?? '';
      final lastName = doctor['lastName']?.toString().toLowerCase() ?? '';
      final speciality = doctor['speciality']?.toString().toLowerCase() ?? '';
      final specialite = doctor['specialite']?.toString().toLowerCase() ?? '';

      return nom.contains(searchQuery) ||
          prenom.contains(searchQuery) ||
          fullName.contains(searchQuery) ||
          firstName.contains(searchQuery) ||
          lastName.contains(searchQuery) ||
          speciality.contains(searchQuery) ||
          specialite.contains(searchQuery);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getDoctorsBySpecialty(
      String specialty) async {
    final allDoctors = await getAllDoctors();
    return allDoctors.where((doctor) {
      final doctorSpecialty = doctor['specialite']?.toString() ??
          doctor['speciality']?.toString() ??
          '';
      return doctorSpecialty.toLowerCase() == specialty.toLowerCase();
    }).toList();
  }

  // ==================== STATISTIQUES ====================

  Future<int> getUserCount() async {
    final box = await usersBox;
    return box.length;
  }

  Future<int> getUserCountByRole(String role) async {
    final users = await getUsersByRole(role);
    return users.length;
  }

  Future<int> getTotalPatients() async {
    final patients = await getAllPatients();
    return patients.length;
  }

  Future<int> getTotalDoctors() async {
    final doctors = await getAllDoctors();
    return doctors.length;
  }

  Future<Map<String, int>> getGenderStatistics(String role) async {
    final users = await getUsersByRole(role);
    int male = 0;
    int female = 0;
    int other = 0;

    for (var user in users) {
      final gender = user['gender']?.toString().toLowerCase() ?? '';
      if (gender == 'homme' || gender == 'male') {
        male++;
      } else if (gender == 'femme' || gender == 'female') {
        female++;
      } else {
        other++;
      }
    }

    return {
      'male': male,
      'female': female,
      'other': other,
    };
  }

  Future<Map<String, int>> getSpecialtyStatistics() async {
    final doctors = await getAllDoctors();
    Map<String, int> specialtyCount = {};

    for (var doctor in doctors) {
      final specialty = doctor['specialite']?.toString() ??
          doctor['speciality']?.toString() ??
          'Non spécifié';
      specialtyCount[specialty] = (specialtyCount[specialty] ?? 0) + 1;
    }

    return specialtyCount;
  }

  // ==================== ADMIN ====================

  Future<void> initializeSingleAdmin() async {
    final box = await usersBox;
    const String adminCarteId = '1234567890';
    const String adminEmail = 'admin@hospital.dz';
    const String adminPassword = 'admin123';
    const String adminName = 'Administrateur Principal';

    if (box.containsKey(adminEmail)) {
      debugPrint('ℹ️  Le compte administrateur existe déjà');
      return;
    }

    await box.put(adminEmail, {
      'carte_id': int.parse(adminCarteId),
      'fullName': adminName,
      'firstName': 'Administrateur',
      'lastName': 'Principal',
      'email': adminEmail,
      'password': adminPassword,
      'role': 'admin',
      'phone': '',
      'gender': 'Homme',
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

  Future<Map<String, dynamic>?> login(
      String identifier, String password) async {
    return await authenticateUser(identifier, password);
  }

  Future<bool> isAdmin(String email) async {
    final box = await usersBox;
    final userData = box.get(email);
    return userData != null && userData['role'] == 'admin';
  }

  Future<void> clearAllUsers() async {
    final box = await usersBox;
    await box.clear();
    debugPrint('⚠️ Tous les utilisateurs ont été supprimés');
  }

  Future<void> resetDatabase() async {
    final box = await usersBox;
    await box.clear();
    await initializeSingleAdmin();
    debugPrint('🔄 Base de données réinitialisée avec le compte admin');
  }

  Future<void> debugPrintAllUsers() async {
    final users = await getAllUsers();
    debugPrint('\n📊 === LISTE DE TOUS LES UTILISATEURS ===');
    debugPrint('Total: ${users.length}');
    for (var user in users) {
      debugPrint('\n---');
      debugPrint(
          'Nom: ${user['fullName'] ?? '${user['firstName']} ${user['lastName']}'}');
      debugPrint('Email: ${user['email']}');
      debugPrint('Carte ID: ${user['carte_id']}');
      debugPrint('Rôle: ${user['role']}');
      if (user['role'] == 'doctor' || user['role'] == 'medecin') {
        debugPrint('Spécialité: ${user['specialite'] ?? 'Non spécifié'}');
        debugPrint('Genre: ${user['gender'] ?? 'Non spécifié'}');
      }
      if (user['medicalData'] != null) {
        debugPrint('Données médicales disponibles: OUI');
      }
    }
    debugPrint('\n=====================================\n');
  }

  Future<void> closeBox() async {
    if (_usersBox != null && _usersBox!.isOpen) {
      await _usersBox!.close();
      _usersBox = null;
    }
    if (_appointmentsBox != null && _appointmentsBox!.isOpen) {
      await _appointmentsBox!.close();
      _appointmentsBox = null;
    }
    if (_medicalRecordsBox != null && _medicalRecordsBox!.isOpen) {
      await _medicalRecordsBox!.close();
      _medicalRecordsBox = null;
    }
  }
}
