// pages/init_accounts.dart
import 'package:flutter/material.dart';
import 'Profile.dart';
import 'SignUp.dart';
import 'database_helper.dart';

// Imports des pages d'accueil selon les rôles
// import 'home_system.dart'; // Pour le rôle system (Non utilisé)
// import 'home_administ.dart'; // Pour le rôle nurse_admin (À corriger)
// import 'home_doctor.dart'; // Pour le rôle medecin (Non utilisé)

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _rememberMe = true;
  bool _obscurePassword = true;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  // Fonction pour rediriger selon le rôle
  void _navigateToHome(String role, Map<String, dynamic> userData) {
    Widget destination;

    switch (role) {
      case 'admin':
        // Admin principal - Gère tout (patients et médecins)
        // TODO: Remplacer par HomeAdmin quand disponible
        destination = Profile(
          username: userData['fullName']?.toString() ?? 'Utilisateur',
          email: userData['email']?.toString() ?? '',
          role: role,
        );
        break;

      case 'patient':
      default:
        destination = Profile(
          username: userData['fullName']?.toString() ?? 'Utilisateur',
          email: userData['email']?.toString() ?? '',
          role: role,
        );
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  Future<void> _signIn() async {
    if (_identifierController.text.trim().isEmpty) {
      _showSnackBar('Veuillez entrer votre email ou numéro de carte nationale');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre mot de passe');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _dbHelper.authenticateUser(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        String fullName = user['fullName']?.toString() ?? 'Utilisateur';
        String email = user['email']?.toString() ?? '';
        String role = user['role']?.toString() ?? 'patient';
        int carteId = user['carte_id'] ?? 0;

        debugPrint(
            '✅ Connexion réussie - Nom: $fullName, Email: $email, Role: $role, Carte ID: $carteId');

        if (!mounted) return;

        _showSnackBar('Connexion réussie ! Redirection...', isSuccess: true);

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Redirection selon le rôle
        _navigateToHome(role, user);
      } else {
        _showSnackBar('Identifiant ou mot de passe incorrect');
      }
    } catch (e) {
      debugPrint('❌ Erreur de connexion: $e');
      _showSnackBar('Erreur lors de la connexion: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : const Color(0xFF2DB4F6),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DB4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2DB4F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUp(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _buildTextField(
                  controller: _identifierController,
                  icon: Icons.badge_outlined,
                  hintText: 'Email ou Numéro de Carte Nationale',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  hintText: 'Mot de passe',
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _rememberMe = !_rememberMe;
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _rememberMe
                                  ? const Color(0xFF2DB4F6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF2DB4F6),
                                width: 2,
                              ),
                            ),
                            child: _rememberMe
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        _showSnackBar('Fonctionnalité à venir');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2DB4F6),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DB4F6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black87,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
