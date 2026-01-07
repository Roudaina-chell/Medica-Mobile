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

class _PatientDashboardPageState extends State<PatientDashboardPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> filteredAppointments = [];
  Map<String, dynamic>? selectedPatient;
  bool isLoading = true;
  bool showSearchResults = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

  Future<void> _loadAppointments() async {
    try {
      final db = DatabaseHelper();
      final data = await db.getAppointments();

      setState(() {
        appointments = data.map((appointment) {
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
            'phone': appointment['patient_phone'] ?? 'N/A',
            'age': appointment['patient_age'] ?? 'N/A',
            'gender': appointment['patient_gender'] ?? 'N/A',
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
          return '${parts[2]}/${parts[1]}/${parts[0]}';
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
      showSearchResults = query.isNotEmpty;
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

  void _selectPatient(Map<String, dynamic> patient) {
    setState(() {
      selectedPatient = patient;
      showSearchResults = false;
      _searchController.clear();
    });
  }

  void _clearSelection() {
    setState(() {
      selectedPatient = null;
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
        return;
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    builder: (context) => HomeDoctorPage(
                                        doctorData: widget.doctorData),
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
                                      color: const Color(0xFF2DB4F6)
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.medical_services_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Patient Dashboard',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
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
                      const SizedBox(height: 16),

                      // Stats Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.people_rounded,
                              count: appointments.length.toString(),
                              label: 'Patients',
                              color: const Color(0xFF2DB4F6),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.search_rounded,
                              count: filteredAppointments.length.toString(),
                              label: 'Results',
                              color: const Color(0xFF1E88E5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search Bar
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
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
                                color:
                                    const Color(0xFF2DB4F6).withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 8,
                                offset: const Offset(-3, -3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF2DB4F6).withOpacity(0.1),
                                      const Color(0xFF2DB4F6).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF2DB4F6),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search for patients...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black12,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Content Area
                Expanded(
                  child: selectedPatient != null
                      ? _buildSelectedPatientView()
                      : showSearchResults
                          ? _buildSearchResults()
                          : _buildAllPatientsTable(),
                ),

                const SizedBox(height: 20),
                _buildBottomNavBar(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPatientView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2DB4F6).withOpacity(0.1),
                  const Color(0xFF1E88E5).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                GestureDetector(
                  onTap: _clearSelection,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Patient Info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          selectedPatient!['avatarColor'],
                          selectedPatient!['avatarColor'].withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedPatient!['avatarColor']
                              .withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name
                  Text(
                    selectedPatient!['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selectedPatient!['statusColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedPatient!['statusColor'],
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedPatient!['icon'],
                          color: selectedPatient!['statusColor'],
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedPatient!['status'],
                          style: TextStyle(
                            color: selectedPatient!['statusColor'],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Info Cards
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    label: 'Appointment Date',
                    value: selectedPatient!['date'],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    label: 'Appointment Time',
                    value: selectedPatient!['time'],
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: selectedPatient!['phone'],
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.cake,
                    label: 'Age',
                    value: selectedPatient!['age'].toString(),
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Gender',
                    value: selectedPatient!['gender'],
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF2DB4F6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Search Results (${filteredAppointments.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filteredAppointments.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      final patient = filteredAppointments[index];
                      return _buildSearchResultItem(patient);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> patient) {
    return InkWell(
      onTap: () => _selectPatient(patient),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: patient['avatarColor'].withOpacity(0.2),
                border: Border.all(
                  color: patient['avatarColor'],
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                color: patient['avatarColor'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${patient['date']} - ${patient['time']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: patient['statusColor'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: patient['statusColor'].withOpacity(0.3),
                ),
              ),
              child: Text(
                patient['status'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: patient['statusColor'],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPatientsTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: MediaQuery.of(context).size.width * 1.8,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2DB4F6).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: const [
                  SizedBox(
                    width: 180,
                    child: Text(
                      'Patients',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: Text(
                      'Date',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: Text(
                      'Hour',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: Text(
                      'Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
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
                                color: const Color(0xFF2DB4F6)
                                    .withOpacity(0.3),
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
                          'Loading appointments...',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredAppointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade50,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No appointments yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredAppointments.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final appointment = filteredAppointments[index];
                          return InkWell(
                            onTap: () => _selectPatient(appointment),
                            child: _buildTableRow(appointment, index),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
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

  Widget _buildTableRow(Map<String, dynamic> appointment, int index) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: MediaQuery.of(context).size.width * 1.8,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: index % 2 == 0
            ? Colors.white
            : Colors.grey.shade50.withOpacity(0.5),
        child: Row(
          children: [
            SizedBox(
              width: 180,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: appointment['iconColor'],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      appointment['icon'],
                      size: 6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appointment['avatarColor'].withOpacity(0.2),
                      border: Border.all(
                        color: appointment['avatarColor'],
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: appointment['avatarColor'],
                    ),
                  ),
                  const SizedBox(width: 6),
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
            SizedBox(
              width: 130,
              child: Text(
                appointment['date'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: Text(
                appointment['time'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: appointment['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: appointment['statusColor'].withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    appointment['status'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: appointment['statusColor'],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          _buildNavItem(Icons.medical_services_rounded, 2, isSelected: true),
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
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}