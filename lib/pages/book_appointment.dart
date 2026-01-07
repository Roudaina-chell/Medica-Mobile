// pages/book_appointment.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'home_doctor.dart';
import 'personal_medical_edit.dart';
import 'patient_dashboard.dart';
import 'profile_doct.dart';

class BookAppointmentPage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const BookAppointmentPage({Key? key, this.doctorData}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage>
    with TickerProviderStateMixin {
  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _carteIdController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  DateTime selectedDate = DateTime.now();
  String selectedMonth = _getMonthName(DateTime.now().month);
  int selectedYear = DateTime.now().year;
  String? selectedTime;
  List<Map<String, dynamic>> patients = [];
  Map<String, dynamic>? selectedPatient;
  bool isLoadingPatients = false;
  bool isSearching = false;
  String? searchError;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final List<String> timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();

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

  Future<void> _loadPatients() async {
    setState(() {
      isLoadingPatients = true;
    });

    try {
      final data = await _dbHelper.getPatients();
      setState(() {
        patients = data;
        isLoadingPatients = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des patients: $e');
      setState(() {
        isLoadingPatients = false;
      });
    }
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
        page = ProfileDoctPage(doctorData: widget.doctorData);
        break;
      default:
        return;
    }

    if (index != 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  Future<void> _saveAppointment() async {
    if (selectedPatient == null && _patientController.text.isEmpty) {
      _showNotification('Please select a patient', isError: true);
      return;
    }

    if (selectedTime == null) {
      _showNotification('Please select a time', isError: true);
      return;
    }

    final appointmentData = {
      'patientCarteId': selectedPatient?['carte_id'] ?? 0,
      'patientName': selectedPatient?['fullName'] ??
          selectedPatient?['firstName'] != null &&
                  selectedPatient?['lastName'] != null
              ? '${selectedPatient!['firstName']} ${selectedPatient!['lastName']}'
              : _patientController.text,
      'patientEmail': selectedPatient?['email'] ?? '',
      'doctorCarteId': widget.doctorData?['carte_id'] ?? 0,
      'doctorName': widget.doctorData?['fullName'] ??
          '${widget.doctorData?['firstName'] ?? 'Dr.'} ${widget.doctorData?['lastName'] ?? ''}',
      'doctorEmail': widget.doctorData?['email'] ?? '',
      'date': selectedDate.toIso8601String(),
      'time': selectedTime,
      'reason': 'Consultation générale',
      'status': 'scheduled',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      await _dbHelper.saveAppointment(appointmentData);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentNotificationPage(
            patientName: appointmentData['patientName'],
            date: selectedDate,
            time: selectedTime!,
            doctorData: widget.doctorData,
          ),
        ),
      );
    } catch (e) {
      _showNotification('Error: $e', isError: true);
    }
  }

  void _showNotification(String message, {bool isError = false}) {
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
        backgroundColor:
            isError ? const Color(0xFFFF6B6B) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _searchPatientByCarteId() async {
    final carteId = _carteIdController.text.trim();

    if (carteId.isEmpty) {
      setState(() {
        searchError = 'Please enter a national ID';
      });
      return;
    }

    final carteIdInt = int.tryParse(carteId);
    if (carteIdInt == null) {
      setState(() {
        searchError = 'Invalid national ID';
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchError = null;
    });

    try {
      final patient = await _dbHelper.getPatientByCarteId(carteIdInt);

      if (patient == null) {
        setState(() {
          searchError = 'No patient found with this national ID';
          isSearching = false;
        });
        return;
      }

      setState(() {
        selectedPatient = patient;
        _patientController.text = patient['fullName'] ??
            '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim();
        isSearching = false;
      });

      Navigator.pop(context);
      _showNotification('Patient found successfully!');
    } catch (e) {
      setState(() {
        searchError = 'Search error: $e';
        isSearching = false;
      });
    }
  }

  void _showPatientSelectionDialog() {
    _carteIdController.clear();
    searchError = null;
    isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Search Patient',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search by National ID
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FA)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Search by National ID',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2DB4F6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _carteIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter National ID...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(
                              Icons.credit_card,
                              color: Color(0xFF2DB4F6),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2DB4F6),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              searchError = null;
                            });
                          },
                        ),
                        if (searchError != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFFF6B6B), size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  searchError!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: isSearching
                              ? null
                              : () async {
                                  await _searchPatientByCarteId();
                                  setModalState(() {});
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2DB4F6),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Search',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Patients List
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DB4F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Color(0xFF2DB4F6),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Select from existing patients',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: isLoadingPatients
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
                                  'Loading patients...',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : patients.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person_off,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No patients available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: patients.length,
                                itemBuilder: (context, index) {
                                  final patient = patients[index];
                                  final fullName = patient['fullName'] ??
                                      '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'
                                          .trim();
                                  final isSelected =
                                      selectedPatient?['carte_id'] ==
                                          patient['carte_id'];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSelected
                                            ? [
                                                const Color(0xFF2DB4F6)
                                                    .withOpacity(0.15),
                                                const Color(0xFF1E88E5)
                                                    .withOpacity(0.1),
                                              ]
                                            : [Colors.white, const Color(0xFFF8F9FA)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF2DB4F6)
                                            : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF2DB4F6)
                                                    .withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isSelected
                                                ? [
                                                    const Color(0xFF2DB4F6),
                                                    const Color(0xFF1E88E5)
                                                  ]
                                                : [
                                                    const Color(0xFF2DB4F6)
                                                        .withOpacity(0.2),
                                                    const Color(0xFF1E88E5)
                                                        .withOpacity(0.1),
                                                  ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF2DB4F6),
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        fullName.isNotEmpty
                                            ? fullName
                                            : 'No name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isSelected
                                              ? const Color(0xFF2DB4F6)
                                              : Colors.black87,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${patient['carte_id'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          if (patient['email'] != null &&
                                              patient['email']
                                                  .toString()
                                                  .isNotEmpty)
                                            Text(
                                              patient['email'],
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: isSelected
                                          ? Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF2DB4F6),
                                                    Color(0xFF1E88E5)
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          selectedPatient = patient;
                                          _patientController.text = fullName;
                                        });
                                        Navigator.pop(context);
                                        _showNotification(
                                            'Patient selected: $fullName');
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                _buildAppBar(),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildPatientSelector(),
                          const SizedBox(height: 24),
                          _buildDateSelector(),
                          const SizedBox(height: 24),
                          _buildTimeSelector(),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomNavBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
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
              onTap: () => Navigator.pop(context),
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
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                Icons.person_search_rounded,
                color: Color(0xFF2DB4F6),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Select Patient',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showPatientSelectionDialog,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedPatient != null
                        ? _patientController.text
                        : 'Tap to search or select a patient',
                    style: TextStyle(
                      color: selectedPatient != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: selectedPatient != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedPatient != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.15),
                  const Color(0xFF4CAF50).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Selected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedPatient!['fullName'] ??
                            '${selectedPatient!['firstName']} ${selectedPatient!['lastName']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedPatient!['carte_id'] != null)
                        Text(
                          'ID: ${selectedPatient!['carte_id']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                Icons.calendar_today_rounded,
                color: Color(0xFF2DB4F6),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildMonthYearSelector(),
              const SizedBox(height: 20),
              _buildCalendar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF2DB4F6).withOpacity(0.1),
          ),
          icon: const Icon(Icons.chevron_left, color: Color(0xFF2DB4F6)),
        ),
        Row(
          children: [
            _buildDropdown(
              value: selectedMonth,
              items: months,
              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                  _updateSelectedDate();
                });
              },
            ),
            const SizedBox(width: 12),
            _buildDropdown(
              value: selectedYear.toString(),
              items: List.generate(
                  5, (index) => (DateTime.now().year + index).toString()),
              onChanged: (value) {
                setState(() {
                  selectedYear = int.parse(value!);
                  _updateSelectedDate();
                });
              },
            ),
          ],
        ),
        IconButton(
          onPressed: _nextMonth,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF2DB4F6).withOpacity(0.1),
          ),
          icon: const Icon(Icons.chevron_right, color: Color(0xFF2DB4F6)),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2DB4F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2DB4F6).withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(
            color: Color(0xFF2DB4F6),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final monthIndex = months.indexOf(selectedMonth) + 1;
    final daysInMonth = DateTime(selectedYear, monthIndex + 1, 0).day;
    final firstDayOfMonth = DateTime(selectedYear, monthIndex, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
              .map(
                (day) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2DB4F6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        ...List.generate(6, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber =
                    weekIndex * 7 + dayIndex - weekdayOfFirstDay + 1;
                final isCurrentMonth =
                    dayNumber > 0 && dayNumber <= daysInMonth;
                final isSelected = isCurrentMonth &&
                    selectedDate.day == dayNumber &&
                    selectedDate.month == monthIndex &&
                    selectedDate.year == selectedYear;

                return _buildDayCell(
                  dayNumber: isCurrentMonth ? dayNumber : null,
                  isSelected: isSelected,
                  isCurrentMonth: isCurrentMonth,
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDayCell({
    required int? dayNumber,
    required bool isSelected,
    required bool isCurrentMonth,
  }) {
    return GestureDetector(
      onTap: dayNumber != null
          ? () {
              setState(() {
                selectedDate = DateTime(
                  selectedYear,
                  months.indexOf(selectedMonth) + 1,
                  dayNumber,
                );
              });
            }
          : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2DB4F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            dayNumber?.toString() ?? '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isCurrentMonth
                      ? Colors.black87
                      : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                Icons.access_time_rounded,
                color: Color(0xFF2DB4F6),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((time) {
            final isSelected = selectedTime == time;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTime = time;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                        )
                      : const LinearGradient(
                          colors: [Colors.white, Color(0xFFF8F9FA)],
                        ),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2DB4F6)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2DB4F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DB4F6).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveAppointment,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Save Appointment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
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
          _buildNavItem(Icons.calendar_month_rounded, 3, isSelected: true),
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

  void _previousMonth() {
    setState(() {
      int monthIndex = months.indexOf(selectedMonth);
      if (monthIndex > 0) {
        selectedMonth = months[monthIndex - 1];
      } else {
        selectedMonth = months[11];
        selectedYear--;
      }
      _updateSelectedDate();
    });
  }

  void _nextMonth() {
    setState(() {
      int monthIndex = months.indexOf(selectedMonth);
      if (monthIndex < 11) {
        selectedMonth = months[monthIndex + 1];
      } else {
        selectedMonth = months[0];
        selectedYear++;
      }
      _updateSelectedDate();
    });
  }

  void _updateSelectedDate() {
    final monthIndex = months.indexOf(selectedMonth) + 1;
    final daysInMonth = DateTime(selectedYear, monthIndex + 1, 0).day;
    final day = selectedDate.day > daysInMonth ? daysInMonth : selectedDate.day;
    selectedDate = DateTime(selectedYear, monthIndex, day);
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _patientController.dispose();
    _carteIdController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}

// AppointmentNotificationPage stays the same - keeping it simple since it's a success page
class AppointmentNotificationPage extends StatelessWidget {
  final String patientName;
  final DateTime date;
  final String time;
  final Map<String, dynamic>? doctorData;

  const AppointmentNotificationPage({
    Key? key,
    required this.patientName,
    required this.date,
    required this.time,
    this.doctorData,
  }) : super(key: key);

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Appointment Booked!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your appointment has been successfully scheduled.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FA)],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                        _buildDetailRow(
                          Icons.person_rounded,
                          'Patient',
                          patientName.isEmpty ? 'Not specified' : patientName,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          Icons.calendar_today_rounded,
                          'Date',
                          '${date.day} ${_getMonthName(date.month)} ${date.year}',
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          Icons.access_time_rounded,
                          'Time',
                          time.isEmpty ? 'Not selected' : time,
                        ),
                        if (doctorData != null) ...[
                          const SizedBox(height: 20),
                          _buildDetailRow(
                            Icons.medical_services_rounded,
                            'Doctor',
                            doctorData?['fullName'] ??
                                '${doctorData?['firstName']} ${doctorData?['lastName']}',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2DB4F6).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomeDoctorPage(doctorData: doctorData),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Back to Home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2DB4F6).withOpacity(0.15),
                const Color(0xFF2DB4F6).withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2DB4F6), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}