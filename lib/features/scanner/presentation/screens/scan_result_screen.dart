import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/bloc/medicine_bloc.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';
import 'package:medicine_guide_ai/core/widgets/scanner_loader.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/gemini_service.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/medicine_model.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/screens/medicine_detail_screen.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;

  const ScanResultScreen({super.key, required this.imagePath});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late String _indications;
  late String _sideEffects;
  late String _dosage;
  late String _instructions;
  final Set<String> _expandedSections = {};
  Medicine? _loadedMedicine;
  bool _isBengali = false;

  @override
  void initState() {
    super.initState();
    context.read<MedicineBloc>().add(ScanMedicineEvent(widget.imagePath));
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isAlreadyBengali(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  void _toggleLanguage(Medicine medicine) {
    if (_isBengali) {
      setState(() {
        _indications = medicine.indications;
        _sideEffects = medicine.sideEffects;
        _dosage = medicine.dosage;
        _instructions = medicine.instructions;
        _isBengali = false;
      });
    } else {
      _translateToBengali(medicine);
    }
  }

  Future<void> _translateToBengali(Medicine medicine) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentTeal),
      ),
    );

    try {
      final geminiService = GeminiService();
      final translated = await geminiService.translateMedicineDetails(
        name: medicine.name,
        genericName: medicine.genericName,
        indications: _indications,
        sideEffects: _sideEffects,
        dosage: _dosage,
        instructions: _instructions,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (translated != null) {
        if (!mounted) return;

        setState(() {
          _indications = translated['indications']!;
          _sideEffects = translated['sideEffects']!;
          _dosage = translated['dosage']!;
          _instructions = translated['instructions']!;
          _isBengali = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সফলভাবে বাংলায় অনুবাদ করা হয়েছে!')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        var errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring(11);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text("স্ক্যান ফলাফল"),
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
      body: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          if (state is MedicineLoading) {
            return _buildLoadingView();
          } else if (state is MedicineLoaded) {
            if (_loadedMedicine != state.medicine) {
              _loadedMedicine = state.medicine;
              _indications = state.medicine.indications;
              _sideEffects = state.medicine.sideEffects;
              _dosage = state.medicine.dosage;
              _instructions = state.medicine.instructions;
              _isBengali = _isAlreadyBengali(_indications);
            }
            return _buildResultView(context, state.medicine);
          } else if (state is MedicineError) {
            return _buildErrorView(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScannerLoader(size: 100),
            SizedBox(height: 32),
            Text(
              "বিশ্লেষণ করা হচ্ছে...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "ওষুধের তথ্য সংগ্রহ করা হচ্ছে\nঅনুগ্রহ করে অপেক্ষা করুন",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.warningRed.withAlpha(20),
                border: Border.all(
                  color: AppTheme.warningRed.withAlpha(80),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.warningRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "তথ্য পাওয়া যায়নি",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningRed.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warningRed.withAlpha(60)),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text("ফিরে যান"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: Color(0xFF263238)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<MedicineBloc>()
                          .add(ScanMedicineEvent(widget.imagePath));
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("আবার চেষ্টা"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, Medicine medicine) {
    final ttsText =
        "${medicine.name}. জেনেরিক নাম: ${medicine.genericName}. "
        "নির্দেশনা: $_indications. সেবনমাত্রা: $_dosage. "
        "খাওয়ার নিয়ম: $_instructions";

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCard(),
                const SizedBox(height: 16),
                _buildMedicineHeader(medicine),
                const SizedBox(height: 16),
                _buildTtsControls(context, ttsText),
                const SizedBox(height: 20),
                _buildInfoSection(
                  "নির্দেশনা",
                  _indications,
                  Icons.healing_rounded,
                  AppTheme.accentTeal,
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  "সেবনমাত্রা",
                  _dosage,
                  Icons.medical_services_rounded,
                  const Color(0xFF42A5F5),
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  "খাওয়ার নিয়ম",
                  _instructions,
                  Icons.info_outline_rounded,
                  const Color(0xFFA78BFA),
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  "পার্শ্বপ্রতিক্রিয়া",
                  _sideEffects,
                  Icons.report_problem_rounded,
                  AppTheme.warningRed,
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  "আনুমানিক মূল্য",
                  medicine.price,
                  Icons.monetization_on_rounded,
                  const Color(0xFFFBBF24),
                ),
                if (medicine.genericAlternatives.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildAlternativesSection(medicine),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildDisclaimer(),
      ],
    );
  }

  Widget _buildImageCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.file(
            File(widget.imagePath),
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.darkBg.withAlpha(200),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 10,
            left: 12,
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.accentTeal, size: 16),
                SizedBox(width: 6),
                Text(
                  "স্ক্যান সম্পন্ন",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineHeader(Medicine medicine) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2640), Color(0xFF161E31)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentTeal.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medicine.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentTeal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            medicine.genericName,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.business_rounded, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  medicine.manufacturer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _toggleLanguage(medicine),
              icon: Icon(
                _isBengali ? Icons.language_rounded : Icons.g_translate_rounded,
                size: 16,
              ),
              label: Text(_isBengali ? 'ইংরেজিতে দেখুন (English)' : 'বাংলায় অনুবাদ করুন (Translate)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentTeal,
                side: const BorderSide(color: AppTheme.accentTeal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTtsControls(BuildContext context, String ttsText) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<MedicineBloc>().add(ReadMedicineTtsEvent(ttsText));
            },
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text("পড়ে শোনান"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            context.read<MedicineBloc>().add(StopMedicineTtsEvent());
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.warningRed,
            side: const BorderSide(color: Color(0xFF263238)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.volume_off_rounded),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    if (content.isEmpty) {
      content = 'তথ্য পাওয়া যায়নি';
    }

    final isLong = content.length > 150;
    final isExpanded = _expandedSections.contains(title);
    
    final String displayContent;
    if (isLong && !isExpanded) {
      displayContent = '${content.substring(0, 150)}...';
    } else {
      displayContent = content;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  displayContent,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                if (isLong) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedSections.remove(title);
                        } else {
                          _expandedSections.add(title);
                        }
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'কমিয়ে দেখান' : 'আরও পড়ুন',
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: color,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesSection(Medicine medicine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "বিকল্প ওষুধ",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...medicine.genericAlternatives.map(
          (alt) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentTeal,
                    ),
                  ),
                );

                try {
                  final dbHelper = DatabaseHelper.instance;
                  Map<String, dynamic>? row = await dbHelper.getMedicineByName(
                    alt.name,
                  );

                  if (row == null) {
                    final searchResults = await dbHelper.searchMedicines(
                      alt.name,
                    );
                    if (searchResults.isNotEmpty) {
                      row = searchResults.first;
                    }
                  }

                  if (!mounted) return;
                  Navigator.pop(context);

                  if (row != null) {
                    final medModel = MedicineModel.fromDbMap(row);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MedicineDetailScreen(medicine: medModel),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ওষুধের বিস্তারিত তথ্য পাওয়া যায়নি'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) Navigator.pop(context);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accentTeal.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: AppTheme.accentTeal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alt.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            alt.manufacturer,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (alt.price.isNotEmpty && alt.price != 'N/A') ...[
                            const SizedBox(height: 4),
                            Text(
                              alt.price,
                              style: const TextStyle(
                                color: AppTheme.accentTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0x1AEF4444),
        border: Border(top: BorderSide(color: Color(0x4DEF4444))),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.warningRed, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppConstants.medicalDisclaimer,
              style: TextStyle(
                color: AppTheme.warningRed,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


