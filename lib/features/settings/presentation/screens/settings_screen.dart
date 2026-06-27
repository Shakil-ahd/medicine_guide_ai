import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.mediscanai.app/battery');
  bool _isIgnoringBattery = true;
  bool _canScheduleExactAlarms = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final ignoring = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ?? true;
      final canSchedule = await _channel.invokeMethod<bool>('canScheduleExactAlarms') ?? true;
      if (mounted) {
        setState(() {
          _isIgnoringBattery = ignoring;
          _canScheduleExactAlarms = canSchedule;
        });
      }
    } catch (_) {}
  }

  void _showDisclaimer(BuildContext context) {
    _showBottomSheetDialog(
      context: context,
      icon: Icons.warning_amber_rounded,
      iconColor: AppTheme.warningRed,
      title: 'সতর্কীকরণ ও দায়মুক্তি',
      content:
          'এই অ্যাপ্লিকেশনের সমস্ত তথ্য ও প্রেসক্রিপশন বিশ্লেষণ শুধুমাত্র সাধারণ জ্ঞান এবং তথ্যের উদ্দেশ্যে প্রদান করা হয়েছে। এটি কোনো পেশাদার চিকিৎসকের বিকল্প নয়। কোনো ওষুধ গ্রহণ বা চিকিৎসা পরিবর্তনের আগে সর্বদা একজন নিবন্ধিত চিকিৎসকের পরামর্শ নিন। এই অ্যাপের কোনো ফলাফলের উপর ভিত্তি করে স্ব-চিকিৎসা করবেন না।',
    );
  }

  void _showAboutApp(BuildContext context) {
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
                    _FeatureHighlight(
                      icon: Icons.document_scanner_rounded,
                      color: AppTheme.accentTeal,
                      title: 'AI Medicine Scanner',
                      desc:
                          'যেকোনো ওষুধের ছবি তুলুন — AI দাম, ব্যবহার ও বিকল্প দেখাবে।',
                    ),
                    const SizedBox(height: 12),
                    _FeatureHighlight(
                      icon: Icons.description_rounded,
                      color: const Color(0xFF5C6BC0),
                      title: 'Prescription Reader',
                      desc: 'হাতের লেখা প্রেসক্রিপশন বাংলায় পড়ুন ও বুঝুন।',
                    ),
                    const SizedBox(height: 12),
                    _FeatureHighlight(
                      icon: Icons.alarm_rounded,
                      color: const Color(0xFFFBBF24),
                      title: 'Medicine Reminder',
                      desc: 'নির্দিষ্ট সময়ে ওষুধ খাওয়ার স্মার্ট নোটিফিকেশন।',
                    ),
                    const SizedBox(height: 12),
                    _FeatureHighlight(
                      icon: Icons.history_edu_rounded,
                      color: const Color(0xFFEC4899),
                      title: 'Medical History',
                      desc:
                          'সব স্ক্যান ও প্রেসক্রিপশনের রেকর্ড অফলাইনে সংরক্ষিত।',
                    ),
                    const SizedBox(height: 12),
                    _FeatureHighlight(
                      icon: Icons.record_voice_over_rounded,
                      color: const Color(0xFF06B6D4),
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

  void _showHowToUse(BuildContext context) {
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
                      desc:
                          'হোম পেজের "ওষুধ স্ক্যান" বোতামে চাপ দিন। ক্যামেরা বা গ্যালারি থেকে ওষুধের পাতার স্পষ্ট ছবি দিন। AI কয়েক সেকেন্ডের মধ্যে দাম, ব্যবহার ও বিকল্প ব্র্যান্ড দেখাবে।',
                    ),
                    SizedBox(height: 16),
                    _HowToStep(
                      stepNum: 2,
                      color: Color(0xFF5C6BC0),
                      icon: Icons.description_rounded,
                      title: 'প্রেসক্রিপশন রিডার',
                      desc:
                          '"প্রেসক্রিপশন রিডার" বোতামে চাপ দিয়ে ডাক্তারের প্রেসক্রিপশনের ছবি তুলুন। AI হাতের লেখা পড়ে প্রতিটি ওষুধের ডোজ ও তথ্য বাংলায় দেখাবে।',
                    ),
                    SizedBox(height: 16),
                    _HowToStep(
                      stepNum: 3,
                      color: Color(0xFFFBBF24),
                      icon: Icons.alarm_rounded,
                      title: 'রিমাইন্ডার সেট করুন',
                      desc:
                          '"রিমাইন্ডার" ট্যাবে গিয়ে ওষুধের নাম, সময় ও দিন নির্ধারণ করুন। সঠিক সময়ে notification আসবে যাতে ওষুধ মিস না হয়।',
                    ),
                    SizedBox(height: 16),
                    _HowToStep(
                      stepNum: 4,
                      color: Color(0xFFEC4899),
                      icon: Icons.history_edu_rounded,
                      title: 'হিস্ট্রি দেখুন',
                      desc:
                          '"হিস্ট্রি" ট্যাবে আগের সব স্ক্যান ও প্রেসক্রিপশন দেখতে পাবেন। ইন্টারনেট ছাড়াও পূর্বে দেখা ওষুধ খুঁজে পাবেন।',
                    ),
                    SizedBox(height: 16),
                    _HowToStep(
                      stepNum: 5,
                      color: Color(0xFF06B6D4),
                      icon: Icons.camera_alt_rounded,
                      title: 'সেরা ছবির টিপস',
                      desc:
                          'পর্যাপ্ত আলোতে ছবি তুলুন। ক্যামেরা সরাসরি ওষুধের উপর রাখুন। হাত স্থির রাখুন। ওষুধের নাম ও ডোজ স্পষ্টভাবে দেখা যাচ্ছে কিনা নিশ্চিত করুন।',
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

  void _showInstructions(BuildContext context) {
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
                      text:
                          'অ্যাপের তথ্য শুধুমাত্র সাধারণ জ্ঞানের জন্য। জরুরি অবস্থায় সরাসরি ডাক্তারের সাথে যোগাযোগ করুন।',
                    ),
                    SizedBox(height: 12),
                    _InstructionCard(
                      icon: Icons.medication_rounded,
                      color: Color(0xFF06B6D4),
                      text:
                          'ডোজ অনুযায়ী ওষুধ খাওয়ার সময় ঠিক রাখতে রিমাইন্ডার ব্যবহার করুন এবং কোনো অ্যালার্ম মিস করবেন না।',
                    ),
                    SizedBox(height: 12),
                    _InstructionCard(
                      icon: Icons.cancel_rounded,
                      color: AppTheme.warningRed,
                      text:
                          'ওষুধ সেবনের পর পার্শ্বপ্রতিক্রিয়া দেখা দিলে তাৎক্ষণিকভাবে সেবন বন্ধ করুন ও চিকিৎসকের পরামর্শ নিন।',
                    ),
                    SizedBox(height: 12),
                    _InstructionCard(
                      icon: Icons.ac_unit_rounded,
                      color: AppTheme.accentTeal,
                      text:
                          'ওষুধ সবসময় আলো ও আর্দ্রতামুক্ত, শীতল ও শুষ্ক স্থানে এবং শিশুদের নাগালের বাইরে রাখুন।',
                    ),
                    SizedBox(height: 12),
                    _InstructionCard(
                      icon: Icons.verified_user_rounded,
                      color: Color(0xFFFBBF24),
                      text:
                          'মেয়াদোত্তীর্ণ ওষুধ কখনো সেবন করবেন না। প্রতিটি ওষুধের মেয়াদ যাচাই করে সেবন করুন।',
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

  void _showBottomSheetDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
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
            border: Border.all(color: iconColor.withAlpha(40)),
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
                        color: iconColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
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
                  children: [
                    Text(
                      content,
                      style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildAppHeader(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildQuickStats(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: _buildSectionHeader(
                'সিস্টেম পারমিশন',
                Icons.settings_suggest_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildSettingsGroup([
                _SettingsTileData(
                  icon: Icons.battery_saver_rounded,
                  iconColor: _isIgnoringBattery ? AppTheme.accentTeal : AppTheme.warningRed,
                  title: 'ব্যাকগ্রাউন্ড ব্যাটারি সচলতা',
                  subtitle: _isIgnoringBattery ? 'অনুমোদিত (রিমাইন্ডার অন-টাইমে বাজবে)' : 'সীমাবদ্ধ (রিমাইন্ডার বিলম্বিত হতে পারে)',
                  trailing: _isIgnoringBattery ? 'সচল' : 'ঠিক করুন',
                  trailingIsLabel: _isIgnoringBattery,
                  onTap: _isIgnoringBattery
                      ? () {}
                      : () async {
                          await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
                        },
                ),
                _SettingsTileData(
                  icon: Icons.alarm_rounded,
                  iconColor: _canScheduleExactAlarms ? AppTheme.accentTeal : AppTheme.warningRed,
                  title: 'অ্যালার্ম ও রিমাইন্ডার',
                  subtitle: _canScheduleExactAlarms ? 'অনুমোদিত (অন-টাইম অ্যালার্ম সচল)' : 'বন্ধ (রিমাইন্ডার কাজ নাও করতে পারে)',
                  trailing: _canScheduleExactAlarms ? 'সচল' : 'চালু করুন',
                  trailingIsLabel: _canScheduleExactAlarms,
                  onTap: _canScheduleExactAlarms
                      ? () {}
                      : () async {
                          await _channel.invokeMethod('requestExactAlarmPermission');
                        },
                ),
                _SettingsTileData(
                  icon: Icons.autorenew_rounded,
                  iconColor: AppTheme.accentTeal,
                  title: 'অটো-স্টার্ট অনুমতি (OEM)',
                  subtitle: 'অ্যাপ বন্ধ করার পরও রিমাইন্ডার সচল রাখতে এটি সচল করুন',
                  trailing: 'চালু করুন',
                  onTap: () async {
                    await _channel.invokeMethod('openAutostartSettings');
                  },
                  isLast: true,
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: _buildSectionHeader(
                'সহায়তা ও তথ্য',
                Icons.support_agent_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildSettingsGroup([
                _SettingsTileData(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.accentTeal,
                  title: 'অ্যাপ পরিচিতি',
                  subtitle: 'MediScan AI সম্পর্কে বিস্তারিত জানুন',
                  trailing: 'About',
                  onTap: () => _showAboutApp(context),
                ),
                _SettingsTileData(
                  icon: Icons.menu_book_rounded,
                  iconColor: AppTheme.accentIndigo,
                  title: 'ব্যবহার নির্দেশিকা',
                  subtitle: 'কীভাবে সব ফিচার ব্যবহার করবেন',
                  trailing: 'How to Use',
                  onTap: () => _showHowToUse(context),
                ),
                _SettingsTileData(
                  icon: Icons.fact_check_rounded,
                  iconColor: const Color(0xFF06B6D4),
                  title: 'সাধারণ নির্দেশনা',
                  subtitle: 'স্বাস্থ্য সুরক্ষার গুরুত্বপূর্ণ নিয়মাবলী',
                  trailing: 'Guidelines',
                  onTap: () => _showInstructions(context),
                ),
                _SettingsTileData(
                  icon: Icons.shield_outlined,
                  iconColor: AppTheme.warningRed,
                  title: 'মেডিকেল সতর্কীকরণ',
                  subtitle: 'চিকিৎসা সংক্রান্ত দায়মুক্তি বিবৃতি',
                  trailing: 'Disclaimer',
                  onTap: () => _showDisclaimer(context),
                  isLast: true,
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: _buildSectionHeader(
                'অ্যাপ তথ্য',
                Icons.smartphone_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildSettingsGroup([
                _SettingsTileData(
                  icon: Icons.verified_rounded,
                  iconColor: const Color(0xFFFBBF24),
                  title: 'সংস্করণ',
                  subtitle: 'বর্তমান অ্যাপ সংস্করণ',
                  trailing: 'v1.0.0',
                  trailingIsLabel: true,
                  onTap: () {},
                ),
                _SettingsTileData(
                  icon: Icons.api_rounded,
                  iconColor: AppTheme.accentTeal,
                  title: 'AI Engine',
                  subtitle: 'Google Gemini AI দ্বারা পরিচালিত',
                  trailing: 'Gemini',
                  trailingIsLabel: true,
                  onTap: () {},
                  isLast: true,
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              child: _buildFooter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF0A1628)],
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
            color: AppTheme.accentTeal.withAlpha(15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00897B), AppTheme.accentTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentTeal.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'সুস্থ থাকুন, সুরক্ষিত থাকুন',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    _StatusBadge(
                      label: 'AI Powered',
                      color: AppTheme.accentTeal,
                    ),
                    SizedBox(width: 6),
                    _StatusBadge(label: 'বাংলা', color: Color(0xFF5C6BC0)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.document_scanner_rounded,
            label: 'স্ক্যান',
            value: 'AI',
            color: AppTheme.accentTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.wifi_off_rounded,
            label: 'অফলাইন',
            value: 'DB',
            color: const Color(0xFF5C6BC0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.alarm_on_rounded,
            label: 'রিমাইন্ডার',
            value: '24/7',
            color: const Color(0xFFFBBF24),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentTeal, size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(List<_SettingsTileData> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Column(
        children: List.generate(tiles.length, (index) {
          final tile = tiles[index];
          return _AnimatedSettingsTile(data: tile, showDivider: !tile.isLast);
        }),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF263238)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: AppTheme.warningRed,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'Made with love for Bangladesh',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'MediScan AI © 2026 | All Rights Reserved',
          style: TextStyle(fontSize: 11, color: Color(0xFF546E7A)),
        ),
      ],
    );
  }
}

class _SettingsTileData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final bool trailingIsLabel;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsTileData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.trailingIsLabel = false,
    this.isLast = false,
  });
}

class _AnimatedSettingsTile extends StatefulWidget {
  final _SettingsTileData data;
  final bool showDivider;

  const _AnimatedSettingsTile({required this.data, required this.showDivider});

  @override
  State<_AnimatedSettingsTile> createState() => _AnimatedSettingsTileState();
}

class _AnimatedSettingsTileState extends State<_AnimatedSettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.data.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: _pressed
                ? widget.data.iconColor.withAlpha(12)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.data.iconColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: widget.data.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.data.trailingIsLabel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.data.iconColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.data.trailing,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.data.iconColor,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF263238)),
                        ),
                        child: Text(
                          widget.data.trailing,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF1E2B3A),
            indent: 70,
            endIndent: 0,
          ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;

  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFF263238), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFF263238), height: 1)),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withAlpha(80), color]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNum',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withAlpha(30)),
                ),
                child: Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


