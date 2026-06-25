import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicine_guide_ai/core/services/gemini_service.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/core/widgets/scanner_loader.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_bloc.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_event.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_state.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/screens/prescription_result_screen.dart';

class PrescriptionScanScreen extends StatefulWidget {
  const PrescriptionScanScreen({super.key});

  @override
  State<PrescriptionScanScreen> createState() => _PrescriptionScanScreenState();
}

class _PrescriptionScanScreenState extends State<PrescriptionScanScreen> {
  String? _selectedImagePath;
  bool _isLoadingDialogShowing = false;
  BuildContext? _dialogContext;

  void _showLoadingDialog(BuildContext context) {
    if (_isLoadingDialogShowing) return;
    _isLoadingDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        _dialogContext = dialogCtx;
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: AppTheme.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const ScannerLoader(size: 80),
                const SizedBox(height: 24),
                const Text(
                  'প্রেসক্রিপশন বিশ্লেষণ করা হচ্ছে...',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'এটি প্রায় ১৫-৩০ সেকেন্ড সময় নিতে পারে। অনুগ্রহ করে অপেক্ষা করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PrescriptionBloc>().add(
                          PrescriptionScanCancelRequested(),
                        );
                  },
                  icon: const Icon(Icons.cancel_rounded),
                  label: const Text('বাতিল করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dismissLoadingDialog() {
    if (_isLoadingDialogShowing && _dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _isLoadingDialogShowing = false;
      _dialogContext = null;
    }
  }

  @override
  void dispose() {
    _dismissLoadingDialog();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrescriptionBloc(GeminiService()),
      child: BlocListener<PrescriptionBloc, PrescriptionState>(
        listener: (context, state) {
          if (state is PrescriptionLoading) {
            _showLoadingDialog(context);
          } else {
            _dismissLoadingDialog();
            if (state is PrescriptionLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('প্রেসক্রিপশন সফলভাবে বিশ্লেষণ করা হয়েছে এবং হিস্ট্রিতে সংরক্ষণ করা হয়েছে।'),
                  backgroundColor: AppTheme.accentTeal,
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<PrescriptionBloc>(),
                    child: const PrescriptionResultScreen(),
                  ),
                ),
              );
            } else if (state is PrescriptionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.warningRed,
                ),
              );
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.darkBg,
          appBar: AppBar(
            title: const Text('প্রেসক্রিপশন রিডার'),
            backgroundColor: AppTheme.darkBg,
            elevation: 0,
            centerTitle: true,
          ),
          body: BlocBuilder<PrescriptionBloc, PrescriptionState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildImagePreview(),
                    const SizedBox(height: 20),
                    _buildSourceButtons(),
                    const SizedBox(height: 20),
                    if (_selectedImagePath != null)
                      _buildAnalyzeButton(context, state),
                    const SizedBox(height: 20),
                    _buildTipsCard(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1560), Color(0xFF2D2080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentIndigo.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentIndigo.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withAlpha(60),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'প্রেসক্রিপশন স্ক্যান করুন',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ডাক্তারের লেখা থেকে ওষুধের তথ্য বের করুন',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _selectedImagePath != null
              ? AppTheme.accentIndigo
              : const Color(0xFF263238),
          width: _selectedImagePath != null ? 2 : 1,
        ),
      ),
      child: _selectedImagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImagePath = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.accentIndigo.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_photo_alternate_rounded,
                      color: AppTheme.accentIndigo, size: 30),
                ),
                const SizedBox(height: 12),
                const Text(
                  'প্রেসক্রিপশনের ছবি যোগ করুন',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
    );
  }

  Widget _buildSourceButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSourceButton(
            label: 'ক্যামেরা',
            icon: Icons.camera_alt_rounded,
            source: ImageSource.camera,
            color: AppTheme.accentTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSourceButton(
            label: 'গ্যালারি',
            icon: Icons.photo_library_rounded,
            source: ImageSource.gallery,
            color: AppTheme.accentIndigo,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceButton({
    required String label,
    required IconData icon,
    required ImageSource source,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickImage(source),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, PrescriptionState state) {
    final isLoading = state is PrescriptionLoading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                context.read<PrescriptionBloc>().add(
                      PrescriptionScanRequested(_selectedImagePath!),
                    );
              },
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('বিশ্লেষণ করুন'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentIndigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.accentIndigo.withAlpha(100),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    const tips = [
      'ভালো আলোতে ছবি তুলুন',
      'প্রেসক্রিপশন সমতল রাখুন',
      'পুরো প্রেসক্রিপশন ফ্রেমে রাখুন',
      'ঝাপসা ছবি এড়িয়ে চলুন',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentIndigo.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentIndigo.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: AppTheme.accentIndigo, size: 18),
              SizedBox(width: 8),
              Text(
                'ভালো ফলাফলের জন্য টিপস',
                style: TextStyle(
                  color: AppTheme.accentIndigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.accentTeal, size: 15),
                  const SizedBox(width: 8),
                  Text(
                    tip,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 1000,
    );
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }
}
