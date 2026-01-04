// pages/profilAd.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

class ProfilAdmin extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfilAdmin({Key? key, this.userData}) : super(key: key);

  @override
  State<ProfilAdmin> createState() => _ProfilAdminState();
}

class _ProfilAdminState extends State<ProfilAdmin> {
  Map<String, dynamic>? adminData;
  bool isLoading = true;
  int _selectedIndex = 3; // Profile est sélectionné

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();

      // Si userData est fourni, l'utiliser
      if (widget.userData != null) {
        adminData = widget.userData;
      } else {
        // Sinon, charger l'admin par défaut
        final admin = await dbHelper.getUserByCarteId(1234567890);
        adminData = admin;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des données admin: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getAdminName() {
    if (adminData == null) return 'Administrateur';
    return adminData!['fullName']?.toString() ?? 'Administrateur Principal';
  }

  String getAdminEmail() {
    if (adminData == null) return 'admin@hospital.dz';
    return adminData!['email']?.toString() ?? 'admin@hospital.dz';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Déconnexion'),
            ],
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🚀 ', style: TextStyle(fontSize: 18)),
            Expanded(
              child: Text('$feature - Fonctionnalité à venir'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2DB4F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
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
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF2DB4F6),
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Menu Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Photo de profil et badge admin
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: Color(0xFF2DB4F6),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange,
                              Colors.deepOrange,
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Nom et email
                Text(
                  getAdminName(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  getAdminEmail(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 12),

                // Badge administrateur
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.shield, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Administrateur Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Menu d'actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuOption(
                        icon: Icons.edit,
                        title: 'Modifier le profil',
                        emoji: '✏️',
                        onTap: () {
                          Navigator.pushNamed(context, '/Madmin');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        emoji: '🔔',
                        onTap: () => _showComingSoon('Notifications'),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        icon: Icons.security,
                        title: 'Sécurité',
                        emoji: '🔒',
                        onTap: () => _showComingSoon('Sécurité'),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        icon: Icons.visibility,
                        title: 'Voir Profile',
                        emoji: '👤',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/viewPa',
                            arguments: adminData,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        icon: Icons.help,
                        title: 'Aide & Support',
                        emoji: '❓',
                        onTap: () => _showComingSoon('Aide & Support'),
                      ),
                      const SizedBox(height: 20),
                      _buildMenuOption(
                        icon: Icons.logout,
                        title: 'Déconnexion',
                        emoji: '🚪',
                        color: Colors.red,
                        onTap: _showLogoutDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 0),
            _buildNavItem(Icons.visibility_outlined, 1),
            _buildNavItem(Icons.notifications_outlined, 2),
            _buildNavItem(Icons.person_outline_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pop(context);
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black54,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String emoji,
    Color? color,
    required VoidCallback onTap,
  }) {
    final itemColor = color ?? const Color(0xFF2DB4F6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    itemColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: itemColor, size: 24),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: itemColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
