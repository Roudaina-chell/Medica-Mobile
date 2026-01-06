// pages/Doctors.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

class Doctors extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const Doctors({Key? key, this.userData}) : super(key: key);

  @override
  State<Doctors> createState() => _DoctorsState();
}

class _DoctorsState extends State<Doctors> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool isLoading = true;
  List<Map<String, dynamic>> doctors = [];
  List<String> specialties = ['All'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    _loadDoctors();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final doctorsList = await dbHelper.getAllDoctors();

      // Extraire les spécialités uniques
      Set<String> uniqueSpecialties = {'All'};
      for (var doctor in doctorsList) {
        final specialty = doctor['specialite']?.toString() ??
            doctor['speciality']?.toString();
        if (specialty != null && specialty.isNotEmpty) {
          uniqueSpecialties.add(specialty);
        }
      }

      setState(() {
        doctors = doctorsList.map((doctor) {
          // Utiliser les champs exacts de votre base de données
          final firstName = doctor['firstName']?.toString() ??
              doctor['prenom']?.toString() ??
              '';
          final lastName =
              doctor['lastName']?.toString() ?? doctor['nom']?.toString() ?? '';
          final fullName =
              doctor['fullName']?.toString() ?? '$firstName $lastName'.trim();

          return {
            'id': doctor['carte_id'],
            'name': fullName.isEmpty ? 'Dr. Unknown' : fullName,
            'specialty': doctor['specialite']?.toString() ??
                doctor['speciality']?.toString() ??
                'Général',
            'experience':
                _calculateExperience(doctor['dateOfBirth']?.toString()),
            'rating': 4.5,
            'patients': 100,
            'isFavorite': false,
            'available': true,
            'nextAvailable': 'Aujourd\'hui',
            'email': doctor['email']?.toString() ?? '',
            'phone': doctor['phone']?.toString() ?? '',
            'carteNationale': doctor['carte_id']?.toString() ?? '',
            'gender': doctor['gender']?.toString() ?? '',
            'address': doctor['address']?.toString() ?? '',
            'deploymentFile': doctor['deploymentFile']?.toString() ?? '',
          };
        }).toList();

        specialties = uniqueSpecialties.toList();
        isLoading = false;
      });

      debugPrint(
          '✅ ${doctors.length} docteurs chargés depuis la base de données');
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des docteurs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _calculateExperience(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) return '5 ans';

    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      final experience = (age - 25).clamp(1, 40);
      return '$experience ans';
    } catch (e) {
      return '5 ans';
    }
  }

  List<Map<String, dynamic>> get filteredDoctors {
    return doctors.where((doctor) {
      final matchesSearch = doctor['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesSpecialty = _selectedSpecialty == 'All' ||
          doctor['specialty'] == _selectedSpecialty;
      return matchesSearch && matchesSpecialty;
    }).toList();
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
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DB4F6).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    color: Color(0xFF2DB4F6),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chargement des docteurs...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildSpecialtyFilter(),
                Expanded(
                  child: _buildDoctorsList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF2DB4F6),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trouvez votre',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Médecin (${doctors.length})',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/notificationPa',
                arguments: widget.userData,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF2DB4F6),
                    size: 24,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Rechercher un médecin...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    if (specialties.length <= 1) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          final isSelected = specialty == _selectedSpecialty;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSpecialty = specialty;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF2DB4F6).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  specialty,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsList() {
    final filteredList = filteredDoctors;

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              doctors.isEmpty
                  ? 'Aucun docteur dans la base de données'
                  : 'Aucun médecin trouvé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (doctors.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addD');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un docteur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DB4F6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildDoctorCard(filteredList[index], index);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _showDoctorDetails(doctor);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar avec initiales ou icône genre
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2DB4F6).withOpacity(0.8),
                        const Color(0xFF1E88E5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DB4F6).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(doctor['name']),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                doctor['isFavorite'] = !doctor['isFavorite'];
                              });
                            },
                            child: Icon(
                              doctor['isFavorite']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: doctor['isFavorite']
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor['specialty'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.star,
                            doctor['rating'].toString(),
                            const Color(0xFFFFB300),
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.work_outline,
                            doctor['experience'],
                            const Color(0xFF2DB4F6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: doctor['available']
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            doctor['available']
                                ? 'Disponible • ${doctor['nextAvailable']}'
                                : 'Indisponible • ${doctor['nextAvailable']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: doctor['available']
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
        .toUpperCase();
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF2DB4F6).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(doctor['name']),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            doctor['name'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor['specialty'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (doctor['gender']?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                doctor['gender'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.star,
                          doctor['rating'].toString(),
                          'Note',
                          const Color(0xFFFFB300),
                        ),
                        _buildStatItem(
                          Icons.people,
                          '${doctor['patients']}+',
                          'Patients',
                          const Color(0xFF2DB4F6),
                        ),
                        _buildStatItem(
                          Icons.workspace_premium,
                          doctor['experience'],
                          'Expérience',
                          const Color(0xFF7E57C2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Informations de contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (doctor['email']?.isNotEmpty ?? false)
                      _buildInfoRow(Icons.email, doctor['email']),
                    if (doctor['phone']?.isNotEmpty ?? false)
                      _buildInfoRow(Icons.phone, doctor['phone']),
                    if (doctor['carteNationale']?.isNotEmpty ?? false)
                      _buildInfoRow(
                          Icons.badge, 'CN: ${doctor['carteNationale']}'),
                    if (doctor['address']?.isNotEmpty ?? false)
                      _buildInfoRow(Icons.location_on, doctor['address']),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/Schedul_appo',
                            arguments: widget.userData,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2DB4F6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Prendre Rendez-vous',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2DB4F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2DB4F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
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
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.medical_services_rounded, 0),
          _buildNavItem(Icons.folder_rounded, 1),
          _buildNavItem(Icons.history_rounded, 2),
          _buildNavItem(Icons.calendar_today_rounded, 3),
          _buildNavItem(Icons.person_rounded, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 0) return;

        setState(() {
          _selectedIndex = index;
        });

        String route = '';
        switch (index) {
          case 1:
            route = '/p_md_record';
            break;
          case 2:
            route = '/history_consu';
            break;
          case 3:
            route = '/Schedul_appo';
            break;
          case 4:
            route = '/Profile';
            break;
        }

        if (route.isNotEmpty) {
          Navigator.pushNamed(
            context,
            route,
            arguments: widget.userData,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2DB4F6), Color(0xFF1E88E5)],
                )
              : null,
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
          size: 22,
        ),
      ),
    );
  }
}
