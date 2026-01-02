// pages/SignUp.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Profile.dart';
import 'SignIn.dart';
import 'database_helper.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'patient'; // Rôle par défaut

  final TextEditingController _carteIdController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  // Liste des rôles disponibles (SEULEMENT patient et nurse_admin)
  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'patient',
      'label': 'Patient',
      'icon': Icons.person,
      'color': const Color(0xFF2DB4F6)
    },
    {
      'value': 'nurse_admin',
      'label': 'Infirmière Admin',
      'icon': Icons.medical_services,
      'color': Colors.green
    },
  ];

  @override
  void dispose() {
    _carteIdController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fonction pour rediriger selon le rôle après inscription
  void _navigateToHome(String role, Map<String, dynamic> userData) {
    Widget destination = Profile(
      username: userData['fullName']?.toString() ?? 'Utilisateur',
      email: userData['email']?.toString() ?? '',
      role: role,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  Future<void> _signUp() async {
    // Validation Carte ID (nombre de 10 chiffres)
    if (_carteIdController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre numéro de carte nationale');
      return;
    }

    int? carteId = int.tryParse(_carteIdController.text);
    if (carteId == null || _carteIdController.text.length != 10) {
      _showSnackBar(
          'Le numéro de carte nationale doit contenir exactement 10 chiffres');
      return;
    }

    // Validation Nom complet
    if (_fullNameController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre nom complet');
      return;
    }

    // Validation Email
    if (_emailController.text.isEmpty) {
      _showSnackBar('Veuillez entrer un email');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showSnackBar('Email invalide');
      return;
    }

    // Validation Mot de passe
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Veuillez entrer un mot de passe');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si l'email existe déjà
      bool emailExists = await _dbHelper.emailExists(_emailController.text);
      if (emailExists) {
        _showSnackBar('Cet email est déjà utilisé');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Vérifier si le numéro de carte nationale existe déjà
      bool carteExists = await _dbHelper.carteIdExists(carteId);
      if (carteExists) {
        _showSnackBar('Ce numéro de carte nationale est déjà utilisé');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Créer l'utilisateur
      await _dbHelper.addUser(_emailController.text, {
        'carte_id': carteId,
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
        'phone': _phoneController.text,
        'dateOfBirth': '',
        'address': '',
        'rememberMe': _rememberMe,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _showSnackBar('Inscription réussie !', isSuccess: true);

      if (!mounted) return;

      // Préparer les données utilisateur pour la redirection
      Map<String, dynamic> userData = {
        'carte_id': carteId,
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'role': _selectedRole,
        'phone': _phoneController.text,
      };

      // Redirection selon le rôle
      _navigateToHome(_selectedRole, userData);
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : const Color(0xFF2DB4F6),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Widget pour sélectionner le rôle
  Widget _buildRoleSelector() {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Sélectionnez votre rôle *',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              children: _roles.map((role) {
                bool isSelected = _selectedRole == role['value'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRole = role['value'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? role['color'].withOpacity(0.1)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? role['color']
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              role['icon'],
                              color: isSelected
                                  ? role['color']
                                  : Colors.grey.shade600,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role['label'],
                              style: TextStyle(
                                color: isSelected
                                    ? role['color']
                                    : Colors.grey.shade700,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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
                        Icons.person_add,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignIn(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2DB4F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Carte Nationale ID Field (10 chiffres)
                _buildTextField(
                  controller: _carteIdController,
                  icon: Icons.badge_outlined,
                  hintText: 'Numéro de Carte Nationale (10 chiffres)',
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                // Full Name Field
                _buildTextField(
                  controller: _fullNameController,
                  icon: Icons.person_outline,
                  hintText: 'Nom Complet',
                ),
                const SizedBox(height: 20),
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                // Phone Field (optional)
                _buildTextField(
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  hintText: 'Téléphone (optionnel)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                // Role Selector
                _buildRoleSelector(),
                const SizedBox(height: 20),
                // Password Field
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
                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  icon: Icons.lock_outline,
                  hintText: 'Confirmer le mot de passe',
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 20),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DB4F6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
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
                            'Sign up',
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
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
        maxLength: maxLength,
        inputFormatters: inputFormatters,
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
          counterText: '', // Cache le compteur de caractères
        ),
      ),
    );
  }
}
