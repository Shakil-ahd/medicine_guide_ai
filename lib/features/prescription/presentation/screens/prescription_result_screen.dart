import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_bloc.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_state.dart';

class PrescriptionResultScreen extends StatelessWidget {
  const PrescriptionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('প্রেসক্রিপশন বিশ্লেষণ'),
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
      body: BlocBuilder<PrescriptionBloc, PrescriptionState>(
        builder: (context, state) {
          if (state is PrescriptionLoading) {
            return _buildLoadingView();
          }
          if (state is PrescriptionError) {
            return _buildErrorView(context, state.message);
          }
          if (state is PrescriptionLoaded) {
            return _buildResultView(state.medicines);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accentIndigo),
          SizedBox(height: 24),
          Text(
            'প্রেসক্রিপশন বিশ্লেষণ করা হচ্ছে...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'এটি কয়েক সেকেন্ড সময় নিতে পারে',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.warningRed,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('ফিরে যান'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(List<PrescriptionMedicine> medicines) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accentIndigo, Color(0xFF5C35CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'প্রেসক্রিপশন পাওয়া গেছে',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${medicines.length}টি ওষুধ চিহ্নিত করা হয়েছে',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...medicines.asMap().entries.map(
          (entry) => _buildMedicineCard(entry.key + 1, entry.value),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0x1AEF4444),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x4DEF4444)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warningRed,
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'এই বিশ্লেষণ শুধুমাত্র তথ্যের উদ্দেশ্যে। ওষুধ সেবনের আগে অবশ্যই চিকিৎসকের পরামর্শ নিন।',
                  style: TextStyle(color: AppTheme.warningRed, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(int index, PrescriptionMedicine medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0x1A6C63FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.accentIndigo,
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    medicine.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.medical_information_rounded,
                  'উদ্দেশ্য',
                  medicine.purpose,
                  AppTheme.accentTeal,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.medication_rounded,
                  'ডোজ',
                  medicine.dosage,
                  AppTheme.accentIndigo,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  'সময়কাল',
                  medicine.duration,
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'তথ্য পাওয়া যায়নি' : value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
