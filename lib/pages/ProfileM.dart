// pages/ProfileM.dart - Standalone version (no backend required)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String userEmail;

  const EditProfilePage({
    Key? key,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;

  String _selectedGender = 'Féminin';
  File? _profileImage;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadUserData();
  }

  void _initControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dateController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString('user_${widget.userEmail}');

      if (userDataJson != null) {
        final userData = json.decode(userDataJson);
        setState(() {
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _dateController.text = userData['birthDate'] ?? '';
          _contactController.text = userData['contact'] ?? '';
          _selectedGender = userData['gender'] ?? 'Féminin';
          _profileImagePath = userData['profileImage'];

          // Load profile image if exists
          if (_profileImagePath != null &&
              _profileImagePath!.isNotEmpty &&
              File(_profileImagePath!).existsSync()) {
            _profileImage = File(_profileImagePath!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF00B4D8)),
                  title: const Text('Galerie'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _profileImage = File(image.path);
                        _profileImagePath = image.path;
                      });
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Color(0xFF00B4D8)),
                  title: const Text('Caméra'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _profileImage = File(image.path);
                        _profileImagePath = image.path;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime(2005, 7, 25);

    if (_dateController.text.isNotEmpty) {
      try {
        final parts = _dateController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B4D8),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // Save profile to SharedPreferences
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs correctement'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toIso8601String();

      final userData = {
        'email': widget.userEmail,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'birthDate': _dateController.text.trim(),
        'contact': _contactController.text.trim(),
        'gender': _selectedGender,
        'profileImage': _profileImagePath ?? '',
        'updatedAt': now,
      };

      // Save to SharedPreferences
      await prefs.setString('user_${widget.userEmail}', json.encode(userData));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pop(context, {
            'success': true,
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'profileImage': _profileImagePath,
            'contact': _contactController.text,
            'gender': _selectedGender,
          });
        }
      }
    } catch (e) {
      debugPrint('Error saving: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF7DD3FC),
                Color(0xFFBAE6FD),
                Color(0xFFE0F2FE),
                Colors.white,
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7DD3FC),
              Color(0xFFBAE6FD),
              Color(0xFFE0F2FE),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back and save buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (_isSaving)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _saveProfile,
                      ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Profile Image with camera button
                          Stack(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildDefaultProfileImage();
                                          },
                                        )
                                      : _buildDefaultProfileImage(),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Email field (read-only)
                          _buildTextField(
                            label: 'Email',
                            controller: _emailController,
                            readOnly: true,
                            isEmail: true,
                          ),

                          const SizedBox(height: 20),

                          // First name
                          _buildTextField(
                            label: 'First name',
                            controller: _firstNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le prénom est requis';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Last name
                          _buildTextField(
                            label: 'Last name',
                            controller: _lastNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le nom est requis';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Date of birth
                          _buildTextField(
                            label: 'Date of birth',
                            controller: _dateController,
                            readOnly: true,
                            onTap: _selectDate,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La date de naissance est requise';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Contact info
                          _buildTextField(
                            label: 'Contact info',
                            controller: _contactController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le contact est requis';
                              }
                              if (!RegExp(r'^[0-9+\s-()]{10,15}$').hasMatch(value.trim())) {
                                return 'Numéro invalide';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Gender dropdown
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, top: 12),
                                  child: Text(
                                    'Gender',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  items: ['Masculin', 'Féminin', 'Autre']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedGender = newValue;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Le genre est requis';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool isEmail = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          fontSize: 16,
          color: (readOnly && isEmail) ? Colors.grey[600] : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.person, size: 80, color: Colors.grey),
      ),
    );
  }
}