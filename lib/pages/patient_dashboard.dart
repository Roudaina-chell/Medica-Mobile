// pages/patient_dashboard.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'home_doctor.dart';
import 'personal_medical_edit.dart';
import 'book_appointment.dart';
import 'profile_doct.dart';
import 'notifications.dart';

class PatientDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const PatientDashboardPage({super.key, this.doctorData});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> filteredAppointments = [];
  bool isLoading = true;

  // Couleurs d'avatar pour différencier les patients
  final List<Color> avatarColors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _searchController.addListener(_filterAppointments);
  }

  Future<void> _loadAppointments() async {
    try {
      final db = DatabaseHelper();
      final data = await db.getAppointments();

      setState(() {
        appointments = data.map((appointment) {
          // Déterminer le statut et les couleurs
          final status = appointment['status'] ?? 'pending';
          final isConsulted = status.toLowerCase() == 'consulted' ||
              status.toLowerCase() == 'completed';

          return {
            'id': appointment['id'],
            'name':
                '${appointment['patient_first_name'] ?? ''} ${appointment['patient_last_name'] ?? ''}'
                    .trim(),
            'date': _formatDate(appointment['appointment_date']),
            'time': _formatTime(appointment['appointment_time']),
            'status': isConsulted ? 'Consulted' : 'Not Attended',
            'statusColor': isConsulted ? Colors.green : Colors.red,
            'icon': isConsulted ? Icons.check : Icons.close,
            'iconColor': isConsulted ? Colors.green : Colors.red,
            'avatarColor':
                avatarColors[data.indexOf(appointment) % avatarColors.length],
            'rawStatus': status,
          };
        }).toList();

        filteredAppointments = List.from(appointments);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final parts = date.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}'; // DD/MM/YYYY
        }
      }
      return date.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(dynamic time) {
    if (time == null) return 'N/A';
    try {
      if (time is String) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = parts[1];
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$displayHour:$minute $period';
        }
      }
      return time.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredAppointments = List.from(appointments);
      } else {
        filteredAppointments = appointments.where((appointment) {
          final name = appointment['name'].toString().toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
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
        return; // Current page
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

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
              // Header avec bouton retour et notifications
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        'Patient Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                      onPressed: _navigateToNotifications,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search name of patient...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Table Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Patients',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Date',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Hour',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Appointments List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 90, 196, 245),
                          ),
                        )
                      : filteredAppointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'No appointments yet'
                                        : 'No patients found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: filteredAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = filteredAppointments[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Patient Info
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: appointment['iconColor'],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                appointment['icon'],
                                                size: 8,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    appointment['avatarColor']
                                                        .withOpacity(0.2),
                                                border: Border.all(
                                                  color: appointment[
                                                      'avatarColor'],
                                                  width: 2,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: 20,
                                                color:
                                                    appointment['avatarColor'],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                appointment['name'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Date
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          appointment['date'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),

                                      // Time
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          appointment['time'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),

                                      // Status
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: appointment['statusColor'],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              appointment['status'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Navigation Bar
              _buildBottomNavBar(),
              const SizedBox(height: 10),
            ],
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
          _buildNavItem(Icons.medical_services_outlined, 2, isSelected: true),
          _buildNavItem(Icons.calendar_month, 3),
          _buildNavItem(Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool isSelected = false}) {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
