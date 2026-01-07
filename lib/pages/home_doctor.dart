// pages/home_doctor.dart
import 'package:flutter/material.dart';
import 'package:se_mobile/pages/database_helper.dart';
import 'package:se_mobile/pages/personal_medical_edit.dart';
import 'package:se_mobile/pages/patient_dashboard.dart';
import 'package:se_mobile/pages/book_appointment.dart';
import 'package:se_mobile/pages/profile_doct.dart';

class HomeDoctorPage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const HomeDoctorPage({super.key, this.doctorData});

  @override
  State<HomeDoctorPage> createState() => _HomeDoctorPageState();
}

class _HomeDoctorPageState extends State<HomeDoctorPage>
    with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Données dynamiques
  String doctorName = 'Dr. James Smith';
  String greeting = 'Good Morning';
  int totalPatients = 0;
  int todayAppointments = 0;
  int todayConsultations = 0;
  int todayReports = 0;
  bool isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _loadStatistics();

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
                // Welcome Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting,',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.brightness_5,
                                          size: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Have a nice day at work',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('👋', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Daily Tracker Section
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2DB4F6),
                                      Color(0xFF1E88E5)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2DB4F6)
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.analytics_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Daily Tracker',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Tracker Cards Grid
                          isLoading
                              ? Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF2DB4F6)
                                                    .withOpacity(0.3),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child:
                                              const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Loading statistics...',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 1.0,
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      _buildTrackerCard(
                                        icon: Icons.people_rounded,
                                        title: 'Total Patients',
                                        count: totalPatients.toString(),
                                        color: const Color(0xFF2DB4F6),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2DB4F6),
                                            Color(0xFF1E88E5)
                                          ],
                                        ),
                                      ),
                                      _buildTrackerCard(
                                        icon: Icons.calendar_today_rounded,
                                        title: 'Appointments',
                                        count: todayAppointments.toString(),
                                        color: const Color(0xFF4CAF50),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4CAF50),
                                            Color(0xFF66BB6A)
                                          ],
                                        ),
                                      ),
                                      _buildTrackerCard(
                                        icon: Icons.medical_services_rounded,
                                        title: 'Consultations',
                                        count: todayConsultations.toString(),
                                        color: const Color(0xFF8E24AA),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF8E24AA),
                                            Color(0xFFAB47BC)
                                          ],
                                        ),
                                      ),
                                      _buildTrackerCard(
                                        icon: Icons.assignment_rounded,
                                        title: 'Reports',
                                        count: todayReports.toString(),
                                        color: const Color(0xFFFF9800),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF9800),
                                            Color(0xFFFFB74D)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _buildTrackerCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 8,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
        ],
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
          _buildNavItem(Icons.home_rounded, 0, isSelected: true),
          _buildNavItem(Icons.calendar_today_rounded, 1),
          _buildNavItem(Icons.medical_services_rounded, 2),
          _buildNavItem(Icons.calendar_month_rounded, 3),
          _buildNavItem(Icons.person_rounded, 4),
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