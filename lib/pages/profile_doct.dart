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

class _ProfileDoctPageState extends State<ProfileDoctPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic> doctorDetails = {};
  bool isLoading = true;
  int totalPatients = 124;
  String yearsExperience = '15';
  String rating = '4.8';

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
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
    // Afficher une boîte de dialogue de confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue

                // Naviguer vers la page de connexion et supprimer toutes les pages précédentes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // Remplacez par le nom de votre route de connexion
                  (route) => false,
                );

                // Alternative si vous n'utilisez pas de routes nommées:
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => LoginPage(), // Remplacez par votre page de connexion
                //   ),
                //   (route) => false,
                // );

                // Afficher un message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleEditProfile() {
    // TODO: Implémenter l'édition du profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Profile - Feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 90, 196, 245), Color(0xFFE8F4F8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeDoctorPage(doctorData: widget.doctorData),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 90, 196, 245),
                        ),
                      )
                    : Column(
                        children: [
                          // Profile Picture
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(255, 90, 196, 245)
                                  .withOpacity(0.2),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: const Color.fromARGB(255, 90, 196, 245),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Doctor Name
                          Text(
                            doctorDetails['fullName'] ?? 'Dr. James Smith',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            doctorDetails['specialite'] ?? 'Cardiologist',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                  totalPatients.toString(), 'Patients'),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              _buildStatItem(yearsExperience, 'Years Exp'),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              _buildStatItem(rating, 'Rating'),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Menu Items
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          onTap: _handleEditProfile,
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {
                            // TODO: Naviguer vers notifications
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.schedule_outlined,
                          title: 'Working Hours',
                          onTap: () {
                            // TODO: Gérer les horaires de travail
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Medical Records',
                          onTap: () {
                            // Naviguer vers les dossiers médicaux
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
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {
                            // TODO: Paramètres
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () {
                            // TODO: Aide et support
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () {
                            // TODO: À propos
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Logout',
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
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 90, 196, 245),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.1)
                        : const Color.fromARGB(255, 90, 196, 245)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout
                        ? Colors.red
                        : const Color.fromARGB(255, 90, 196, 245),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isLogout ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isLogout
                      ? Colors.red
                      : const Color.fromARGB(255, 90, 196, 245),
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 0),
          _buildNavItem(Icons.calendar_today_outlined, 1),
          _buildNavItem(Icons.medical_services_outlined, 2),
          _buildNavItem(Icons.calendar_month, 3),
          _buildNavItem(Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = index == 4; // Current page
    return GestureDetector(
      onTap: () => _navigateToPage(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1DB1FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 26,
        ),
      ),
    );
  }
}
