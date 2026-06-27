import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

void showHowToUseBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppTheme.accentIndigo.withAlpha(40),
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
                      color: AppTheme.accentIndigo.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.accentIndigo,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'কীভাবে ব্যবহার করবেন',
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
                  _HowToStep(
                    stepNum: 1,
                    color: AppTheme.accentTeal,
                    icon: Icons.document_scanner_rounded,
                    title: 'ওষুধ স্ক্যান করুন',
                    desc: 'হোম পেজের "ওষুধ স্ক্যান" বোতামে চাপ দিন। ক্যামেরা বা গ্যালারি থেকে ওষুধের পাতার স্পষ্ট ছবি দিন। AI কয়েক সেকেন্ডের মধ্যে দাম, ব্যবহার ও বিকল্প ব্র্যান্ড দেখাবে।',
                  ),
                  SizedBox(height: 16),
                  _HowToStep(
                    stepNum: 2,
                    color: Color(0xFF5C6BC0),
                    icon: Icons.description_rounded,
                    title: 'প্রেসক্রিপশন রিডার',
                    desc: '"প্রেসক্রিপশন রিডার" বোতামে চাপ দিয়ে ডাক্তারের প্রেসক্রিপশনের ছবি তুলুন। AI হাতের লেখা পড়ে প্রতিটি ওষুধের ডোজ ও তথ্য বাংলায় দেখাবে।',
                  ),
                  SizedBox(height: 16),
                  _HowToStep(
                    stepNum: 3,
                    color: Color(0xFFFBBF24),
                    icon: Icons.alarm_rounded,
                    title: 'রিমাইন্ডার সেট করুন',
                    desc: '"রিমাইন্ডার" ট্যাবে গিয়ে ওষুধের নাম, সময় ও দিন নির্ধারণ করুন। সঠিক সময়ে notification আসবে যাতে ওষুধ মিস না হয়।',
                  ),
                  SizedBox(height: 16),
                  _HowToStep(
                    stepNum: 4,
                    color: Color(0xFFEC4899),
                    icon: Icons.history_edu_rounded,
                    title: 'হিস্ট্রি দেখুন',
                    desc: '"হিস্ট্রি" ট্যাবে আগের সব স্ক্যান ও প্রেসক্রিপশন দেখতে পাবেন। ইন্টারনেট ছাড়াও পূর্বে দেখা ওষুধ খুঁজে পাবেন।',
                  ),
                  SizedBox(height: 16),
                  _HowToStep(
                    stepNum: 5,
                    color: Color(0xFF06B6D4),
                    icon: Icons.camera_alt_rounded,
                    title: 'সেরা ছবির টিপস',
                    desc: 'পর্যাপ্ত আলোতে ছবি তুলুন। ক্যামেরা সরাসরি ওষুধের উপর রাখুন। হাত স্থির রাখুন। ওষুধের নাম ও ডোজ স্পষ্টভাবে দেখা যাচ্ছে কিনা নিশ্চিত করুন।',
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

class _HowToStep extends StatelessWidget {
  final int stepNum;
  final Color color;
  final IconData icon;
  final String title;
  final String desc;

  const _HowToStep({
    required this.stepNum,
    required this.color,
    required this.icon,
    required this.title,
    required this.desc,
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNum.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.5,
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
