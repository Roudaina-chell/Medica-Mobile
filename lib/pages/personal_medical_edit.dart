// pages/personal_medical_edit.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'notifications.dart';

class MedicalRecordsPage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const MedicalRecordsPage({super.key, this.doctorData});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bloodController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();

  Map<String, dynamic> patientData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _dbHelper.getUserData();
      setState(() {
        patientData = data.isNotEmpty ? data : _getDefaultPatientData();
        _updateControllers();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des données patient: $e');
      setState(() {
        patientData = _getDefaultPatientData();
        _updateControllers();
        isLoading = false;
      });
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
      'allergies': 'None',
      'medications': 'None',
      'conditions': 'None',
      'gender': 'Female',
      'dateOfBirth': '1998-05-15',
    };
  }

  void _updateControllers() {
    _ageController.text = patientData['age']?.toString() ?? '26';
    _bloodController.text = patientData['bloodType']?.toString() ?? 'AB+';
    _heightController.text = patientData['height']?.toString() ?? '1.68';
    _weightController.text = patientData['weight']?.toString() ?? '75';
    _allergiesController.text = patientData['allergies']?.toString() ?? 'None';
    _medicationsController.text =
        patientData['medications']?.toString() ?? 'None';
    _conditionsController.text =
        patientData['conditions']?.toString() ?? 'None';
  }

  Future<void> _savePatientData() async {
    final updatedData = {
      'age': _ageController.text,
      'bloodType': _bloodController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'allergies': _allergiesController.text,
      'medications': _medicationsController.text,
      'conditions': _conditionsController.text,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      if (patientData['email'] != null) {
        await _dbHelper.updateUser(patientData['email'], {
          ...patientData,
          ...updatedData,
        });
      } else if (patientData['carte_id'] != null) {
        await _dbHelper.updateUserByCarteId(
          int.parse(patientData['carte_id'].toString()),
          updatedData,
        );
      }

      _showSaveNotification('Patient data saved successfully!');

      setState(() {
        patientData = {...patientData, ...updatedData};
      });
    } catch (e) {
      _showSaveNotification('Error saving data: $e', isError: true);
    }
  }

  void _showSaveNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToNotifications() {
    // Navigation vers notifications si nécessaire
  }

  void _showEditDialog() {
    // Créer des contrôleurs temporaires pour le formulaire d'édition
    final tempAgeController = TextEditingController(text: _ageController.text);
    final tempBloodController =
        TextEditingController(text: _bloodController.text);
    final tempHeightController =
        TextEditingController(text: _heightController.text);
    final tempWeightController =
        TextEditingController(text: _weightController.text);
    final tempAllergiesController =
        TextEditingController(text: _allergiesController.text);
    final tempMedicationsController =
        TextEditingController(text: _medicationsController.text);
    final tempConditionsController =
        TextEditingController(text: _conditionsController.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Color.fromARGB(255, 64, 123, 191)),
              SizedBox(width: 10),
              Text(
                'Edit Medical Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 64, 123, 191),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditField(
                  label: 'Age',
                  controller: tempAgeController,
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 15),
                _buildEditField(
                  label: 'Blood Type',
                  controller: tempBloodController,
                  icon: Icons.water_drop,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 15),
                _buildEditField(
                  label: 'Height (cm)',
                  controller: tempHeightController,
                  icon: Icons.straighten,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 15),
                _buildEditField(
                  label: 'Weight (kg)',
                  controller: tempWeightController,
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 15),
                _buildEditField(
                  label: 'Allergies',
                  controller: tempAllergiesController,
                  icon: Icons.warning_amber_outlined,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                ),
                SizedBox(height: 15),
                _buildEditField(
                  label: 'Current Medications',
                  controller: tempMedicationsController,
                  icon: Icons.medication_outlined,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                ),
                SizedBox(height: 15),
                _buildEditField(
                  label: 'Medical Conditions',
                  controller: tempConditionsController,
                  icon: Icons.health_and_safety_outlined,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Disposer les contrôleurs temporaires
                tempAgeController.dispose();
                tempBloodController.dispose();
                tempHeightController.dispose();
                tempWeightController.dispose();
                tempAllergiesController.dispose();
                tempMedicationsController.dispose();
                tempConditionsController.dispose();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // Mettre à jour les contrôleurs principaux
                _ageController.text = tempAgeController.text;
                _bloodController.text = tempBloodController.text;
                _heightController.text = tempHeightController.text;
                _weightController.text = tempWeightController.text;
                _allergiesController.text = tempAllergiesController.text;
                _medicationsController.text = tempMedicationsController.text;
                _conditionsController.text = tempConditionsController.text;

                // Sauvegarder les données
                await _savePatientData();

                // Disposer les contrôleurs temporaires
                tempAgeController.dispose();
                tempBloodController.dispose();
                tempHeightController.dispose();
                tempWeightController.dispose();
                tempAllergiesController.dispose();
                tempMedicationsController.dispose();
                tempConditionsController.dispose();

                Navigator.pop(context);
              },
              icon: Icon(Icons.save, size: 18),
              label: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 64, 123, 191),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 64, 123, 191)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 90, 196, 245),
                Color.fromARGB(255, 221, 230, 235),
                Color.fromARGB(255, 214, 225, 230),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 90, 196, 245),
              Color.fromARGB(255, 221, 230, 235),
              Color.fromARGB(255, 214, 225, 230),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black,
                        size: 26,
                      ),
                      onPressed: _navigateToNotifications,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Personal and medical\nRecords',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 40),

                // Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.grey.shade300,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  patientData['fullName'] ?? 'Roudaina Chelloug',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 40),

                // Medical Info Cards (Lecture seule)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      label: 'Age',
                      value: _ageController.text,
                      bgColor: Colors.white.withOpacity(0.9),
                      iconColor: Colors.black,
                    ),
                    _buildInfoCard(
                      icon: Icons.water_drop,
                      label: 'Blood',
                      value: _bloodController.text,
                      bgColor: Colors.white.withOpacity(0.9),
                      iconColor: const Color(0xFFE53935),
                    ),
                    _buildInfoCard(
                      icon: Icons.straighten,
                      label: 'Height',
                      value: _heightController.text,
                      bgColor: Colors.white.withOpacity(0.9),
                      iconColor: const Color(0xFF8E24AA),
                    ),
                    _buildInfoCard(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      value: _weightController.text,
                      bgColor: Colors.white.withOpacity(0.9),
                      iconColor: const Color(0xFFEC407A),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Personal Details Label avec bouton d'édition
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Personal details :',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 64, 123, 191),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: const Color.fromARGB(255, 64, 123, 191),
                      ),
                      onPressed: _showEditDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Additional Medical Info (Lecture seule)
                _buildReadOnlyDetail(
                  label: 'Allergies',
                  value: _allergiesController.text,
                  icon: Icons.warning_amber_outlined,
                ),
                const SizedBox(height: 15),
                _buildReadOnlyDetail(
                  label: 'Current Medications',
                  value: _medicationsController.text,
                  icon: Icons.medication_outlined,
                ),
                const SizedBox(height: 15),
                _buildReadOnlyDetail(
                  label: 'Medical Conditions',
                  value: _conditionsController.text,
                  icon: Icons.health_and_safety_outlined,
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showPatientDetailsDialog,
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        label: const Text(
                          'View',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 60, 131, 193),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showSaveNotification('Document saved successfully!');
                        },
                        icon: const Icon(Icons.download_outlined, size: 20),
                        label: const Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom Navigation Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavIcon(Icons.home),
                      _buildNavIcon(Icons.card_membership, isActive: true),
                      _buildNavIcon(Icons.favorite),
                      _buildNavIcon(Icons.calendar_today),
                      _buildNavIcon(Icons.person),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyDetail({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 64, 123, 191), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Patient Medical Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('Full Name', patientData['fullName'] ?? 'N/A'),
                _buildDetailItem('Age', _ageController.text),
                _buildDetailItem('Blood Type', _bloodController.text),
                _buildDetailItem('Height', '${_heightController.text} cm'),
                _buildDetailItem('Weight', '${_weightController.text} kg'),
                _buildDetailItem('Allergies', _allergiesController.text),
                _buildDetailItem('Medications', _medicationsController.text),
                _buildDetailItem('Conditions', _conditionsController.text),
                if (patientData['gender'] != null)
                  _buildDetailItem('Gender', patientData['gender']),
                if (patientData['dateOfBirth'] != null)
                  _buildDetailItem('Date of Birth', patientData['dateOfBirth']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1E88E5).withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isActive ? const Color(0xFF1E88E5) : Colors.grey.shade600,
        size: 26,
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _bloodController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }
}
