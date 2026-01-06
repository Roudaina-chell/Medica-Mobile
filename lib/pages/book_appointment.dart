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

class _BookAppointmentPageState extends State<BookAppointmentPage> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un patient')),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une heure')),
      );
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

      // Naviguer vers la page de confirmation
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _searchPatientByCarteId() async {
    final carteId = _carteIdController.text.trim();

    if (carteId.isEmpty) {
      setState(() {
        searchError = 'Veuillez entrer un numéro de carte nationale';
      });
      return;
    }

    final carteIdInt = int.tryParse(carteId);
    if (carteIdInt == null) {
      setState(() {
        searchError = 'Numéro de carte invalide';
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
          searchError = 'Aucun patient trouvé avec cette carte nationale';
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

      // Fermer le dialogue si le patient est trouvé
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        searchError = 'Erreur lors de la recherche: $e';
        isSearching = false;
      });
    }
  }

  void _showPatientSelectionDialog() {
    // Réinitialiser la recherche
    _carteIdController.clear();
    searchError = null;
    isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  const Text(
                    'Rechercher un patient',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Entrez le numéro de carte nationale du patient pour le rechercher',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  // Formulaire de recherche
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _carteIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 1234567890',
                        hintStyle:
                            TextStyle(color: Colors.grey[500], fontSize: 16),
                        prefixIcon:
                            Icon(Icons.credit_card, color: Colors.blue[700]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        labelText: 'Numéro de Carte Nationale',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Message d'erreur
                  if (searchError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        searchError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // Bouton de recherche
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB1FF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1DB1FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _searchPatientByCarteId,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: isSearching
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Rechercher le patient',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Séparateur
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Liste des patients existants
                  Text(
                    'Sélectionner parmi les patients existants',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: isLoadingPatients
                        ? const Center(child: CircularProgressIndicator())
                        : patients.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aucun patient disponible',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
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

                                  return Card(
                                    elevation: isSelected ? 2 : 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: isSelected
                                        ? const Color(0xFF1DB1FF)
                                            .withOpacity(0.1)
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected
                                            ? const Color(0xFF1DB1FF)
                                            : Colors.grey[200]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected
                                            ? const Color(0xFF1DB1FF)
                                            : Colors.blue[100],
                                        child: Icon(
                                          Icons.person,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.blue[700],
                                        ),
                                      ),
                                      title: Text(
                                        fullName.isNotEmpty
                                            ? fullName
                                            : 'Sans nom',
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFF1DB1FF)
                                              : Colors.black,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            'Carte: ${patient['carte_id'] ?? 'N/A'}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          if (patient['email'] != null &&
                                              patient['email']
                                                  .toString()
                                                  .isNotEmpty)
                                            Text(
                                              'Email: ${patient['email']}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: isSelected
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF1DB1FF),
                                              size: 28,
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          selectedPatient = patient;
                                          _patientController.text = fullName;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              selectedPatient = null;
                              _patientController.text = '';
                            });
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Effacer la sélection',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB1FF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Fermer',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
              const Color.fromARGB(255, 123, 207, 252),
              const Color.fromARGB(255, 226, 236, 242),
            ],
            stops: const [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
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
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Book an Appointment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
        const Text(
          'Select Patient',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showPatientSelectionDialog,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _patientController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: selectedPatient != null
                    ? ''
                    : 'Cliquez pour sélectionner un patient',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
        if (selectedPatient != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient sélectionné:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        selectedPatient!['fullName'] ??
                            '${selectedPatient!['firstName']} ${selectedPatient!['lastName']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedPatient!['carte_id'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Carte nationale: ${selectedPatient!['carte_id']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
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
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
          icon: const Icon(Icons.chevron_left, size: 28),
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
            const SizedBox(width: 16),
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
          icon: const Icon(Icons.chevron_right, size: 28),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 16)),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        fontSize: 14,
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
          color: isSelected ? const Color(0xFF1DB1FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            dayNumber?.toString() ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : isCurrentMonth
                      ? Colors.black
                      : Colors.grey[300],
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
        const Text(
          'Select Hour',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1DB1FF) : Colors.white,
                  border: Border.all(color: const Color(0xFF1DB1FF), width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1DB1FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
        color: const Color(0xFF1DB1FF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB1FF).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveAppointment,
          borderRadius: BorderRadius.circular(28),
          child: const Center(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          _buildNavItem(Icons.calendar_month, 3, isSelected: true),
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
    super.dispose();
  }
}

// AppointmentNotificationPage
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
              const Color.fromARGB(255, 123, 207, 252),
              const Color.fromARGB(255, 226, 236, 242),
            ],
            stops: const [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1DB1FF).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1DB1FF),
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Success Message
                  const Text(
                    'Appointment Booked!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Your appointment has been successfully scheduled.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Appointment Details Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                          Icons.person,
                          'Patient',
                          patientName.isEmpty ? 'Not specified' : patientName,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Date',
                          '${date.day} ${_getMonthName(date.month)} ${date.year}',
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          Icons.access_time,
                          'Time',
                          time.isEmpty ? 'Not selected' : time,
                        ),
                        if (doctorData != null) ...[
                          const SizedBox(height: 20),
                          _buildDetailRow(
                            Icons.medical_services,
                            'Doctor',
                            doctorData?['fullName'] ??
                                '${doctorData?['firstName']} ${doctorData?['lastName']}',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Back to Home Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB1FF),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1DB1FF).withOpacity(0.3),
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
                        borderRadius: BorderRadius.circular(28),
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
            color: const Color(0xFF1DB1FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1DB1FF), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
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
