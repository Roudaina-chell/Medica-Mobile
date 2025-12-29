import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medica App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
        child: Stack(
          children: [

            Positioned(
              top: -150,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      const Color(0xFF1DB5ED).withOpacity(0.5),
                      const Color(0xFF1DB5ED).withOpacity(0.25),
                      const Color(0xFF1DB5ED).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),

            // Deuxième cercle haut pour l'effet superposé
            Positioned(
              top: -120,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      const Color(0xFF8ED8F8).withOpacity(0.4),
                      const Color(0xFF8ED8F8).withOpacity(0.2),
                      const Color(0xFF8ED8F8).withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Cercle décoratif en bas à droite - Plus grand
            Positioned(
              bottom: -180,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.7,
                    colors: [
                      const Color(0xFF1DB5ED).withOpacity(0.4),
                      const Color(0xFF1DB5ED).withOpacity(0.25),
                      const Color(0xFF1DB5ED).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),

            // Deuxième cercle bas pour effet superposé
            Positioned(
              bottom: -150,
              right: -80,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.7,
                    colors: [
                      const Color(0xFF8ED8F8).withOpacity(0.35),
                      const Color(0xFF8ED8F8).withOpacity(0.2),
                      const Color(0xFF8ED8F8).withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Contenu principal
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo et Texte "Medica"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo Coeur avec stéthoscope - Taille ajustée
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 25,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Coeur - Taille précise
                              const Icon(
                                Icons.favorite,
                                size: 75,
                                color: Color(0xFF1DB5ED),
                              ),
                              // Lettre Y (stéthoscope stylisé) - Position ajustée
                              Positioned(
                                top: 35,
                                child: Text(
                                  'ÿ',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Arial',
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 18),

                        // Texte "Medica" - Taille ajustée
                        const Text(
                          'Medica',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DB5ED),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 3),

                    // Bouton "Get Started" - Taille et style ajustés
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        width: double.infinity,
                        height: 68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1DB5ED), Color(0xFF1CA5E8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB5ED).withOpacity(0.35),
                              blurRadius: 25,
                              spreadRadius: 1,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF1DB5ED),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
