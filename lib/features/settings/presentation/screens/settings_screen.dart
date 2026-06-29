import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/settings/presentation/widgets/settings_tile.dart';
import 'package:medicine_guide_ai/features/settings/presentation/widgets/about_app_bottom_sheet.dart';
import 'package:medicine_guide_ai/features/settings/presentation/widgets/how_to_use_bottom_sheet.dart';
import 'package:medicine_guide_ai/features/settings/presentation/widgets/instructions_bottom_sheet.dart';
import 'package:medicine_guide_ai/features/settings/presentation/widgets/disclaimer_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beautiful Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2B48), Color(0xFF0A192F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accentTeal.withAlpha(50),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentTeal.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00897B), AppTheme.accentTeal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentTeal.withAlpha(40),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'আপনার ডিজিটাল স্বাস্থ্য সহায়িকা',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Settings Items Container
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'সহায়তা ও তথ্য',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF263238)),
                ),
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.menu_book_rounded,
                      iconColor: AppTheme.accentIndigo,
                      title: 'কীভাবে ব্যবহার করবেন',
                      subtitle: 'সব ফিচারের ব্যবহার নির্দেশিকা',
                      onTap: () => showHowToUseBottomSheet(context),
                    ),
                    const Divider(height: 1, color: Color(0xFF263238)),
                    SettingsTile(
                      icon: Icons.fact_check_rounded,
                      iconColor: const Color(0xFF06B6D4),
                      title: 'সাধারণ নির্দেশনা',
                      subtitle: 'স্বাস্থ্য সুরক্ষার গুরুত্বপূর্ণ নিয়মাবলী',
                      onTap: () => showInstructionsBottomSheet(context),
                    ),
                    const Divider(height: 1, color: Color(0xFF263238)),
                    SettingsTile(
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppTheme.warningRed,
                      title: 'মেডিকেল সতর্কীকরণ',
                      subtitle: 'চিকিৎসা সংক্রান্ত দায়মুক্তি বিবৃতি',
                      onTap: () => showDisclaimerBottomSheet(context),
                    ),
                    const Divider(height: 1, color: Color(0xFF263238)),
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppTheme.accentTeal,
                      title: 'অ্যাপ পরিচিতি',
                      subtitle: 'MediScan AI সম্পর্কে বিস্তারিত',
                      onTap: () => showAboutAppBottomSheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Simple Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0 | Powered by Gemini AI',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary.withAlpha(120),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'MediScan AI © 2026',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary.withAlpha(80),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
