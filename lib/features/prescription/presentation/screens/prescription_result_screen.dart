import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_bloc.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_state.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/screens/medicine_detail_screen.dart';

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
            return _buildResultView(context, state.medicines);
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
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
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

  Widget _buildResultView(BuildContext context, List<PrescriptionMedicine> medicines) {
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
          (entry) => _buildMedicineCard(context, entry.key + 1, entry.value),
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

  Widget _buildMedicineCard(BuildContext context, int index, PrescriptionMedicine medicine) {
    void routeToDetail() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineDetailScreen(
            medicine: medicine.toMedicine(),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: routeToDetail,
          borderRadius: BorderRadius.circular(16),
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
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textSecondary,
                      size: 14,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      _formatDosage(medicine.dosage),
                      AppTheme.accentIndigo,
                    ),
                    _buildDosageVisuals(medicine.dosage),
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
              const Divider(color: Color(0xFF263238), height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentTeal,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: routeToDetail,
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: const Text(
                        'বিস্তারিত দেখুন',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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

  static String _formatDosage(String rawDosage) {
    if (rawDosage.isEmpty) return 'তথ্য পাওয়া যায়নি';

    if (rawDosage.contains('(') ||
        rawDosage.contains('সকালে') ||
        rawDosage.contains('রাতে')) {
      return rawDosage;
    }

    var normalized = rawDosage
        .replaceAll('+', '-')
        .replaceAll(',', '-')
        .replaceAll('/', '-')
        .replaceAll(' ', '');

    normalized = normalized
        .replaceAll('১', '1')
        .replaceAll('২', '2')
        .replaceAll('৩', '3')
        .replaceAll('৪', '4')
        .replaceAll('৫', '5')
        .replaceAll('৬', '6')
        .replaceAll('৭', '7')
        .replaceAll('৮', '8')
        .replaceAll('৯', '9')
        .replaceAll('০', '0');

    final parts = normalized.split('-');
    if (parts.length >= 2 &&
        parts.length <= 4 &&
        parts.every((p) => RegExp(r'^\d+$').hasMatch(p))) {
      final ints = parts.map(int.parse).toList();

      String toBanglaDigit(String engDigit) {
        return engDigit
            .replaceAll('1', '১')
            .replaceAll('2', '২')
            .replaceAll('3', '৩')
            .replaceAll('4', '৪')
            .replaceAll('5', '৫')
            .replaceAll('6', '৬')
            .replaceAll('7', '৭')
            .replaceAll('8', '৮')
            .replaceAll('9', '৯')
            .replaceAll('0', '০');
      }

      final banglaParts = <String>[];

      if (ints.length == 2) {
        if (ints[0] > 0) banglaParts.add('সকালে ${toBanglaDigit(parts[0])}টি');
        if (ints[1] > 0) banglaParts.add('রাতে ${toBanglaDigit(parts[1])}টি');
      } else if (ints.length == 3) {
        if (ints[0] > 0) banglaParts.add('সকালে ${toBanglaDigit(parts[0])}টি');
        if (ints[1] > 0) banglaParts.add('দুপুরে ${toBanglaDigit(parts[1])}টি');
        if (ints[2] > 0) banglaParts.add('রাতে ${toBanglaDigit(parts[2])}টি');
      } else if (ints.length == 4) {
        if (ints[0] > 0) banglaParts.add('সকালে ${toBanglaDigit(parts[0])}টি');
        if (ints[1] > 0) banglaParts.add('দুপুরে ${toBanglaDigit(parts[1])}টি');
        if (ints[2] > 0) banglaParts.add('বিকালে ${toBanglaDigit(parts[2])}টি');
        if (ints[3] > 0) banglaParts.add('রাতে ${toBanglaDigit(parts[3])}টি');
      }

      if (banglaParts.isNotEmpty) {
        String partsText = '';
        if (banglaParts.length == 1) {
          partsText = banglaParts.first;
        } else if (banglaParts.length == 2) {
          partsText = '${banglaParts[0]} ও ${banglaParts[1]}';
        } else if (banglaParts.length == 3) {
          partsText =
              '${banglaParts[0]}, ${banglaParts[1]} ও ${banglaParts[2]}';
        } else if (banglaParts.length == 4) {
          partsText =
              '${banglaParts[0]}, ${banglaParts[1]}, ${banglaParts[2]} ও ${banglaParts[3]}';
        }
        return '$rawDosage ($partsText করে)';
      }
    }
    return rawDosage;
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

  Widget _buildDosageVisuals(String rawDosage) {
    if (rawDosage.isEmpty) return const SizedBox.shrink();

    var normalized = rawDosage
        .replaceAll('+', '-')
        .replaceAll(',', '-')
        .replaceAll('/', '-')
        .replaceAll(' ', '');

    normalized = normalized
        .replaceAll('১', '1')
        .replaceAll('২', '2')
        .replaceAll('৩', '3')
        .replaceAll('৪', '4')
        .replaceAll('৫', '5')
        .replaceAll('৬', '6')
        .replaceAll('৭', '7')
        .replaceAll('৮', '8')
        .replaceAll('৯', '9')
        .replaceAll('০', '0');

    final parts = normalized.split('-');
    if (parts.length >= 2 &&
        parts.length <= 4 &&
        parts.every((p) => RegExp(r'^\d+$').hasMatch(p))) {
      final ints = parts.map(int.parse).toList();

      String toBanglaDigit(String engDigit) {
        return engDigit
            .replaceAll('1', '১')
            .replaceAll('2', '২')
            .replaceAll('3', '৩')
            .replaceAll('4', '৪')
            .replaceAll('5', '৫')
            .replaceAll('6', '৬')
            .replaceAll('7', '৭')
            .replaceAll('8', '৮')
            .replaceAll('9', '৯')
            .replaceAll('0', '০');
      }

      final List<Map<String, dynamic>> slots = [];

      if (ints.length == 2) {
        slots.add({'time': 'সকাল', 'qty': ints[0]});
        slots.add({'time': 'রাত', 'qty': ints[1]});
      } else if (ints.length == 3) {
        slots.add({'time': 'সকাল', 'qty': ints[0]});
        slots.add({'time': 'দুপুর', 'qty': ints[1]});
        slots.add({'time': 'রাত', 'qty': ints[2]});
      } else if (ints.length == 4) {
        slots.add({'time': 'সকাল', 'qty': ints[0]});
        slots.add({'time': 'দুপুর', 'qty': ints[1]});
        slots.add({'time': 'বিকাল', 'qty': ints[2]});
        slots.add({'time': 'রাত', 'qty': ints[3]});
      }

      return Padding(
        padding: const EdgeInsets.only(left: 28, top: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final qty = slot['qty'] as int;
            final time = slot['time'] as String;
            final isTaken = qty > 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isTaken
                    ? AppTheme.accentTeal.withAlpha(20)
                    : const Color(0xFF1E293B).withAlpha(100),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isTaken
                      ? AppTheme.accentTeal.withAlpha(100)
                      : const Color(0xFF263238),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTaken
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 14,
                    color: isTaken
                        ? AppTheme.accentTeal
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isTaken
                        ? '$time (${toBanglaDigit(qty.toString())}টি)'
                        : time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isTaken ? FontWeight.bold : FontWeight.normal,
                      color: isTaken
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
