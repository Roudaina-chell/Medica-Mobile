// pages/profilAd.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'home_admin.dart';

class ProfilAdmin extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfilAdmin({Key? key, this.userData}) : super(key: key);

  @override
  State<ProfilAdmin> createState() => _ProfilAdminState();
}

class _ProfilAdminState extends State<ProfilAdmin>
    with TickerProviderStateMixin {
  Map<String, dynamic>? adminData;
  bool isLoading = true;
  int _selectedIndex = 3;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadAdminData();

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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();

      if (widget.userData != null) {
        adminData = widget.userData;
      } else {
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
            textAlign: TextAlign.center,
            style: TextStyle(
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Déconnexion',
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
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    feature,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    'Bientôt disponible',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2DB4F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
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
              stops: const [0.0, 0.5, 1.0],
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
                  'Chargement...',
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
                  child: Row(
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
                              color: const Color(0xFF2DB4F6).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Admin Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Profile Card - Main
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
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
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFF2DB4F6).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Photo de profil avec badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2DB4F6),
                                    Color(0xFF1E88E5),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2DB4F6)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFB74D),
                                      Color(0xFFFF9800),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF9800)
                                          .withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Nom
                        Text(
                          getAdminName(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 6),

                        // Email
                        Text(
                          getAdminEmail(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 14),

                        // Badge Admin
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2DB4F6),
                                Color(0xFF1E88E5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2DB4F6).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Administrateur Principal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Menu Options
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 14),

                          _buildMenuOption(
                            icon: Icons.edit_rounded,
                            title: 'Modifier le profil',
                            emoji: '✏️',
                            color: const Color(0xFF2DB4F6),
                            onTap: () {
                              Navigator.pushNamed(context, '/Madmin');
                            },
                          ),
                          const SizedBox(height: 10),

                          _buildMenuOption(
                            icon: Icons.notifications_rounded,
                            title: 'Notifications',
                            emoji: '🔔',
                            color: const Color(0xFF1E88E5),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/notificationAd',
                                arguments: widget.userData,
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          _buildMenuOption(
                            icon: Icons.security_rounded,
                            title: 'Sécurité',
                            emoji: '🔒',
                            color: const Color(0xFF43A047),
                            onTap: () => _showComingSoon('Sécurité'),
                          ),
                          const SizedBox(height: 10),

                          _buildMenuOption(
                            icon: Icons.visibility_rounded,
                            title: 'Voir Profile',
                            emoji: '👤',
                            color: const Color(0xFF7E57C2),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/viewPa',
                                arguments: adminData,
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          _buildMenuOption(
                            icon: Icons.help_rounded,
                            title: 'Aide & Support',
                            emoji: '❓',
                            color: const Color(0xFFFF9800),
                            onTap: () => _showComingSoon('Aide & Support'),
                          ),

                          const SizedBox(height: 20),

                          // Logout button - Special style
                          _buildMenuOption(
                            icon: Icons.logout_rounded,
                            title: 'Déconnexion',
                            emoji: '🚪',
                            color: const Color(0xFFFF6B6B),
                            isLogout: true,
                            onTap: _showLogoutDialog,
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
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

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            final dataToPass = widget.userData ?? adminData ?? {};
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeAdmin(
                  userData: dataToPass,
                ),
              ),
            );
            break;
          case 1:
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pushNamed(
              context,
              '/dashbordAd',
              arguments: widget.userData ?? adminData,
            );
            break;
          case 2:
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pushNamed(
              context,
              '/notificationAd',
              arguments: widget.userData ?? adminData,
            );
            break;
          case 3:
            setState(() {
              _selectedIndex = index;
            });
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

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String emoji,
    required Color color,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLogout
                ? [
                    const Color(0xFFFFEBEE),
                    Colors.white,
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8F9FA),
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
          border: isLogout
              ? Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isLogout ? const Color(0xFFFF6B6B) : Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
