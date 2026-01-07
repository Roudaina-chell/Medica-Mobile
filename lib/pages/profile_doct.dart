// pages/profile_doct.dart
import 'package:flutter/material.dart';
import 'home_doctor.dart';
import 'personal_medical_edit.dart';
import 'patient_dashboard.dart';
import 'book_appointment.dart';
import 'database_helper.dart';

class ProfileDoctPage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const ProfileDoctPage({super.key, this.doctorData});

  @override
  State<ProfileDoctPage> createState() => _ProfileDoctPageState();
}

class _ProfileDoctPageState extends State<ProfileDoctPage>
    with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic> doctorDetails = {};
  bool isLoading = true;
  int totalPatients = 124;
  String yearsExperience = '15';
  String rating = '4.8';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();

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

  Future<void> _loadDoctorProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Charger les données du docteur
      Map<String, dynamic> doctorData;
      if (widget.doctorData != null) {
        doctorData = widget.doctorData!;
      } else {
        final data = await _dbHelper.getDoctorData();
        doctorData = data.isNotEmpty ? data : _getDefaultDoctorData();
      }

      // Charger les statistiques
      final patients = await _dbHelper.getTotalPatients();
      final appointments = await _dbHelper.getAppointments();

      // Filtrer les rendez-vous de ce docteur
      final doctorAppointments = appointments.where((appt) {
        final apptDoctorId = appt['doctorCarteId'] ?? appt['doctor_id'];
        final doctorId = doctorData['carte_id'];
        return apptDoctorId == doctorId;
      }).toList();

      // Calculer la note moyenne (simulée)
      final appointmentCount = doctorAppointments.length;
      final avgRating = appointmentCount > 0
          ? (4.5 + (appointmentCount % 5) * 0.1).toStringAsFixed(1)
          : '4.8';

      setState(() {
        doctorDetails = doctorData;
        totalPatients = patients;
        yearsExperience = doctorData['yearsExperience']?.toString() ?? '15';
        rating = avgRating;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement du profil: $e');
      setState(() {
        doctorDetails = _getDefaultDoctorData();
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getDefaultDoctorData() {
    return {
      'fullName': 'Dr. James Smith',
      'firstName': 'James',
      'lastName': 'Smith',
      'specialite': 'Cardiologist',
      'carte_id': '123456',
      'email': 'dr.james@hospital.dz',
      'phone': '+213 123 456 789',
      'gender': 'Male',
      'dateOfBirth': '1980-05-15',
      'address': '123 Medical Street, Algiers',
      'yearsExperience': '15',
      'rating': '4.8',
    };
  }

  void _navigateToPage(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = HomeDoctorPage(doctorData: widget.doctorData);
        break;
      case 1:
        page = MedicalRecordsPage(doctorData: widget.doctorData);
        break;
      case 2:
        page = PatientDashboardPage(doctorData: widget.doctorData);
        break;
      case 3:
        page = BookAppointmentPage(doctorData: widget.doctorData);
        break;
      case 4:
        return; // Current page
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
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
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Logged out successfully',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF4CAF50),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Logout',
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

  void _handleEditProfile() {
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
              child: const Icon(
                Icons.info_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Edit Profile - Feature coming soon',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2DB4F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HomeDoctorPage(doctorData: widget.doctorData),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
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
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Card
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFF8F9FA)],
                      ),
                      borderRadius: BorderRadius.circular(24),
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
                    child: isLoading
                        ? Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2DB4F6),
                                        Color(0xFF1E88E5)
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Loading profile...',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Profile Picture
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2DB4F6),
                                      Color(0xFF1E88E5)
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2DB4F6)
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Doctor Name
                              Text(
                                doctorDetails['fullName'] ?? 'Dr. James Smith',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2DB4F6).withOpacity(0.15),
                                      const Color(0xFF2DB4F6).withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        const Color(0xFF2DB4F6).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  doctorDetails['specialite'] ?? 'Cardiologist',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF2DB4F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Stats Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    totalPatients.toString(),
                                    'Patients',
                                    Icons.people_rounded,
                                    const Color(0xFF2DB4F6),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.grey.shade300,
                                          Colors.grey.shade100,
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildStatItem(
                                    yearsExperience,
                                    'Years Exp',
                                    Icons.work_history_rounded,
                                    const Color(0xFF4CAF50),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.grey.shade300,
                                          Colors.grey.shade100,
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildStatItem(
                                    rating,
                                    'Rating',
                                    Icons.star_rounded,
                                    const Color(0xFFFF9800),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Menu Items
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.edit_rounded,
                            title: 'Edit Profile',
                            color: const Color(0xFF2DB4F6),
                            onTap: _handleEditProfile,
                          ),
                          _buildMenuItem(
                            icon: Icons.notifications_rounded,
                            title: 'Notifications',
                            color: const Color(0xFF4CAF50),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.schedule_rounded,
                            title: 'Working Hours',
                            color: const Color(0xFF8E24AA),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.receipt_long_rounded,
                            title: 'Medical Records',
                            color: const Color(0xFF00BCD4),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MedicalRecordsPage(
                                      doctorData: widget.doctorData),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            color: const Color(0xFF607D8B),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.help_rounded,
                            title: 'Help & Support',
                            color: const Color(0xFF03A9F4),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.info_rounded,
                            title: 'About',
                            color: const Color(0xFF9E9E9E),
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            color: const Color(0xFFFF6B6B),
                            isLogout: true,
                            onTap: _handleLogout,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                _buildBottomNavBar(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.08),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? color : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
          _buildNavItem(Icons.home_rounded, 0),
          _buildNavItem(Icons.calendar_today_rounded, 1),
          _buildNavItem(Icons.medical_services_rounded, 2),
          _buildNavItem(Icons.calendar_month_rounded, 3),
          _buildNavItem(Icons.person_rounded, 4, isSelected: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _navigateToPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2DB4F6),
                    Color(0xFF1E88E5),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
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
          color: isSelected ? Colors.white : Colors.black54,
          size: 24,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}