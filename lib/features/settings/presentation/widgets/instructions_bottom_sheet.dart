import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

void showInstructionsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.accentTeal.withAlpha(40)),
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fact_check_rounded,
                      color: AppTheme.accentTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'সাধারণ নির্দেশনা',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: const [
                  _InstructionCard(
                    icon: Icons.local_hospital_rounded,
                    color: AppTheme.warningRed,
                    text: 'অ্যাপের তথ্য শুধুমাত্র সাধারণ জ্ঞানের জন্য। জরুরি অবস্থায় সরাসরি ডাক্তারের সাথে যোগাযোগ করুন।',
                  ),
                  SizedBox(height: 12),
                  _InstructionCard(
                    icon: Icons.medication_rounded,
                    color: Color(0xFF06B6D4),
                    text: 'ডোজ অনুযায়ী ওষুধ খাওয়ার সময় ঠিক রাখতে রিমাইন্ডার ব্যবহার করুন এবং কোনো অ্যালার্ম মিস করবেন না।',
                  ),
                  SizedBox(height: 12),
                  _InstructionCard(
                    icon: Icons.cancel_rounded,
                    color: AppTheme.warningRed,
                    text: 'ওষুধ সেবনের পর পার্শ্বপ্রতিক্রিয়া দেখা দিলে তাৎক্ষণিকভাবে সেবন বন্ধ করুন ও চিকিৎসকের পরামর্শ নিন।',
                  ),
                  SizedBox(height: 12),
                  _InstructionCard(
                    icon: Icons.ac_unit_rounded,
                    color: AppTheme.accentTeal,
                    text: 'ওষুধ সবসময় আলো ও আর্দ্রতামুক্ত, শীতল ও শুষ্ক স্থানে এবং শিশুদের নাগালের বাইরে রাখুন।',
                  ),
                  SizedBox(height: 12),
                  _InstructionCard(
                    icon: Icons.verified_user_rounded,
                    color: Color(0xFFFBBF24),
                    text: 'মেয়াদোত্তীর্ণ ওষুধ কখনো সেবন করবেন না। প্রতিটি ওষুধের মেয়াদ যাচাই করে সেবন করুন।',
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

class _InstructionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InstructionCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
