import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/reminder/domain/entities/reminder.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_state.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/screens/add_reminder_screen.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  static const _dayLabels = [
    'সোম',
    'মঙ্গল',
    'বুধ',
    'বৃহ',
    'শুক্র',
    'শনি',
    'রবি',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      // appBar: AppBar(
      //   title: const Text('মেডিসিন রিমাইন্ডার'),
      //   backgroundColor: AppTheme.darkBg,
      //   elevation: 0,
      //   centerTitle: true,
      // ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return Center(
              child: SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    color: AppTheme.accentTeal,
                    backgroundColor: Color(0xFF1E293B),
                    minHeight: 4,
                  ),
                ),
              ),
            );
          }
          if (state is ReminderError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.warningRed),
              ),
            );
          }
          if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) return _buildEmptyView(context);
            return _buildList(context, state.reminders);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        backgroundColor: AppTheme.accentTeal,
        icon: const Icon(Icons.alarm_add_rounded, color: Colors.white),
        label: const Text(
          'নতুন রিমাইন্ডার',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentTeal.withAlpha(60)),
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 44,
              color: AppTheme.accentTeal,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'কোনো রিমাইন্ডার নেই',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'নতুন রিমাইন্ডার যোগ করুন এবং\nওষুধ খাওয়ার সময় মনে রাখুন',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => _openAdd(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('রিমাইন্ডার যোগ করুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Reminder> reminders) {
    final active = reminders.where((r) => r.isActive).toList();
    final inactive = reminders.where((r) => !r.isActive).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (active.isNotEmpty) ...[
          _buildSectionHeader('সক্রিয় রিমাইন্ডার', active.length),
          const SizedBox(height: 10),
          ...active.map((r) => _buildReminderCard(context, r)),
        ],
        if (inactive.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('নিষ্ক্রিয়', inactive.length),
          const SizedBox(height: 10),
          ...inactive.map((r) => _buildReminderCard(context, r)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
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
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.accentTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour % 12 == 0 ? 12 : hour % 12;
      final mStr = minute.toString().padLeft(2, '0');
      final hStr = h12.toString().padLeft(2, '0');
      return '$hStr:$mStr $amPm';
    } catch (_) {
      return time24;
    }
  }

  static String _formatDays(List<int> days) {
    if (days.isEmpty) return 'কোনো দিন নয়';
    if (days.length == 7) {
      return 'প্রতিদিন';
    }
    final isWeekdays =
        days.length == 5 &&
        days.contains(1) &&
        days.contains(2) &&
        days.contains(3) &&
        days.contains(4) &&
        days.contains(5);
    if (isWeekdays) {
      return 'সোম - শুক্র';
    }
    final isWeekends = days.length == 2 && days.contains(6) && days.contains(7);
    if (isWeekends) {
      return 'শনি - রবি';
    }
    return days.map((d) => _dayLabels[(d - 1).clamp(0, 6)]).join(', ');
  }

  Widget _buildReminderCard(BuildContext context, Reminder reminder) {
    return Dismissible(
      key: Key('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.warningRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        if (reminder.id != null) {
          context.read<ReminderBloc>().add(DeleteReminderEvent(reminder.id!));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: reminder.isActive
                ? AppTheme.accentTeal.withAlpha(60)
                : const Color(0xFF263238),
          ),
          boxShadow: reminder.isActive
              ? [
                  BoxShadow(
                    color: AppTheme.accentTeal.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: () => _openEdit(context, reminder),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: reminder.isActive
                        ? AppTheme.accentTeal.withAlpha(15)
                        : const Color(0xFF263238).withAlpha(120),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: reminder.isActive
                        ? AppTheme.accentTeal
                        : AppTheme.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicineName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: reminder.isActive
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      if (reminder.doseDescription.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          reminder.doseDescription,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: reminder.isActive
                                ? AppTheme.accentTeal.withAlpha(180)
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(reminder.time),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: reminder.isActive
                                  ? AppTheme.accentTeal
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: reminder.isActive
                                ? AppTheme.accentIndigo
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDays(reminder.daysOfWeek),
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
                    Switch(
                      value: reminder.isActive,
                      activeThumbColor: AppTheme.accentTeal,
                      onChanged: (val) {
                        if (reminder.id != null) {
                          context.read<ReminderBloc>().add(
                            ToggleReminderEvent(reminder.id!, val),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppTheme.warningRed,
                        size: 22,
                      ),
                      onPressed: () {
                        if (reminder.id != null) {
                          context.read<ReminderBloc>().add(
                            DeleteReminderEvent(reminder.id!),
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
      ),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReminderBloc>(),
          child: const AddReminderScreen(),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, Reminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReminderBloc>(),
          child: AddReminderScreen(existing: reminder),
        ),
      ),
    );
  }
}
