import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

void showDisclaimerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.warningRed.withAlpha(40)),
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
                      color: AppTheme.warningRed.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warningRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'সতর্কীকরণ ও দায়মুক্তি',
                    style: TextStyle(
                      color: AppTheme.warningRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF263238)),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: const [
                  Text(
                    'এই অ্যাপ্লিকেশনের সমস্ত তথ্য ও প্রেসক্রিপশন বিশ্লেষণ শুধুমাত্র সাধারণ জ্ঞান এবং তথ্যের উদ্দেশ্যে প্রদান করা হয়েছে। এটি কোনো পেশাদার চিকিৎসকের বিকল্প নয়। কোনো ওষুধ গ্রহণ বা চিকিৎসা পরিবর্তনের আগে সর্বদা একজন নিবন্ধিত চিকিৎসকের পরামর্শ নিন। এই অ্যাপের কোনো ফলাফলের উপর ভিত্তি করে স্ব-চিকিৎসা করবেন না।',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      height: 1.7,
                      fontSize: 14,
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
