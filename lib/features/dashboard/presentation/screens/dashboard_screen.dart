import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/gemini_service.dart';
import 'package:medicine_guide_ai/core/services/notification_service.dart';
import 'package:medicine_guide_ai/core/services/ocr_service.dart';
import 'package:medicine_guide_ai/core/services/tts_service.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/bloc/navigation_bloc.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/screens/prescription_scan_screen.dart';
import 'package:medicine_guide_ai/features/reminder/data/repositories/reminder_repository_impl.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/screens/reminder_screen.dart';
import 'package:medicine_guide_ai/features/scanner/data/datasources/medicine_local_datasource.dart';
import 'package:medicine_guide_ai/features/scanner/data/datasources/medicine_remote_datasource.dart';
import 'package:medicine_guide_ai/features/scanner/data/repositories/medicine_repository_impl.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/bloc/medicine_bloc.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/screens/scan_result_screen.dart';
import 'package:medicine_guide_ai/features/history/data/repositories/history_repository_impl.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_bloc.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_event.dart';
import 'package:medicine_guide_ai/features/history/presentation/screens/medical_diary_screen.dart';
import 'package:medicine_guide_ai/features/settings/presentation/screens/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReminderBloc>(
          create: (_) => ReminderBloc(
            ReminderRepositoryImpl(
              DatabaseHelper.instance,
              NotificationService.instance,
            ),
          )..add(LoadRemindersEvent()),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(
            HistoryRepositoryImpl(
              DatabaseHelper.instance,
            ),
          )..add(LoadHistoryEvent()),
        ),
      ],
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppTheme.darkBg,
            appBar: _buildAppBar(state.currentIndex),
            body: IndexedStack(
              index: state.currentIndex,
              children: [
                _buildHomeView(context),
                const ReminderScreen(),
                const MedicalDiaryScreen(),
                const SettingsScreen(),
              ],
            ),
            bottomNavigationBar: _buildBottomNav(context, state.currentIndex),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(int currentIndex) {
    final titles = [
      AppConstants.appName,
      AppConstants.pillReminder,
      AppConstants.medicalDiary,
      'সেটিংস',
    ];
    return AppBar(
      backgroundColor: AppTheme.darkBg,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentTeal, AppTheme.accentIndigo],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            titles[currentIndex],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: const Border(top: BorderSide(color: Color(0xFF263238))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, currentIndex, Icons.home_rounded, 'হোম'),
              _buildNavItem(context, 1, currentIndex, Icons.alarm_rounded, 'রিমাইন্ডার'),
              _buildNavItem(context, 2, currentIndex, Icons.history_edu_rounded, 'হিস্ট্রি'),
              _buildNavItem(context, 3, currentIndex, Icons.settings_rounded, 'সেটিংস'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    int currentIndex,
    IconData icon,
    String label,
  ) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () {
        context.read<NavigationBloc>().add(TabChanged(index));
        if (index == 1) {
          context.read<ReminderBloc>().add(LoadRemindersEvent());
        } else if (index == 2) {
          context.read<HistoryBloc>().add(LoadHistoryEvent());
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentTeal.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentTeal : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.accentTeal : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWelcomeBanner(),
        const SizedBox(height: 24),
        _buildSectionHeader('দ্রুত অ্যাক্সেস'),
        const SizedBox(height: 14),
        _buildFeatureGrid(context),
        const SizedBox(height: 24),
        _buildSectionHeader('কিভাবে ব্যবহার করবেন'),
        const SizedBox(height: 14),
        _buildHowToUse(),
        const SizedBox(height: 20),
        _buildDisclaimer(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentTeal.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentTeal.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentTeal.withAlpha(80)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppTheme.accentTeal, size: 12),
                SizedBox(width: 5),
                Text(
                  'ডিজিটাল সহায়িকা',
                  style: TextStyle(
                    color: AppTheme.accentTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'স্বাগতম! 👋',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'ওষুধের পাতা স্ক্যান করুন অথবা প্রেসক্রিপশন আপলোড করে বিস্তারিত তথ্য ও নির্দেশিকা পান।',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accentTeal, AppTheme.accentIndigo],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            title: AppConstants.scanMedicine,
            subtitle: 'ক্যামেরা দিয়ে স্ক্যান করুন',
            icon: Icons.document_scanner_rounded,
            gradientColors: [const Color(0xFF00897B), const Color(0xFF00BFA5)],
            onTap: () => _showScanBottomSheet(context),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildFeatureCard(
            title: AppConstants.prescriptionReader,
            subtitle: 'হাতের লেখা পড়ুন',
            icon: Icons.description_rounded,
            gradientColors: [const Color(0xFF3949AB), const Color(0xFF5C6BC0)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrescriptionScanScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientColors[0].withAlpha(40), gradientColors[1].withAlpha(20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: gradientColors[1].withAlpha(80)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[1].withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: gradientColors[1],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowToUse() {
    const steps = [
      (Icons.camera_alt_rounded, 'ছবি তুলুন', 'ওষুধের পাতা বা প্রেসক্রিপশনের ছবি নিন'),
      (Icons.auto_awesome_rounded, 'স্বয়ংক্রিয় বিশ্লেষণ', 'সিস্টেম স্বয়ংক্রিয়ভাবে তথ্য বের করে'),
      (Icons.info_rounded, 'ফলাফল দেখুন', 'ওষুধের বিস্তারিত তথ্য বাংলায় পড়ুন'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, title, desc) = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 16 : 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.accentTeal, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14)),
                      Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warningRed.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warningRed.withAlpha(60)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.warningRed, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppConstants.medicalDisclaimer,
              style: TextStyle(color: AppTheme.warningRed, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showScanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF263238),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ওষুধ স্ক্যান করুন',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text('ছবির উৎস নির্বাচন করুন', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildSheetOption(context, sheetCtx, 'ক্যামেরা', Icons.camera_alt_rounded, ImageSource.camera, AppTheme.accentTeal)),
                      const SizedBox(width: 14),
                      Expanded(child: _buildSheetOption(context, sheetCtx, 'গ্যালারি', Icons.photo_library_rounded, ImageSource.gallery, AppTheme.accentIndigo)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetOption(
    BuildContext context,
    BuildContext sheetCtx,
    String label,
    IconData icon,
    ImageSource source,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Navigator.pop(sheetCtx);
          final picker = ImagePicker();
          final image = await picker.pickImage(
            source: source,
            imageQuality: 50,
            maxWidth: 1000,
          );
          if (image != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (routeCtx) => BlocProvider(
                  create: (_) => MedicineBloc(
                    repository: MedicineRepositoryImpl(
                      ocrService: OcrService(),
                      localDataSource: MedicineLocalDataSourceImpl(DatabaseHelper.instance),
                      remoteDataSource: MedicineRemoteDataSourceImpl(GeminiService()),
                    ),
                    ttsService: TtsService(),
                  ),
                  child: ScanResultScreen(imagePath: image.path),
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
