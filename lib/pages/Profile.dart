import 'package:flutter/material.dart';
import 'ProfileM.dart';
import 'Doctors.dart';
import 'SignUp.dart';
import 'NotificationPage.dart'; // ← Import ajouté ici

// ==================== PROFILE PAGE ====================
class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 24, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Profile Avatar
              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black87,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 50),

              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.edit_outlined,
                          title: 'Modified',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileM(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12),
                        _buildMenuItem(
                          context,
                          icon: Icons.notifications_outlined,
                          title: 'Notification',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationPage(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12),
                        _buildMenuItem(
                          context,
                          icon: Icons.security_outlined,
                          title: 'Security',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SecurityPage(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12),
                        _buildMenuItem(
                          context,
                          icon: Icons.remove_red_eye_outlined,
                          title: 'View Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProfilePage(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline,
                          title: 'Help',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HelpPage(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12),
                      _buildMenuItem(
                        context,
                        icon: Icons.logout,
                        title: 'Log Out',
                        iconColor: Colors.red,
                        titleColor: Colors.red,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 10,
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: EdgeInsets.all(30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icon
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.logout_rounded,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      
                                      // Title
                                      Text(
                                        'Log Out',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      
                                      // Message
                                      Text(
                                        'Are you sure you want to log out?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          height: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      
                                      // Buttons
                                      Row(
                                        children: [
                                          // Cancel Button
                                          Expanded(
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(15),
                                                  onTap: () => Navigator.of(context).pop(),
                                                  child: Center(
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          
                                          // Log Out Button
                                          Expanded(
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.red[400]!, Colors.red[600]!],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(15),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (context) => SignUp(),
                                                      ),
                                                      (Route<dynamic> route) => false,
                                                    );
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      'Log Out',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar moved outside Column
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(
              Icons.home_rounded,
              false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorsPage(),
                  ),
                );
              },
            ),
            _buildNavIcon(Icons.receipt_long_outlined, false),
            _buildNavIcon(Icons.medical_services_outlined, false),
            _buildNavIcon(Icons.calendar_month_outlined, false),
            _buildNavIcon(Icons.person_outline, true, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileM(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Colors.black87,
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF2196F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: 26,
        ),
      ),
    );
  }
}

// ==================== SECURITY PAGE ====================
class SecurityPage extends StatefulWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 24, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Security',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Security Settings
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Change Password
                      _buildSecurityItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password regularly',
                        onTap: () {
                          _showChangePasswordDialog(context);
                        },
                      ),
                      SizedBox(height: 12),

                      // Biometric Authentication
                      _buildSecurityToggle(
                        icon: Icons.fingerprint,
                        title: 'Biometric Authentication',
                        subtitle: 'Use fingerprint or face ID',
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                        },
                      ),
                      SizedBox(height: 12),

                      // Two-Factor Authentication
                      _buildSecurityToggle(
                        icon: Icons.security,
                        title: 'Two-Factor Authentication',
                        subtitle: 'Add extra layer of security',
                        value: _twoFactorEnabled,
                        onChanged: (value) {
                          setState(() {
                            _twoFactorEnabled = value;
                          });
                        },
                      ),
                      SizedBox(height: 12),

                      // Login History
                      _buildSecurityItem(
                        icon: Icons.history,
                        title: 'Login History',
                        subtitle: 'View your recent login activity',
                        onTap: () {},
                      ),
                      SizedBox(height: 12),

                      // Privacy Settings
                      _buildSecurityItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Settings',
                        subtitle: 'Manage your privacy preferences',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Color(0xFF2196F3), size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Color(0xFF2196F3), size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Color(0xFF2196F3),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password updated successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ==================== VIEW PROFILE PAGE ====================
class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({Key? key}) : super(key: key);

  // Liste des docteurs qui ont consulté le profil
  final List<Map<String, dynamic>> _doctorsWhoViewed = const [
    {
      'name': 'Dr. Sarah Ahmed',
      'specialty': 'Cardiologist',
      'date': '28 Dec 2025',
      'action': 'Updated medical record',
    },
    {
      'name': 'Dr. Mohamed Ali',
      'specialty': 'General Practitioner',
      'date': '15 Dec 2025',
      'action': 'Added prescription',
    },
    {
      'name': 'Dr. Leila Benali',
      'specialty': 'Dermatologist',
      'date': '10 Dec 2025',
      'action': 'Viewed medical history',
    },
    {
      'name': 'Dr. Karim Bouzid',
      'specialty': 'Neurologist',
      'date': '05 Dec 2025',
      'action': 'Updated diagnosis',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 24, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Profile Activity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Profile Summary Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                        border: Border.all(color: Color(0xFF2196F3), width: 2),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Patient ID: #12345',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_doctorsWhoViewed.length} Doctors Viewed',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Section Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.medical_information,
                        color: Color(0xFF2196F3), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Doctors Who Accessed Your Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Doctors List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _doctorsWhoViewed.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctorsWhoViewed[index];
                    return _buildDoctorCard(doctor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2196F3).withOpacity(0.1),
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: Color(0xFF2196F3),
              ),
            ),
            SizedBox(width: 16),
            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    doctor['specialty'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.edit_note, size: 16, color: Color(0xFF4CAF50)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor['action'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                SizedBox(height: 4),
                Text(
                  doctor['date'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HELP PAGE ====================
class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 24, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Help & Support',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Help Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // FAQ Section
                      _buildHelpItem(
                        icon: Icons.question_answer_outlined,
                        title: 'FAQs',
                        subtitle: 'Frequently Asked Questions',
                        onTap: () {},
                      ),
                      SizedBox(height: 12),

                      // Contact Support
                      _buildHelpItem(
                        icon: Icons.support_agent_outlined,
                        title: 'Contact Support',
                        subtitle: 'Get help from our support team',
                        onTap: () {
                          _showContactDialog(context);
                        },
                      ),
                      SizedBox(height: 12),

                      // User Guide
                      _buildHelpItem(
                        icon: Icons.menu_book_outlined,
                        title: 'User Guide',
                        subtitle: 'Learn how to use the app',
                        onTap: () {},
                      ),
                      SizedBox(height: 12),

                      // Report a Problem
                      _buildHelpItem(
                        icon: Icons.report_problem_outlined,
                        title: 'Report a Problem',
                        subtitle: 'Let us know about any issues',
                        onTap: () {
                          _showReportDialog(context);
                        },
                      ),
                      SizedBox(height: 12),

                      // Terms & Conditions
                      _buildHelpItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        subtitle: 'Read our terms of service',
                        onTap: () {},
                      ),
                      SizedBox(height: 12),

                      // Privacy Policy
                      _buildHelpItem(
                        icon: Icons.policy_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we protect your data',
                        onTap: () {},
                      ),
                      SizedBox(height: 12),

                      // About App
                      _buildHelpItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'Version 1.0.0',
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Color(0xFF2196F3), size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: support@medicalapp.com'),
              SizedBox(height: 8),
              Text('Phone: +213 555 000 000'),
              SizedBox(height: 8),
              Text('Available: 24/7'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report a Problem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the problem...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report submitted successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About Medical App'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('Your trusted healthcare companion'),
              SizedBox(height: 8),
              Text('© 2024 Medical App. All rights reserved.'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}