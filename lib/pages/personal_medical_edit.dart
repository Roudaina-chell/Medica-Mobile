// pages/personal_medical_edit.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'notifications.dart';
import 'home_doctor.dart';
import 'patient_dashboard.dart';
import 'book_appointment.dart';
import 'profile_doct.dart';

class MedicalRecordsPage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const MedicalRecordsPage({super.key, this.doctorData});
  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage>
    with TickerProviderStateMixin {
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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadPatientData();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFFF6B6B) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  void _showEditDialog() {
    final tempAgeController = TextEditingController(text: _ageController.text);
    final tempBloodController = TextEditingController(text: _bloodController.text);
    final tempHeightController = TextEditingController(text: _heightController.text);
    final tempWeightController = TextEditingController(text: _weightController.text);
    final tempAllergiesController = TextEditingController(text: _allergiesController.text);
    final tempMedicationsController = TextEditingController(text: _medicationsController.text);
    final tempConditionsController = TextEditingController(text: _conditionsController.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2DB4F6),
                      Color(0xFF1E88E5),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DB4F6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Edit Medical Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                const SizedBox(height: 16),
                _buildEditField(
                  label: 'Blood Type',
                  controller: tempBloodController,
                  icon: Icons.water_drop_outlined,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                _buildEditField(
                  label: 'Height (cm)',
                  controller: tempHeightController,
                  icon: Icons.straighten,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                _buildEditField(
                  label: 'Weight (kg)',
                  controller: tempWeightController,
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                _buildEditField(
                  label: 'Allergies',
                  controller: tempAllergiesController,
                  icon: Icons.warning_amber_outlined,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildEditField(
                  label: 'Current Medications',
                  controller: tempMedicationsController,
                  icon: Icons.medication_outlined,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
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
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      tempAgeController.dispose();
                      tempBloodController.dispose();
                      tempHeightController.dispose();
                      tempWeightController.dispose();
                      tempAllergiesController.dispose();
                      tempMedicationsController.dispose();
                      tempConditionsController.dispose();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      _ageController.text = tempAgeController.text;
                      _bloodController.text = tempBloodController.text;
                      _heightController.text = tempHeightController.text;
                      _weightController.text = tempWeightController.text;
                      _allergiesController.text = tempAllergiesController.text;
                      _medicationsController.text = tempMedicationsController.text;
                      _conditionsController.text = tempConditionsController.text;

                      await _savePatientData();

                      tempAgeController.dispose();
                      tempBloodController.dispose();
                      tempHeightController.dispose();
                      tempWeightController.dispose();
                      tempAllergiesController.dispose();
                      tempMedicationsController.dispose();
                      tempConditionsController.dispose();

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DB4F6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2DB4F6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF2DB4F6),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withOpacity(0.15),
                  iconColor.withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
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
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2DB4F6),
                        Color(0xFF1E88E5),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DB4F6).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading medical records...',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
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
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2DB4F6),
                                  Color(0xFF1E88E5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2DB4F6).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.medical_information_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Medical Records',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      // Notification button
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: _navigateToNotifications,
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Profile Picture
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2DB4F6).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF2DB4F6).withOpacity(0.2),
                                    const Color(0xFF1E88E5).withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 55,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Name
                          Text(
                            patientData['fullName'] ?? 'Roudaina Chelloug',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Medical Info Cards Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            children: [
                              _buildInfoCard(
                                icon: Icons.person_outline,
                                label: 'Age',
                                value: _ageController.text,
                                iconColor: const Color(0xFF2DB4F6),
                              ),
                              _buildInfoCard(
                                icon: Icons.water_drop_outlined,
                                label: 'Blood Type',
                                value: _bloodController.text,
                                iconColor: const Color(0xFFE53935),
                              ),
                              _buildInfoCard(
                                icon: Icons.straighten,
                                label: 'Height',
                                value: '${_heightController.text}m',
                                iconColor: const Color(0xFF8E24AA),
                              ),
                              _buildInfoCard(
                                icon: Icons.monitor_weight_outlined,
                                label: 'Weight',
                                value: '${_weightController.text}kg',
                                iconColor: const Color(0xFFEC407A),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Personal Details Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color(0xFFF8F9FA),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF2DB4F6).withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF2DB4F6).withOpacity(0.15),
                                                const Color(0xFF2DB4F6).withOpacity(0.08),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.description_outlined,
                                            color: Color(0xFF2DB4F6),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Personal Details',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF2DB4F6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _showEditDialog,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2DB4F6),
                                              Color(0xFF1E88E5),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF2DB4F6).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildDetailCard(
                                  label: 'Allergies',
                                  value: _allergiesController.text,
                                  icon: Icons.warning_amber_outlined,
                                  iconColor: const Color(0xFFFF9800),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailCard(
                                  label: 'Current Medications',
                                  value: _medicationsController.text,
                                  icon: Icons.medication_outlined,
                                  iconColor: const Color(0xFF4CAF50),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailCard(
                                  label: 'Medical Conditions',
                                  value: _conditionsController.text,
                                  icon: Icons.health_and_safety_outlined,
                                  iconColor: const Color(0xFFE53935),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showPatientDetailsDialog,
                                  icon: const Icon(Icons.visibility_outlined, size: 20),
                                  label: const Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2DB4F6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadowColor: const Color(0xFF2DB4F6).withOpacity(0.3),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showSaveNotification('Document saved successfully!');
                                  },
                                  icon: const Icon(Icons.download_rounded, size: 20),
                                  label: const Text(
                                    'Download',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE53935),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadowColor: const Color(0xFFE53935).withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: const Color(0xFF2DB4F6).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(Icons.home_rounded, 0, false),
                      _buildNavIcon(Icons.calendar_today_rounded, 1, true), // Medical Records active
                      _buildNavIcon(Icons.medical_services_rounded, 2, false),
                      _buildNavIcon(Icons.calendar_month_rounded, 3, false),
                      _buildNavIcon(Icons.person_rounded, 4, false),
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

  Widget _buildDetailCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DB4F6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_information_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Patient Medical Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('Full Name', patientData['fullName'] ?? 'N/A'),
                _buildDetailItem('Age', _ageController.text),
                _buildDetailItem('Blood Type', _bloodController.text),
                _buildDetailItem('Height', '${_heightController.text} m'),
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
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF2DB4F6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, bool isCurrentPage) {
    return GestureDetector(
      onTap: () => _navigateToPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isCurrentPage ? 16 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isCurrentPage
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2DB4F6),
                    Color(0xFF1E88E5),
                  ],
                )
              : null,
          color: isCurrentPage ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isCurrentPage
              ? [
                  BoxShadow(
                    color: const Color(0xFF2DB4F6).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isCurrentPage ? Colors.white : Colors.black54,
          size: 24,
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    if (index == 1) return; // Current page - Medical Records
    
    Widget page;
    switch (index) {
      case 0:
        // Home - go to HomeDoctorPage
        page = HomeDoctorPage(doctorData: widget.doctorData);
        break;
      case 2:
        // Patient Dashboard
        page = PatientDashboardPage(doctorData: widget.doctorData);
        break;
      case 3:
        // Book Appointment
        page = BookAppointmentPage(doctorData: widget.doctorData);
        break;
      case 4:
        // Profile
        page = ProfileDoctPage(doctorData: widget.doctorData);
        break;
      default:
        return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}