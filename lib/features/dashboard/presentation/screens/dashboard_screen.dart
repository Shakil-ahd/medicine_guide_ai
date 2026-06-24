import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/gemini_service.dart';
import 'package:medicine_guide_ai/core/services/ocr_service.dart';
import 'package:medicine_guide_ai/core/services/tts_service.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/bloc/navigation_bloc.dart';
import 'package:medicine_guide_ai/features/scanner/data/datasources/medicine_local_datasource.dart';
import 'package:medicine_guide_ai/features/scanner/data/datasources/medicine_remote_datasource.dart';
import 'package:medicine_guide_ai/features/scanner/data/repositories/medicine_repository_impl.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/bloc/medicine_bloc.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/screens/scan_result_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeView(context),
      _buildPlaceholderView(AppConstants.pillReminder, Icons.alarm),
      _buildPlaceholderView(AppConstants.medicalDiary, Icons.book_online),
      _buildPlaceholderView("সেটিংস", Icons.settings),
    ];

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.appName),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.darkBg, Color(0xFF101726)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          body: pages[state.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(TabChanged(index));
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.cardBg,
            selectedItemColor: AppTheme.accentTeal,
            unselectedItemColor: AppTheme.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: "হোম",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm_rounded),
                label: "রিমাইন্ডার",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: "হিস্ট্রি",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: "সেটিংস",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentIndigo, AppTheme.accentTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "স্বাগতম!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "আপনার ওষুধের পাতা স্ক্যান করুন অথবা প্রেসক্রিপশন আপলোড করে এআই নির্দেশিকা পান।",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "দ্রুত অ্যাক্সেস",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildFeatureCard(
                title: AppConstants.scanMedicine,
                subtitle: "ক্যামেরা দিয়ে স্ক্যান করুন",
                icon: Icons.camera_alt_rounded,
                color: AppTheme.accentTeal,
                onTap: () => _showImageSourceSheet(context),
              ),
              _buildFeatureCard(
                title: AppConstants.prescriptionReader,
                subtitle: "প্রেসক্রিপশন রিডার",
                icon: Icons.description_rounded,
                color: AppTheme.accentIndigo,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x1AEF4444),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x4DEF4444)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.warningRed),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.medicalDisclaimer,
                    style: TextStyle(
                      color: AppTheme.warningRed,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ওষুধ স্ক্যান করার উৎস নির্বাচন করুন",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      context: context,
                      sheetContext: sheetContext,
                      label: "ক্যামেরা",
                      icon: Icons.camera_alt_rounded,
                      source: ImageSource.camera,
                    ),
                    _buildSourceOption(
                      context: context,
                      sheetContext: sheetContext,
                      label: "গ্যালারি",
                      icon: Icons.photo_library_rounded,
                      source: ImageSource.gallery,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required BuildContext sheetContext,
    required String label,
    required IconData icon,
    required ImageSource source,
  }) {
    return InkWell(
      onTap: () async {
        Navigator.pop(sheetContext);
        final picker = ImagePicker();
        final image = await picker.pickImage(source: source);
        if (image != null) {
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (routeContext) => BlocProvider(
                create: (blocContext) => MedicineBloc(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0x1A00BFA5),
            child: Icon(icon, color: AppTheme.accentTeal, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF263238)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderView(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "ফিচারটি শীঘ্রই যুক্ত করা হবে",
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
