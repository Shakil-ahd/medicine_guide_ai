import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
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

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ওষুধের নাম দিন')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কমপক্ষে একটি দিন নির্বাচন করুন')),
      );
      return;
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
      context.read<ReminderBloc>().add(UpdateReminderEvent(reminder));
    } else {
      context.read<ReminderBloc>().add(AddReminderEvent(reminder));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(isEditing ? 'রিমাইন্ডার সম্পাদনা' : 'নতুন রিমাইন্ডার'),
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'সংরক্ষণ',
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
              label: 'ওষুধের নাম',
              hint: 'যেমন: Napa, Losec, Metformin...',
              icon: Icons.medication_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _doseController,
              label: 'মাত্রা / নির্দেশনা',
              hint: 'যেমন: ১টি ট্যাবলেট খাবারের পর',
              icon: Icons.info_outline_rounded,
            ),
            const SizedBox(height: 24),
            _buildSectionLabel('সময় নির্বাচন'),
            const SizedBox(height: 12),
            _buildTimePicker(),
            const SizedBox(height: 24),
            _buildSectionLabel('সপ্তাহের দিন'),
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
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF546E7A), fontSize: 13),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentTeal.withAlpha(80)),
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
                  'ট্যাপ করে সময় পরিবর্তন করুন',
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
                    : const Color(0xFF263238),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.alarm_add_rounded),
        label: Text(
          widget.existing != null ? 'আপডেট করুন' : 'রিমাইন্ডার যোগ করুন',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
