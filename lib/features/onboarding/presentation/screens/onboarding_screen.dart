import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/constants/app_strings.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/bloc/navigation_bloc.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:medicine_guide_ai/core/widgets/scanner_loader.dart';
import 'package:medicine_guide_ai/core/widgets/custom_snackbar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _hasAcceptedDisclaimer = false;
  bool _isSaving = false;

  Future<void> _completeOnboarding() async {
    if (!_hasAcceptedDisclaimer || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await DatabaseHelper.instance.saveSetting('onboarding_completed', 'true');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => NavigationBloc(),
              child: const DashboardScreen(),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        CustomSnackBar.showError(context, AppErrors.tryAgain);
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
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05070F), Color(0xFF0F172A), Color(0xFF05070F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.accentTeal, AppTheme.accentIndigo],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentTeal.withAlpha(60),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppTheme.accentIndigo.withAlpha(40),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.6,
                            shadows: [
                              Shadow(
                                color: AppTheme.accentIndigo,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          AppStrings.appSubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildFeatureRow(
                          Icons.qr_code_scanner_rounded,
                          AppTheme.accentTeal,
                          AppStrings.onboardingScanTitle,
                          AppStrings.onboardingScanDesc,
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureRow(
                          Icons.history_edu_rounded,
                          AppTheme.accentIndigo,
                          AppStrings.onboardingReaderTitle,
                          AppStrings.onboardingReaderDesc,
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureRow(
                          Icons.alarm_on_rounded,
                          AppTheme.accentTeal,
                          AppStrings.onboardingReminderTitle,
                          AppStrings.onboardingReminderDesc,
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.warningRed.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.warningRed.withAlpha(60),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.warningRed.withAlpha(5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppTheme.warningRed,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppStrings.disclaimerTitle,
                                    style: TextStyle(
                                      color: AppTheme.warningRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                AppStrings.disclaimerDetail,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12.5,
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _hasAcceptedDisclaimer = !_hasAcceptedDisclaimer;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _hasAcceptedDisclaimer,
                                activeColor: AppTheme.accentTeal,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: _hasAcceptedDisclaimer
                                      ? AppTheme.accentTeal
                                      : AppTheme.textSecondary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _hasAcceptedDisclaimer = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                AppStrings.acceptDisclaimer,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: _hasAcceptedDisclaimer && !_isSaving
                            ? AppTheme.primaryGradient
                            : null,
                        color: _hasAcceptedDisclaimer && !_isSaving
                            ? null
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _hasAcceptedDisclaimer && !_isSaving
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentTeal.withAlpha(60),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: _hasAcceptedDisclaimer && !_isSaving ? _completeOnboarding : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: Colors.white30,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const ScannerLoader(size: 24)
                            : const Text(
                                AppStrings.startApp,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    Color iconColor,
    String title,
    String desc,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withAlpha(120),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1F2937),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
