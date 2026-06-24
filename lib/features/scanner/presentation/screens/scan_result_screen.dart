import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/scanner/presentation/bloc/medicine_bloc.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;

  const ScanResultScreen({super.key, required this.imagePath});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MedicineBloc>().add(ScanMedicineEvent(widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.accentTeal),
          const SizedBox(height: 20),
          const Text(
            "ওষুধের ছবি প্রসেস করা হচ্ছে...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "অনুগ্রহ করে অপেক্ষা করুন",
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.warningRed),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MedicineBloc>().add(ScanMedicineEvent(widget.imagePath));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("আবার চেষ্টা করুন"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, Medicine medicine) {
    final ttsText = "${medicine.name}. জেনেরিক নাম: ${medicine.genericName}. নির্দেশনা: ${medicine.indications}. সেবনমাত্রা: ${medicine.dosage}. খাওয়ার নিয়ম: ${medicine.instructions}";

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentTeal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medicine.genericName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medicine.manufacturer,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<MedicineBloc>().add(ReadMedicineTtsEvent(ttsText));
                        },
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text("পড়ে শোনান"),
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
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MedicineBloc>().add(StopMedicineTtsEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardBg,
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
                ),
                const SizedBox(height: 24),
                _buildInfoSection("নির্দেশনা (Indications)", medicine.indications, Icons.healing_rounded, AppTheme.accentTeal),
                const SizedBox(height: 16),
                _buildInfoSection("সেবনমাত্রা (Dosage)", medicine.dosage, Icons.medical_services_rounded, AppTheme.accentTeal),
                const SizedBox(height: 16),
                _buildInfoSection("খাওয়ার নিয়ম (Instructions)", medicine.instructions, Icons.info_outline_rounded, AppTheme.accentTeal),
                const SizedBox(height: 16),
                _buildInfoSection("পার্শ্বপ্রতিক্রিয়া (Side Effects)", medicine.sideEffects, Icons.report_problem_rounded, AppTheme.warningRed),
                const SizedBox(height: 16),
                _buildInfoSection("মূল্য (Price)", medicine.price, Icons.monetization_on_rounded, Colors.amber),
                const SizedBox(height: 28),
                if (medicine.genericAlternatives.isNotEmpty) ...[
                  const Text(
                    "সস্তা বিকল্প ওষুধ (Generic Alternatives)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...medicine.genericAlternatives.map((alt) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x1A00BFA5),
                            child: Icon(Icons.medication_rounded, color: AppTheme.accentTeal),
                          ),
                          title: Text(alt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(alt.manufacturer),
                          trailing: Text(
                            alt.price,
                            style: const TextStyle(
                              color: AppTheme.accentTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0x1AEF4444),
            border: Border(top: BorderSide(color: Color(0x4DEF4444))),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
