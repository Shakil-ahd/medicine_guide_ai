import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/bloc/navigation_bloc.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/screens/dashboard_screen.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('অনুগ্রহ করে আবার চেষ্টা করুন।')),
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
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBg, Color(0xFF0F1524)],
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
                        // Premium Logo with Glow
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.accentTeal, AppTheme.accentIndigo],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentTeal.withAlpha(50),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // App Title
                        const Text(
                          'মেডিসিন গাইড এআই',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'আপনার স্বাস্থ্য সহযোগী কৃত্রিম বুদ্ধিমত্তা',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 35),
                        // Features section
                        _buildFeatureRow(
                          Icons.qr_code_scanner_rounded,
                          AppTheme.accentTeal,
                          'ওষুধ স্ক্যানার ও তথ্য বিশ্লেষণ',
                          'যেকোনো ওষুধের পাতা স্ক্যান করে তার কার্যকারিতা, পার্শ্বপ্রতিক্রিয়া এবং বিকল্প ওষুধ জানুন মুহূর্তেই।',
                        ),
                        const SizedBox(height: 18),
                        _buildFeatureRow(
                          Icons.history_edu_rounded,
                          AppTheme.accentIndigo,
                          'প্রেসক্রিপশন রিডার ও গাইড',
                          'প্রেসক্রিপশন আপলোড করে কোন ওষুধ কেন এবং কীভাবে খেতে বলা হয়েছে তা বিস্তারিত জানুন বাংলায়।',
                        ),
                        const SizedBox(height: 18),
                        _buildFeatureRow(
                          Icons.alarm_on_rounded,
                          AppTheme.accentTeal,
                          'স্মার্ট মেডিসিন রিমাইন্ডার',
                          'সময়মতো ওষুধ খাওয়ার জন্য সহজে রিমাইন্ডার সেট করুন এবং নোটিফিকেশন পান।',
                        ),
                        const SizedBox(height: 35),
                        // Disclaimer Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x0DE57373),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.warningRed.withAlpha(60),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppTheme.warningRed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'চিকিৎসা সতর্কীকরণ ও দায়মুক্তি',
                                    style: TextStyle(
                                      color: AppTheme.warningRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'এই অ্যাপ্লিকেশনের সমস্ত তথ্য ও প্রেসক্রিপশন বিশ্লেষণ শুধুমাত্র সাধারণ জ্ঞান এবং তথ্যের উদ্দেশ্যে প্রদান করা হয়েছে। এটি কোনো পেশাদার চিকিৎসকের পরামর্শ বা চিকিৎসার বিকল্প নয়। কোনো ওষুধ সেবন বা বন্ধ করার আগে সর্বদা একজন নিবন্ধিত চিকিৎসকের পরামর্শ নিন। অ্যাপের বিশ্লেষণের ওপর ভিত্তি করে নিজে নিজে স্ব-চিকিৎসা করা থেকে বিরত থাকুন।',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12.5,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Footer Controls
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept Checkbox
                    InkWell(
                      onTap: () {
                        setState(() {
                          _hasAcceptedDisclaimer = !_hasAcceptedDisclaimer;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _hasAcceptedDisclaimer = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'আমি সতর্কীকরণটি পড়েছি এবং একমত পোষণ করছি।',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _hasAcceptedDisclaimer && !_isSaving ? _completeOnboarding : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentTeal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.accentTeal.withAlpha(50),
                          disabledForegroundColor: Colors.white30,
                          elevation: _hasAcceptedDisclaimer ? 4 : 0,
                          shadowColor: AppTheme.accentTeal.withAlpha(100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'অ্যাপ শুরু করুন',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
