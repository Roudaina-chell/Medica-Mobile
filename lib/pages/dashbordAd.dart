// pages/dashbordAd.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

class DashboardAdmin extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const DashboardAdmin({Key? key, this.userData}) : super(key: key);

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 1;
  int _selectedTab = 0; // 0 = Patients, 1 = Doctors
  bool _isLoading = true;
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();

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

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final allDoctors = await dbHelper.getAllDoctors();
      final allPatients = await dbHelper.getAllPatients();

      // Normaliser les données des patients pour qu'elles aient toujours les mêmes noms d'attributs
      final normalizedPatients = allPatients.map((patient) {
        final Map<String, dynamic> normalized = Map.from(patient);

        // Gérer les attributs avec des noms différents
        if (patient['firstName'] == null && patient['prenom'] != null) {
          normalized['firstName'] = patient['prenom'];
        }
        if (patient['lastName'] == null && patient['nom'] != null) {
          normalized['lastName'] = patient['nom'];
        }
        if (patient['gender'] == null && patient['sexe'] != null) {
          normalized['gender'] = patient['sexe'];
        }
        if (patient['dateOfBirth'] == null &&
            patient['date_naissance'] != null) {
          normalized['dateOfBirth'] = patient['date_naissance'];
        }

        // Créer fullName si manquant
        if (patient['fullName'] == null) {
          final firstName = normalized['firstName'] ?? '';
          final lastName = normalized['lastName'] ?? '';
          normalized['fullName'] = '$firstName $lastName'.trim();
        }

        return normalized;
      }).toList();

      // Normaliser les données des docteurs
      final normalizedDoctors = allDoctors.map((doctor) {
        final Map<String, dynamic> normalized = Map.from(doctor);

        // Gérer les attributs avec des noms différents
        if (doctor['firstName'] == null && doctor['prenom'] != null) {
          normalized['firstName'] = doctor['prenom'];
        }
        if (doctor['lastName'] == null && doctor['nom'] != null) {
          normalized['lastName'] = doctor['nom'];
        }
        if (doctor['gender'] == null && doctor['sexe'] != null) {
          normalized['gender'] = doctor['sexe'];
        }

        // Créer fullName si manquant
        if (doctor['fullName'] == null) {
          final firstName = normalized['firstName'] ?? '';
          final lastName = normalized['lastName'] ?? '';
          normalized['fullName'] = '$firstName $lastName'.trim();
        }

        return normalized;
      }).toList();

      setState(() {
        doctors = normalizedDoctors;
        filteredDoctors = normalizedDoctors;
        patients = normalizedPatients;
        filteredPatients = normalizedPatients;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement données: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDoctors = doctors;
        filteredPatients = patients;
      } else {
        // Search doctors
        filteredDoctors = doctors.where((doctor) {
          final fullName = doctor['fullName']?.toString().toLowerCase() ?? '';
          final firstName = doctor['firstName']?.toString().toLowerCase() ?? '';
          final lastName = doctor['lastName']?.toString().toLowerCase() ?? '';
          final specialite =
              doctor['specialite']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return fullName.contains(searchLower) ||
              firstName.contains(searchLower) ||
              lastName.contains(searchLower) ||
              specialite.contains(searchLower);
        }).toList();

        // Search patients
        filteredPatients = patients.where((patient) {
          final fullName = patient['fullName']?.toString().toLowerCase() ?? '';
          final firstName =
              patient['firstName']?.toString().toLowerCase() ?? '';
          final lastName = patient['lastName']?.toString().toLowerCase() ?? '';
          final carteId = patient['carte_id']?.toString() ?? '';
          final searchLower = query.toLowerCase();

          return fullName.contains(searchLower) ||
              firstName.contains(searchLower) ||
              lastName.contains(searchLower) ||
              carteId.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _deleteItem(int carteId, String name, bool isDoctor) async {
    final itemType = isDoctor ? 'Docteur' : 'Patient';
    final prefix = isDoctor ? 'Dr.' : '';

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFEE5A6F),
                  ],
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
                Icons.delete_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Supprimer $itemType',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment supprimer $prefix $name ?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
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
                    'Annuler',
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
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Supprimer',
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
      ),
    );

    if (confirm == true) {
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.deleteUserByCarteId(carteId);

        if (!mounted) return;

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
                Expanded(
                  child: Text(
                    '$prefix $name supprimé avec succès',
                    style: const TextStyle(fontWeight: FontWeight.w500),
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

        _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  void _showEditDialog(Map<String, dynamic> item, bool isDoctor) {
    final itemType = isDoctor ? 'Docteur' : 'Patient';
    final firstNameController =
        TextEditingController(text: item['firstName'] ?? '');
    final lastNameController =
        TextEditingController(text: item['lastName'] ?? '');
    final emailController = TextEditingController(text: item['email'] ?? '');
    final phoneController = TextEditingController(text: item['phone'] ?? '');
    final dateOfBirthController =
        TextEditingController(text: item['dateOfBirth'] ?? '');
    final addressController =
        TextEditingController(text: item['address'] ?? '');
    final specialiteController =
        TextEditingController(text: item['specialite'] ?? '');

    // Récupérer le gender depuis les différents noms possibles
    final genderValue = item['gender'] ?? item['sexe'] ?? 'Homme';
    final genderController = TextEditingController(text: genderValue);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                Text(
                  'Modifier $itemType',
                  style: const TextStyle(
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
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: const Icon(Icons.person_outline),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: const Icon(Icons.person_outline),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: const Icon(Icons.phone_outlined),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateOfBirthController,
                    decoration: InputDecoration(
                      labelText: 'Date de naissance',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Adresse',
                      prefixIcon: const Icon(Icons.location_on_outlined),
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
                    ),
                  ),
                  if (isDoctor) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: specialiteController,
                      decoration: InputDecoration(
                        labelText: 'Spécialité',
                        prefixIcon: const Icon(Icons.medical_services_outlined),
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
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: genderController.text,
                    decoration: InputDecoration(
                      labelText: 'Genre',
                      prefixIcon: const Icon(Icons.person_outline),
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
                    ),
                    items: ['Homme', 'Femme'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        genderController.text = newValue ?? 'Homme';
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
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
                        'Annuler',
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
                        try {
                          final dbHelper = DatabaseHelper();
                          await dbHelper.updateUserByCarteId(
                            item['carte_id'],
                            {
                              'firstName': firstNameController.text,
                              'lastName': lastNameController.text,
                              'email': emailController.text,
                              'phone': phoneController.text,
                              'dateOfBirth': dateOfBirthController.text,
                              'address': addressController.text,
                              'gender': genderController.text,
                              if (isDoctor)
                                'specialite': specialiteController.text,
                            },
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _loadData();

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
                                  Expanded(
                                    child: Text(
                                      '$itemType modifié avec succès',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
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
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: const Color(0xFFFF6B6B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          );
                        }
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
                        'Enregistrer',
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                  color:
                                      const Color(0xFF2DB4F6).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.dashboard_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tab Selector - Patients vs Doctors
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Color(0xFFF8F9FA),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DB4F6).withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTab = 0;
                                    _searchController.clear();
                                    _searchData('');
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: _selectedTab == 0
                                        ? const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF2DB4F6),
                                              Color(0xFF1E88E5),
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _selectedTab == 0
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF2DB4F6)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_rounded,
                                        color: _selectedTab == 0
                                            ? Colors.white
                                            : Colors.black45,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Patients',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 0
                                              ? Colors.white
                                              : Colors.black45,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTab = 1;
                                    _searchController.clear();
                                    _searchData('');
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: _selectedTab == 1
                                        ? const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF2DB4F6),
                                              Color(0xFF1E88E5),
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _selectedTab == 1
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF2DB4F6)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.medical_services_rounded,
                                        color: _selectedTab == 1
                                            ? Colors.white
                                            : Colors.black45,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Doctors',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 1
                                              ? Colors.white
                                              : Colors.black45,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Stats Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: _selectedTab == 0
                                  ? Icons.people_rounded
                                  : Icons.medical_services_rounded,
                              count: _selectedTab == 0
                                  ? patients.length.toString()
                                  : doctors.length.toString(),
                              label: _selectedTab == 0 ? 'Patients' : 'Doctors',
                              color: const Color(0xFF2DB4F6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.search_rounded,
                              count: _selectedTab == 0
                                  ? filteredPatients.length.toString()
                                  : filteredDoctors.length.toString(),
                              label: 'Results',
                              color: const Color(0xFF1E88E5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Search Bar
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 4),
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
                                  onChanged: _searchData,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: _selectedTab == 0
                                        ? 'Search for patients...'
                                        : 'Search for doctors...',
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
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
                                    _searchData('');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
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

                const SizedBox(height: 16),

                // Data Table - NOW WITH HORIZONTAL SCROLL
                Expanded(
                  child: Container(
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
                        BoxShadow(
                          color: const Color(0xFF2DB4F6).withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Header - SCROLLABLE
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1.8,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DB4F6).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    'National ID',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E88E5),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    'Full Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E88E5),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Gender',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E88E5),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (_selectedTab == 1)
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Speciality',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E88E5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    'Actions',
                                    style: const TextStyle(
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

                        // Table Body
                        Expanded(
                          child: _isLoading
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
                                        'Loading data...',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : (_selectedTab == 0
                                          ? filteredPatients
                                          : filteredDoctors)
                                      .isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            _selectedTab == 0
                                                ? 'Aucun patient trouvé'
                                                : 'Aucun docteur trouvé',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Essayez une autre recherche',
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: EdgeInsets.zero,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _selectedTab == 0
                                          ? filteredPatients.length
                                          : filteredDoctors.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        height: 1,
                                        color: Colors.grey.shade200,
                                      ),
                                      itemBuilder: (context, index) {
                                        final item = _selectedTab == 0
                                            ? filteredPatients[index]
                                            : filteredDoctors[index];
                                        return _buildTableRow(
                                            item, index, _selectedTab == 1);
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
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
            _buildNavItem(Icons.home_rounded, 0, 'Home'),
            _buildNavItem(Icons.dashboard_rounded, 1, 'Board'),
            _buildNavItem(Icons.notifications_rounded, 2, 'Alerts'),
            _buildNavItem(Icons.person_rounded, 3, 'Profile'),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
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

  Widget _buildTableRow(Map<String, dynamic> item, int index, bool isDoctor) {
    final fullName = item['fullName'] ??
        '${item['firstName'] ?? ''} ${item['lastName'] ?? ''}'.trim();
    final carteId = item['carte_id']?.toString() ?? 'N/A';

    // Récupérer le gender depuis les différents noms possibles
    final gender = item['gender'] ?? item['sexe'] ?? 'N/A';

    final specialite = item['specialite']?.toString() ?? 'N/A';

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
              width: 130,
              child: Text(
                carteId,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: Text(
                fullName.isNotEmpty ? fullName : 'Sans nom',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (gender.toLowerCase() == 'homme' ||
                          gender.toLowerCase() == 'male')
                      ? const Color(0xFF2DB4F6).withOpacity(0.1)
                      : const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (gender.toLowerCase() == 'homme' ||
                            gender.toLowerCase() == 'male')
                        ? const Color(0xFF2DB4F6).withOpacity(0.3)
                        : const Color(0xFFFF6B6B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    gender,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (gender.toLowerCase() == 'homme' ||
                              gender.toLowerCase() == 'male')
                          ? const Color(0xFF2DB4F6)
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ),
            ),
            if (isDoctor)
              SizedBox(
                width: 160,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF43A047).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      specialite,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF43A047),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: 140,
              child: Row(
                children: [
                  // Edit button
                  GestureDetector(
                    onTap: () => _showEditDialog(item, isDoctor),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2DB4F6).withOpacity(0.15),
                            const Color(0xFF2DB4F6).withOpacity(0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: Color(0xFF2DB4F6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete button
                  GestureDetector(
                    onTap: () =>
                        _deleteItem(item['carte_id'], fullName, isDoctor),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B6B).withOpacity(0.15),
                            const Color(0xFFFF6B6B).withOpacity(0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        size: 18,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/homeAd', arguments: widget.userData);
            break;
          case 1:
            // Stay on dashboard
            break;
          case 2:
            Navigator.pushNamed(
              context,
              '/notificationAd',
              arguments: widget.userData,
            );
            break;
          case 3:
            Navigator.pushNamed(
              context,
              '/profilAd',
              arguments: widget.userData,
            );
            break;
        }
      },
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}