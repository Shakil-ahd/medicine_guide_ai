import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
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
        "নির্দেশনা: ${m.indications}. সেবনমাত্রা: ${m.dosage}. "
        "খাওয়ার নিয়ম: ${m.instructions}";

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
                    m.indications,
                    Icons.healing_rounded,
                    AppTheme.accentTeal,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoSection(
                    "সেবনমাত্রা",
                    m.dosage,
                    Icons.medical_services_rounded,
                    const Color(0xFF42A5F5),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoSection(
                    "খাওয়ার নিয়ম",
                    m.instructions,
                    Icons.info_outline_rounded,
                    const Color(0xFFA78BFA),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoSection(
                    "পার্শ্বপ্রতিক্রিয়া",
                    m.sideEffects,
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
              Text(
                medicine.manufacturer,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
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
                  content.isEmpty ? 'তথ্য পাওয়া যায়নি' : content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
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
          (alt) => Container(
            margin: const EdgeInsets.only(bottom: 10),
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
                      Text(
                        alt.manufacturer,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alt.price,
                    style: const TextStyle(
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
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
