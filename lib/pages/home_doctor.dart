// pages/home_doctor.dart
import 'package:flutter/material.dart';
import 'package:se_mobile/pages/database_helper.dart'; // Ajustez le chemin
import 'package:se_mobile/pages/personal_medical_edit.dart'; // Ajustez le chemin
import 'package:se_mobile/pages/patient_dashboard.dart'; // Ajustez le chemin
import 'package:se_mobile/pages/book_appointment.dart'; // Ajustez le chemin
import 'package:se_mobile/pages/profile_doct.dart'; // Ajustez le chemin

class HomeDoctorPage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const HomeDoctorPage({super.key, this.doctorData});

  @override
  State<HomeDoctorPage> createState() => _HomeDoctorPageState();
}

class _HomeDoctorPageState extends State<HomeDoctorPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Données dynamiques
  String doctorName = 'Dr. James Smith';
  String greeting = 'Good Morning';
  int totalPatients = 0;
  int todayAppointments = 0;
  int todayConsultations = 0;
  int todayReports = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _loadStatistics();
  }

  Future<void> _loadDoctorData() async {
    // Si doctorData est fourni, l'utiliser
    if (widget.doctorData != null) {
      setState(() {
        doctorName = widget.doctorData!['fullName'] ??
            '${widget.doctorData!['firstName'] ?? 'Dr.'} ${widget.doctorData!['lastName'] ?? 'Smith'}';
      });
    } else {
      // Sinon, charger depuis la base de données
      try {
        final doctorData = await _dbHelper.getDoctorData();
        if (doctorData.isNotEmpty) {
          setState(() {
            doctorName = doctorData['fullName'] ??
                '${doctorData['firstName'] ?? 'Dr.'} ${doctorData['lastName'] ?? 'Smith'}';
          });
        }
      } catch (e) {
        debugPrint('Error loading doctor data: $e');
      }
    }

    // Déterminer le salut selon l'heure
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        greeting = 'Good Morning';
      } else if (hour < 18) {
        greeting = 'Good Afternoon';
      } else {
        greeting = 'Good Evening';
      }
    });
  }

  Future<void> _loadStatistics() async {
    try {
      // Charger les statistiques depuis la base de données
      final patients = await _dbHelper.getTotalPatients();
      final appointments = await _dbHelper.getAppointments();

      // Filtrer les rendez-vous d'aujourd'hui
      final today = DateTime.now();
      final todayAppointmentsList = appointments.where((appt) {
        try {
          final apptDate = DateTime.parse(appt['date']);
          return apptDate.year == today.year &&
              apptDate.month == today.month &&
              apptDate.day == today.day;
        } catch (e) {
          return false;
        }
      }).toList();

      setState(() {
        totalPatients = patients;
        todayAppointments = todayAppointmentsList.length;
        todayConsultations = appointments.where((appt) {
          final status = (appt['status'] ?? '').toString().toLowerCase();
          return status == 'completed' || status == 'consulted';
        }).length;
        todayReports = appointments.where((appt) {
          final hasReport =
              appt['report'] != null && appt['report'].toString().isNotEmpty;
          return hasReport;
        }).length;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des statistiques: $e');
      // Valeurs par défaut en cas d'erreur
      setState(() {
        totalPatients = 124;
        todayAppointments = 18;
        todayConsultations = 12;
        todayReports = 8;
        isLoading = false;
      });
    }
  }

  void _navigateToPage(int index) {
    Widget page;
    switch (index) {
      case 0:
        return; // Page actuelle
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
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Welcome Header
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting,',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Have a nice day at work',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👋', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ],
                ),
              ),

              // Daily Tracker Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Tracker',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tracker Cards Grid
                      isLoading
                          ? const Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Expanded(
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 1.2,
                                children: [
                                  _buildTrackerCard(
                                    icon: Icons.people_outline,
                                    title: 'Total Patients',
                                    count: totalPatients.toString(),
                                    color:
                                        const Color.fromARGB(255, 90, 196, 245),
                                  ),
                                  _buildTrackerCard(
                                    icon: Icons.calendar_today,
                                    title: 'Appointments',
                                    count: todayAppointments.toString(),
                                    color:
                                        const Color.fromARGB(255, 76, 175, 230),
                                  ),
                                  _buildTrackerCard(
                                    icon: Icons.medical_services_outlined,
                                    title: 'Consultations',
                                    count: todayConsultations.toString(),
                                    color: const Color.fromARGB(
                                        255, 100, 210, 255),
                                  ),
                                  _buildTrackerCard(
                                    icon: Icons.assignment_outlined,
                                    title: 'Reports',
                                    count: todayReports.toString(),
                                    color:
                                        const Color.fromARGB(255, 85, 190, 240),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
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

  Widget _buildTrackerCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
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
    final isSelected = index == 0;
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
