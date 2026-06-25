import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/history/domain/entities/history_entry.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_bloc.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_event.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_state.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/medicine_model.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/screens/medicine_detail_screen.dart';

class MedicalDiaryScreen extends StatefulWidget {
  const MedicalDiaryScreen({super.key});

  @override
  State<MedicalDiaryScreen> createState() => _MedicalDiaryScreenState();
}

class _MedicalDiaryScreenState extends State<MedicalDiaryScreen> {
  final Set<int> _expandedIds = {};

  void _showImageDialog(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(LoadHistoryEvent());
  }

  String _formatDate(DateTime dt) {
    final months = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];
    final dayStr = _toBanglaDigit(dt.day.toString());
    final monthStr = months[dt.month - 1];
    final yearStr = _toBanglaDigit(dt.year.toString());

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'রাত/বিকাল' : 'সকাল/দুপুর';
    final minuteStr = _toBanglaDigit(dt.minute.toString().padLeft(2, '0'));
    final hourStr = _toBanglaDigit(hour.toString().padLeft(2, '0'));

    return '$dayStr $monthStr $yearStr, $amPm $hourStr:$minuteStr';
  }

  String _toBanglaDigit(String engDigit) {
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

  Future<void> _viewMedicineDetails(BuildContext context, String name) async {
    final row = await DatabaseHelper.instance.getMedicineByName(name);
    if (row != null && context.mounted) {
      final medicine = MedicineModel.fromDbMap(row);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineDetailScreen(medicine: medicine),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ওষুধের বিস্তারিত তথ্য পাওয়া যায়নি।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentIndigo),
            );
          }
          if (state is HistoryError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.warningRed),
              ),
            );
          }
          if (state is HistoryLoaded) {
            if (state.history.isEmpty) return _buildEmptyView();
            return _buildList(state.history);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentIndigo.withAlpha(60)),
            ),
            child: const Icon(
              Icons.history_edu_rounded,
              size: 44,
              color: AppTheme.accentIndigo,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'কোনো হিস্ট্রি নেই',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ওষুধ স্ক্যান করলে এখানে তার\nইতিহাস ও তালিকা সংরক্ষিত থাকবে।',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<HistoryEntry> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final isExpanded = _expandedIds.contains(entry.id);

        if (entry.isPrescription) {
          final fileExists = entry.imagePath != null && File(entry.imagePath!).existsSync();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded ? AppTheme.accentIndigo.withAlpha(150) : const Color(0xFF263238),
              ),
              boxShadow: isExpanded
                  ? [
                      BoxShadow(
                        color: AppTheme.accentIndigo.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Large prescription image
                      GestureDetector(
                        onTap: fileExists ? () => _showImageDialog(context, entry.imagePath!) : null,
                        child: Hero(
                          tag: 'prescription_img_${entry.id}',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF263238)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: fileExists
                                  ? Image.file(
                                      File(entry.imagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.description_rounded,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details beside the image
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedIds.remove(entry.id);
                              } else {
                                _expandedIds.add(entry.id!);
                              }
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'প্রেসক্রিপশন স্ক্যান',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _formatDate(entry.scannedAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${entry.prescriptionMedicines!.length}টি ওষুধ চিহ্নিত',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.accentTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Expand / Show icon button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: isExpanded ? AppTheme.accentIndigo : AppTheme.accentTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedIds.remove(entry.id);
                            } else {
                              _expandedIds.add(entry.id!);
                            }
                          });
                        },
                        icon: Icon(
                          isExpanded ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isExpanded ? 'লুকান' : 'দেখুন',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.warningRed,
                          size: 22,
                        ),
                        onPressed: () {
                          if (entry.id != null) {
                            context.read<HistoryBloc>().add(
                              DeleteHistoryItemEvent(entry.id!),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Expanded list of medicines
                if (isExpanded) ...[
                  const Divider(color: Color(0xFF263238), height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'চিহ্নিত ওষুধসমূহ (বিস্তারিত দেখতে ক্লিক করুন):',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.prescriptionMedicines!.map((med) => Card(
                          color: const Color(0xFF1E293B).withAlpha(120),
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF263238)),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MedicineDetailScreen(
                                    medicine: med.toMedicine(),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.medication_rounded,
                                    color: AppTheme.accentIndigo,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          med.name,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'উদ্দেশ্য: ${med.purpose.isNotEmpty ? med.purpose : 'N/A'} • ডোজ: ${med.dosage} • সময়কাল: ${med.duration}',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppTheme.textSecondary,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // Regular Scanned Medicine layout
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF263238)),
          ),
          child: InkWell(
            onTap: () => _viewMedicineDetails(context, entry.medicineName),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: entry.isOffline
                          ? AppTheme.accentTeal.withAlpha(15)
                          : AppTheme.accentIndigo.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      entry.isOffline
                          ? Icons.offline_pin_rounded
                          : Icons.cloud_done_rounded,
                      color: entry.isOffline
                          ? AppTheme.accentTeal
                          : AppTheme.accentIndigo,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.medicineName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatDate(entry.scannedAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: entry.isOffline
                              ? AppTheme.accentTeal.withAlpha(20)
                              : AppTheme.accentIndigo.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.isOffline ? 'অফলাইন' : 'অনলাইন',
                          style: TextStyle(
                            fontSize: 10,
                            color: entry.isOffline
                                ? AppTheme.accentTeal
                                : AppTheme.accentIndigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.warningRed,
                          size: 22,
                        ),
                        onPressed: () {
                          if (entry.id != null) {
                            context.read<HistoryBloc>().add(
                              DeleteHistoryItemEvent(entry.id!),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
