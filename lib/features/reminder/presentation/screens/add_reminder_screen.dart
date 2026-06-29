import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/constants/app_strings.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/core/widgets/custom_snackbar.dart';
import 'package:medicine_guide_ai/core/services/notification_service.dart';
import 'package:medicine_guide_ai/features/reminder/domain/entities/reminder.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_event.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? existing;

  const AddReminderScreen({super.key, this.existing});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7};

  static const _dayLabels = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final r = widget.existing!;
      _nameController.text = r.medicineName;
      _doseController.text = r.doseDescription;
      final parts = r.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      _selectedDays
        ..clear()
        ..addAll(r.daysOfWeek);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  String _timeString() {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentTeal,
              surface: AppTheme.cardBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackBar.showError(context, AppErrors.enterMedicineName);
      return;
    }
    if (_selectedDays.isEmpty) {
      CustomSnackBar.showError(context, AppErrors.selectAtLeastOneDay);
      return;
    }

    try {
      final bool notificationGranted = await NotificationService.instance.requestPermissions();
      if (!notificationGranted && mounted) {
        CustomSnackBar.showError(context, AppErrors.notificationPermissionRequired);
        return;
      }
    } catch (e) {
      debugPrint('Notification permission check failed: $e');
    }

    final reminder = Reminder(
      id: widget.existing?.id,
      medicineName: _nameController.text.trim(),
      time: _timeString(),
      daysOfWeek: _selectedDays.toList()..sort(),
      isActive: true,
      doseDescription: _doseController.text.trim(),
    );

    if (widget.existing != null) {
      if (mounted) {
        context.read<ReminderBloc>().add(UpdateReminderEvent(reminder));
      }
    } else {
      if (mounted) {
        context.read<ReminderBloc>().add(AddReminderEvent(reminder));
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editReminderTitle : AppStrings.addReminderTitle),
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              AppStrings.save,
              style: TextStyle(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: AppStrings.medicineNameLabel,
              hint: AppStrings.medicineNameHint,
              icon: Icons.medication_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _doseController,
              label: AppStrings.doseLabel,
              hint: AppStrings.doseHint,
              icon: Icons.info_outline_rounded,
            ),
            const SizedBox(height: 24),
            _buildSectionLabel(AppStrings.timeSelection),
            const SizedBox(height: 12),
            _buildTimePicker(),
            const SizedBox(height: 24),
            _buildSectionLabel(AppStrings.daysOfWeek),
            const SizedBox(height: 12),
            _buildDayPicker(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.accentTeal, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.accentTeal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentTeal.withAlpha(80), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentTeal.withAlpha(15),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: AppTheme.accentTeal,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentTeal,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  AppStrings.timeSelectionDesc,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.accentTeal : AppTheme.cardBg,
              border: Border.all(
                color: isSelected
                    ? AppTheme.accentTeal
                    : const Color(0xFF1F2937),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.accentTeal.withAlpha(60),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                _dayLabels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentTeal.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm_add_rounded),
            const SizedBox(width: 8),
            Text(
              widget.existing != null ? AppStrings.update : AppStrings.addReminder,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
