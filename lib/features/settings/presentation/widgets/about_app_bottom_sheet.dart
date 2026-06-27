import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

void showAboutAppBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppTheme.accentTeal.withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00897B), AppTheme.accentTeal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentTeal.withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'আপনার ডিজিটাল স্বাস্থ্য সহায়িকা',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF263238)),
                    ),
                    child: const Text(
                      'MediScan AI একটি অত্যাধুনিক মোবাইল অ্যাপ যা AI-powered OCR ব্যবহার করে যেকোনো ওষুধের প্যাকেট বা ডাক্তারের প্রেসক্রিপশন বিশ্লেষণ করতে পারে এবং বাংলায় বিস্তারিত তথ্য সরবরাহ করে।',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.6,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionDivider(title: 'মূল ফিচারসমূহ'),
                  const SizedBox(height: 16),
                  const _FeatureHighlight(
                    icon: Icons.document_scanner_rounded,
                    color: AppTheme.accentTeal,
                    title: 'AI Medicine Scanner',
                    desc: 'যেকোনো ওষুধের ছবি তুলুন — AI দাম, ব্যবহার ও বিকল্প দেখাবে।',
                  ),
                  const SizedBox(height: 12),
                  const _FeatureHighlight(
                    icon: Icons.description_rounded,
                    color: Color(0xFF5C6BC0),
                    title: 'Prescription Reader',
                    desc: 'হাতের লেখা প্রেসক্রিপশন বাংলায় পড়ুন ও বুঝুন।',
                  ),
                  const SizedBox(height: 12),
                  const _FeatureHighlight(
                    icon: Icons.alarm_rounded,
                    color: Color(0xFFFBBF24),
                    title: 'Medicine Reminder',
                    desc: 'নির্দিষ্ট সময়ে ওষুধ খাওয়ার স্মার্ট নোটিফিকেশন।',
                  ),
                  const SizedBox(height: 12),
                  const _FeatureHighlight(
                    icon: Icons.history_edu_rounded,
                    color: Color(0xFFEC4899),
                    title: 'Medical History',
                    desc: 'সব স্ক্যান ও প্রেসক্রিপশনের রেকর্ড অফলাইনে সংরক্ষিত।',
                  ),
                  const SizedBox(height: 12),
                  const _FeatureHighlight(
                    icon: Icons.record_voice_over_rounded,
                    color: Color(0xFF06B6D4),
                    title: 'Voice Assistant (TTS)',
                    desc: 'ওষুধের তথ্য বাংলায় পড়ে শুনতে পাবেন।',
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF263238)),
                      ),
                      child: const Text(
                        'Powered by Google Gemini AI',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
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

class _SectionDivider extends StatelessWidget {
  final String title;

  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF263238),
          ),
        ),
      ],
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _FeatureHighlight({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
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
