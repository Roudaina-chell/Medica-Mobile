import 'package:flutter/material.dart';
import 'OnboardingPage2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
      ),
      home: const OnboardingPage1(),
    );
  }
}

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: 40,
                    left: 60,
                    child: _buildCircle(12, Colors.blue.shade300),
                  ),
                  Positioned(
                    top: 90,
                    right: 280,
                    child: _buildCircle(8, Colors.blue.shade200),
                  ),
                  Positioned(
                    top: 180,
                    right: 50,
                    child: _buildCircle(6, Colors.blue.shade100),
                  ),
                  Positioned(
                    top: 280,
                    right: 30,
                    child: _buildCircle(10, Colors.blue.shade300),
                  ),
                  Positioned(
                    bottom: 280,
                    left: 40,
                    child: _buildCircle(8, Colors.blue.shade200),
                  ),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Doctor image with blue circle background
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 245,
                              height: 245,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2DB4F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // HANA 7OT LA PHOTO - Ista3ml Image.asset
                            // Exemple:
                            Image.asset(
                              'assets/images/tbib.png',
                              height: 240,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom card with text and button
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text(
                          'Thousands of\ndoctors & experts to\nhelp your health!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 35),

                        // Next button
                        Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DB4F6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OnboardingPage2(),
                                  ),
                                );
                              },
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Page indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIndicator(true),
                            const SizedBox(width: 8),
                            _buildIndicator(false),
                            const SizedBox(width: 8),
                            _buildIndicator(false),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
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

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      width: isActive ? 40 : 12,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2DB4F6) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
