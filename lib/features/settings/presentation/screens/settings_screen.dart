import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.warningRed, size: 24),
            const SizedBox(width: 10),
            Text(
              'সতর্কীকরণ ও দায়মুক্তি',
              style: TextStyle(
                color: AppTheme.warningRed,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'এই অ্যাপ্লিকেশনের সমস্ত তথ্য ও প্রেসক্রিপশন বিশ্লেষণ শুধুমাত্র সাধারণ জ্ঞান এবং তথ্যের উদ্দেশ্যে প্রদান করা হয়েছে। এটি কোনো পেশাদার চিকিৎসকের বিকল্প নয়। কোনো ওষুধ গ্রহণ বা চিকিৎসা পরিবর্তনের আগে সর্বদা একজন নিবন্ধিত চিকিৎসকের পরামর্শ নিন। এই অ্যাপের কোনো ফলাফলের উপর ভিত্তি করে স্ব-চিকিৎসা করবেন না।',
            style: TextStyle(color: AppTheme.textPrimary, height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বন্ধ করুন', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: AppTheme.accentTeal, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'অ্যাপ পরিচিতি',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentTeal.withAlpha(40), width: 1.5),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.description_rounded, size: 28, color: Colors.white),
                      Icon(Icons.document_scanner_outlined, size: 48, color: AppTheme.accentTeal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '${AppConstants.appName}\nআপনার ডিজিটাল স্বাস্থ্য সহায়িকা',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'মেডি-সহায়িকা একটি অত্যাধুনিক মোবাইল অ্যাপ্লিকেশন যা আপনার প্রেসক্রিপশন ও ওষুধ বিশ্লেষণের জন্য তৈরি। এটি চিকিৎসকের প্রেসক্রিপশন বাংলায় অনুবাদ করতে পারে এবং যেকোনো ওষুধের দাম ও তথ্য সরবরাহ করে।',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF263238)),
              const SizedBox(height: 10),
              _buildHighlightRow(Icons.offline_bolt_rounded, 'অফলাইন ডেটাবেস', 'ইন্টারনেট ছাড়াও পূর্বে স্ক্যান করা ওষুধ দেখতে পাবেন।'),
              const SizedBox(height: 12),
              _buildHighlightRow(Icons.alarm_on_rounded, 'এক্স্যাক্ট রিমাইন্ডার', 'সঠিক সময়ে ওষুধ সেবনের রিমাইন্ডার ও নোটিফিকেশন।'),
              const SizedBox(height: 12),
              _buildHighlightRow(Icons.monetization_on_rounded, 'বিকল্প ব্র্যান্ড ও দাম', 'যেকোনো ওষুধের প্রকৃত দাম এবং বিকল্প সাশ্রয়ী ব্র্যান্ড।'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বন্ধ করুন', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accentTeal, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.3)),
            ],
          ),
        )
      ],
    );
  }

  void _showHowToUse(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentIndigo.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, color: AppTheme.accentIndigo, size: 20),
            ),
            const SizedBox(width: 10),
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
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'মেডি-সহায়িকা অ্যাপটি খুব সহজে ব্যবহার করার পদ্ধতি নিচে দেওয়া হলো:',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 16),
              _GuideStep(
                stepNum: '১',
                title: 'ওষুধ স্ক্যান করুন',
                desc: 'হোম পেজের ক্যামেরা বোতাম চেপে যেকোনো ওষুধের পাতার পরিষ্কার ছবি তুলুন। অ্যাপটি অফলাইন ডেটাবেস ও এআই-এর মাধ্যমে ওষুধের ব্যবহার, মূল্য এবং বিকল্প সাশ্রয়ী ব্র্যান্ড দেখাবে।',
              ),
              SizedBox(height: 14),
              _GuideStep(
                stepNum: '২',
                title: 'প্রেসক্রিপশন রিডার',
                desc: 'প্রেসক্রিপশন স্ক্যানার আইকনে চাপ দিয়ে প্রেসক্রিপশনের সোজা ও পরিষ্কার ছবি তুলুন। ছবি বিশ্লেষণ সম্পন্ন হলে চিহ্নিত ওষুধের তালিকা এবং ডোজ বাংলায় দেখতে পাবেন।',
              ),
              SizedBox(height: 14),
              _GuideStep(
                stepNum: '৩',
                title: 'ওষুধের অ্যালার্ম (রিমাইন্ডার)',
                desc: 'রিমাইন্ডার অপশন থেকে ওষুধ সেবনের দিন ও সময় নির্ধারণ করুন। নোটিফিকেশনের মাধ্যমে নির্দিষ্ট সময়ে আপনাকে ওষুধ খাওয়ার কথা মনে করিয়ে দেওয়া হবে।',
              ),
              SizedBox(height: 14),
              _GuideStep(
                stepNum: '৪',
                title: 'ছবি তোলার সেরা টিপস',
                desc: 'ছবি তোলার সময় পর্যাপ্ত আলো রাখুন, ক্যামেরা সোজা রাখুন এবং হাত কাঁপানো থেকে বিরত থাকুন যাতে সব অক্ষর পরিষ্কার বোঝা যায়।',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বন্ধ করুন', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fact_check_rounded, color: AppTheme.accentTeal, size: 20),
            ),
            const SizedBox(width: 10),
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
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'সুস্থ ও সুরক্ষিত থাকার জন্য নিচের নির্দেশনাবলী অনুসরণ করুন:',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 16),
              _InstructionItem(
                icon: Icons.personal_injury_rounded,
                text: 'অ্যাপের যেকোনো তথ্য শুধুমাত্র আপনার সাধারণ জ্ঞান বৃদ্ধির জন্য। যেকোনো জরুরি চিকিৎসায় সরাসরি ডাক্তারের সাথে যোগাযোগ করুন।',
              ),
              SizedBox(height: 12),
              _InstructionItem(
                icon: Icons.medication_liquid_rounded,
                text: 'ডোজ অনুযায়ী ওষুধ খাওয়ার সঠিক সময় ঠিক রাখতে রিমাইন্ডার ফিচারটি ব্যবহার করুন এবং অ্যালার্ম মিস করবেন না।',
              ),
              SizedBox(height: 12),
              _InstructionItem(
                icon: Icons.cancel_presentation_rounded,
                text: 'কোনো ওষুধ সেবনের পর কোনো ধরনের পার্শ্বপ্রতিক্রিয়া দেখা দিলে তাৎক্ষণিকভাবে সেই ওষুধ সেবন বন্ধ করুন ও চিকিৎসকের পরামর্শ নিন।',
              ),
              SizedBox(height: 12),
              _InstructionItem(
                icon: Icons.severe_cold_rounded,
                text: 'ওষুধ সবসময় আলো ও আর্দ্রতা থেকে দূরে, শীতল ও শুষ্ক স্থানে এবং শিশুদের নাগালের বাইরে রাখুন।',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বন্ধ করুন', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accentTeal.withAlpha(40), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentTeal.withAlpha(10),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.accentTeal,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'সুস্থ থাকুন, সুরক্ষিত থাকুন সর্বদা',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('সহায়তা ও তথ্য'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppTheme.accentTeal,
                title: 'অ্যাপ পরিচিতি (About)',
                subtitle: 'মেডি-সহায়িকা অ্যাপ সম্পর্কে জানুন',
                onTap: () => _showAboutApp(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.menu_book_rounded,
                iconColor: AppTheme.accentIndigo,
                title: 'কীভাবে ব্যবহার করবেন (How to Use)',
                subtitle: 'ফিচারসমূহের ব্যবহার প্রণালী ও টিপস',
                onTap: () => _showHowToUse(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.fact_check_rounded,
                iconColor: AppTheme.accentTeal,
                title: 'সাধারণ নির্দেশনা (Instructions)',
                subtitle: 'স্বাস্থ্য সুরক্ষা ও সাধারণ নিয়মাবলী',
                onTap: () => _showInstructions(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.warning_amber_rounded,
                iconColor: AppTheme.warningRed,
                title: 'মেডিকেল সতর্কীকরণ (Disclaimer)',
                subtitle: 'চিকিৎসা সংক্রান্ত সতর্কতা ও দায়মুক্তি',
                onTap: () => _showDisclaimer(context),
              ),
            ],
          ),
          
          const SizedBox(height: 35),
          
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF263238)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, color: AppTheme.accentTeal, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'সংস্করণ: ১.০.০',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'মেডিসিন গাইড টিম © ২০২৬',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textSecondary,
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFF263238),
      indent: 52,
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String stepNum;
  final String title;
  final String desc;

  const _GuideStep({
    required this.stepNum,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppTheme.accentTeal.withAlpha(30),
          child: Text(
            stepNum,
            style: const TextStyle(
              color: AppTheme.accentTeal,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
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

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accentTeal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
