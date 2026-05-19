import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HabitItem {
  final String id;
  final String label;
  final bool completed;

  const HabitItem({
    required this.id,
    required this.label,
    required this.completed,
  });

  HabitItem copyWith({bool? completed}) {
    return HabitItem(
      id: id,
      label: label,
      completed: completed ?? this.completed,
    );
  }
}

class HabitTracker extends StatelessWidget {
  final List<HabitItem> habits;
  final void Function(String id)? onToggle;

  const HabitTracker({super.key, required this.habits, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final completedCount = habits.where((h) => h.completed).length;
    final progress = habits.isNotEmpty ? completedCount / habits.length : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgLight.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Habit Tracker',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedCount/${habits.length} selesai',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgLight.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Habit items
          ...habits.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HabitItemTile(
                habit: habit,
                onToggle: () => onToggle?.call(habit.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitItemTile extends StatelessWidget {
  final HabitItem habit;
  final VoidCallback? onToggle;

  const _HabitItemTile({required this.habit, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: habit.completed
              ? AppColors.teal.withValues(alpha: 0.1)
              : AppColors.bgLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: habit.completed
                ? AppColors.teal.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: habit.completed ? AppColors.teal : Colors.white,
                border: Border.all(
                  color: habit.completed ? AppColors.teal : AppColors.bgLight,
                  width: 2,
                ),
              ),
              child: habit.completed
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                habit.label,
                style: TextStyle(
                  color: habit.completed
                      ? AppColors.textDark
                      : AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: habit.completed
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
