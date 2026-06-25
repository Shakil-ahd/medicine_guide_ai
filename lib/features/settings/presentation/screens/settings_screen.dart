import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/notification_service.dart';
import 'package:medicine_guide_ai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_bloc.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_event.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _ttsSpeed = 0.5;
  bool _smartNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final speed = await DatabaseHelper.instance.getSetting('tts_speed');
      final notif = await DatabaseHelper.instance.getSetting('smart_notifications');
      
      setState(() {
        if (speed != null) {
          _ttsSpeed = double.tryParse(speed) ?? 0.5;
        }
        if (notif != null) {
          _smartNotifications = notif == 'true';
        }
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTtsSpeed(double value) async {
    setState(() {
      _ttsSpeed = value;
    });
    await DatabaseHelper.instance.saveSetting('tts_speed', value.toStringAsFixed(2));
  }

  Future<void> _saveNotifications(bool value) async {
    setState(() {
      _smartNotifications = value;
    });
    await DatabaseHelper.instance.saveSetting('smart_notifications', value ? 'true' : 'false');
  }

  String _getSpeedLabel(double speed) {
    if (speed <= 0.35) return 'খুব ধীর';
    if (speed <= 0.45) return 'ধীর';
    if (speed <= 0.55) return 'স্বাভাবিক';
    if (speed <= 0.65) return 'দ্রুত';
    return 'খুব দ্রুত';
  }

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

  void _showUserGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppTheme.accentTeal, size: 24),
            SizedBox(width: 10),
            Text(
              'অ্যাপ ব্যবহার নির্দেশিকা',
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
              _GuideStep(
                stepNum: '১',
                title: 'ওষুধ স্ক্যানিং',
                desc: 'হোম পেজ থেকে ক্যামেরা দিয়ে যেকোনো ওষুধের খাপ বা পাতার লেখা স্পষ্ট ছবি তুলুন। অ্যাপটি অফলাইন ডাটাবেজ এবং কৃত্রিম বুদ্ধিমত্তার মাধ্যমে ওষুধটির কার্যকারিতা, খাবার নিয়ম ও বিকল্প ওষুধের তালিকা দেখাবে।',
              ),
              SizedBox(height: 12),
              _GuideStep(
                stepNum: '২',
                title: 'প্রেসক্রিপশন রিডার',
                desc: 'ডাক্তারের হাতের লেখা প্রেসক্রিপশন স্ক্যান করে কোন ওষুধ কোন সময় খেতে হবে তার একটি সহজ বাংলা তালিকা দেখতে পাবেন।',
              ),
              SizedBox(height: 12),
              _GuideStep(
                stepNum: '৩',
                title: 'রিমাইন্ডার সেট করা',
                desc: 'রিমাইন্ডার ট্যাপ থেকে ওষুধের নাম ও সময়সূচী নির্ধারণ করে রাখুন। নির্দিষ্ট সময়ে নোটিফিকেশনের মাধ্যমে আপনাকে ওষুধ খাওয়ার কথা মনে করিয়ে দেওয়া হবে।',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বুঝেছি', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmResetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('সব ডেটা মুছুন'),
        content: const Text(
          'আপনি কি নিশ্চিত যে আপনি আপনার সমস্ত স্ক্যান ইতিহাস এবং মেডিসিন রিমাইন্ডার মুছে ফেলতে চান? এটি আর ফিরিয়ে আনা যাবে না।',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বাতিল', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final historyBloc = context.read<HistoryBloc>();
              final reminderBloc = context.read<ReminderBloc>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogCtx);
              
              final db = await DatabaseHelper.instance.database;
              await db.delete('reminders');
              await NotificationService.instance.cancelAll();
              
              historyBloc.add(ClearHistoryEvent());
              reminderBloc.add(LoadRemindersEvent());
              
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('সমস্ত হিস্ট্রি ও রিমাইন্ডার মুছে ফেলা হয়েছে।')),
              );
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: AppTheme.warningRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmResetOnboarding(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('অনবোর্ডিং স্ক্রিন দেখুন'),
        content: const Text(
          'এটি আপনাকে আবার অনবোর্ডিং এবং সতর্কীকরণ গ্রহণ করার স্বাগতম স্ক্রিনে নিয়ে যাবে।',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বাতিল', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.saveSetting('onboarding_completed', 'false');
              if (context.mounted) {
                Navigator.pop(dialogCtx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('রিসেট', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: SizedBox(
            width: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                color: AppTheme.accentTeal,
                backgroundColor: Color(0xFF1E293B),
                minHeight: 4,
              ),
            ),
          ),
        ),
      );
    }

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
          
          _buildSectionHeader('অ্যাপ সেটিংস'),
          _buildSettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.record_voice_over_rounded, color: AppTheme.accentTeal, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'কথা বলার গতি (Voice Speed)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'গতি: ${_ttsSpeed.toStringAsFixed(1)} (${_getSpeedLabel(_ttsSpeed)})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.accentTeal,
                        inactiveTrackColor: const Color(0xFF263238),
                        thumbColor: AppTheme.accentTeal,
                        overlayColor: AppTheme.accentTeal.withAlpha(30),
                        trackHeight: 3,
                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                        valueIndicatorColor: AppTheme.cardBg,
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: _ttsSpeed,
                        min: 0.3,
                        max: 0.8,
                        divisions: 5,
                        onChanged: _saveTtsSpeed,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentIndigo.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.alarm_rounded, color: AppTheme.accentIndigo, size: 20),
                ),
                title: const Text(
                  'মেডিসিন নোটিফিকেশন',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                subtitle: const Text(
                  'ওষুধ খাওয়ার সময়ে রিমাইন্ডার এলার্ট পান',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                value: _smartNotifications,
                activeTrackColor: AppTheme.accentTeal,
                onChanged: _saveNotifications,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionHeader('সহায়তা ও তথ্য'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppTheme.accentTeal,
                title: 'ব্যবহার সহায়িকা',
                subtitle: 'অ্যাপ কীভাবে ব্যবহার করবেন তা জানুন',
                onTap: () => _showUserGuide(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.warning_amber_rounded,
                iconColor: AppTheme.warningRed,
                title: 'মেডিকেল সতর্কীকরণ',
                subtitle: 'চিকিৎসা সংক্রান্ত সতর্কতা ও দায়মুক্তি দেখুন',
                onTap: () => _showDisclaimer(context),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionHeader('রিসেট'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.refresh_rounded,
                iconColor: AppTheme.accentIndigo,
                title: 'অনবোর্ডিং আবার দেখুন',
                subtitle: 'স্বাগতম ও নিয়মাবলী স্ক্রিনে ফিরে যান',
                onTap: () => _confirmResetOnboarding(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.delete_forever_rounded,
                iconColor: AppTheme.warningRed,
                title: 'অ্যাপ ডেটা মুছুন',
                subtitle: 'রিমাইন্ডার এবং স্ক্যানিং ইতিহাস খালি করুন',
                onTap: () => _confirmResetData(context),
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
