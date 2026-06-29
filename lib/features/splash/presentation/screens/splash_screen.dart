import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/bloc/navigation_bloc.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:medicine_guide_ai/features/onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool onboardingCompleted;

  const SplashScreen({super.key, required this.onboardingCompleted});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late AnimationController _scannerController;
  late Animation<double> _laserAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 22.0, end: 88.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return widget.onboardingCompleted
                  ? BlocProvider(
                      create: (context) => NavigationBloc(),
                      child: const DashboardScreen(),
                    )
                  : const OnboardingScreen();
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05070F), Color(0xFF0E1326), Color(0xFF05070F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentTeal.withAlpha(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentTeal.withAlpha(25),
                              blurRadius: 35,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: AppTheme.accentIndigo.withAlpha(20),
                              blurRadius: 50,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _scannerController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.accentTeal.withAlpha(50),
                                      width: 1.8,
                                    ),
                                    gradient: RadialGradient(
                                      colors: [
                                        AppTheme.accentTeal.withAlpha(15),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.description_rounded,
                                  size: 48,
                                  color: Colors.white70,
                                ),
                                const Icon(
                                  Icons.document_scanner_outlined,
                                  size: 80,
                                  color: AppTheme.accentTeal,
                                ),
                                Positioned(
                                  top: _laserAnimation.value,
                                  left: 26,
                                  right: 26,
                                  child: Container(
                                    height: 3.5,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentIndigo,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentIndigo.withAlpha(255),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: AppTheme.accentTeal.withAlpha(200),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: AppTheme.accentIndigo,
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                            Shadow(
                              color: AppTheme.accentTeal,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'আপনার নির্ভরযোগ্য স্বাস্থ্য নির্দেশিকা',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 52),
                      SizedBox(
                        width: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            color: AppTheme.accentTeal,
                            backgroundColor: Color(0xFF1E293B),
                            minHeight: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
