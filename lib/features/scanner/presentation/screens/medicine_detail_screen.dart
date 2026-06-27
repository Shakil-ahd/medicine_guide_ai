import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/medicine_model.dart';
import 'package:medicine_guide_ai/core/services/gemini_service.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  late String _indications;
  late String _sideEffects;
  late String _dosage;
  late String _instructions;
  final Set<String> _expandedSections = {};
  bool _isBengali = false;

  @override
  void initState() {
    super.initState();
    _indications = widget.medicine.indications;
    _sideEffects = widget.medicine.sideEffects;
    _dosage = widget.medicine.dosage;
    _instructions = widget.medicine.instructions;
    _isBengali = _isAlreadyBengali(_indications);
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("bn-BD");
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    final m = widget.medicine;
    final text =
        "${m.name}. জেনেরিক নাম: ${m.genericName}. "
        "নির্দেশনা: $_indications. সেবনমাত্রা: $_dosage. "
        "খাওয়ার নিয়ম: $_instructions";

    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.medicine;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(m.name),
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMedicineHeader(m),
                  const SizedBox(height: 16),
                  _buildTtsButton(),
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
                    m.price,
                    Icons.monetization_on_rounded,
                    const Color(0xFFFBBF24),
                  ),
                  if (m.genericAlternatives.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildAlternativesSection(m),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  bool _isAlreadyBengali(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  void _toggleLanguage() {
    if (_isBengali) {
      setState(() {
        _indications = widget.medicine.indications;
        _sideEffects = widget.medicine.sideEffects;
        _dosage = widget.medicine.dosage;
        _instructions = widget.medicine.instructions;
        _isBengali = false;
      });
    } else {
      _translateToBengali(widget.medicine);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  Widget _buildMedicineHeader(Medicine medicine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
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
            ),
          ),
          const SizedBox(height: 6),
          Text(
            medicine.genericName,
            style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.business_rounded,
                size: 14,
                color: AppTheme.textSecondary,
              ),
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
              onPressed: _toggleLanguage,
              icon: Icon(
                _isBengali ? Icons.language_rounded : Icons.g_translate_rounded,
                size: 16,
              ),
              label: Text(
                _isBengali
                    ? 'ইংরেজিতে দেখুন (English)'
                    : 'বাংলায় অনুবাদ করুন (Translate)',
              ),
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

  Widget _buildTtsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _speak,
        icon: Icon(
          _isPlaying ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        ),
        label: Text(_isPlaying ? "পড়া থামান" : "পড়ে শোনান"),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isPlaying
              ? AppTheme.warningRed
              : AppTheme.accentIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warningRed,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "এটি চিকিৎসকের বিকল্প নয়, সেবনের পূর্বে ডাক্তারের পরামর্শ নিন।",
              style: TextStyle(color: AppTheme.warningRed, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
