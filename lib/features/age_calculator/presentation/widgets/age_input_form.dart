import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calculator/features/age_calculator/presentation/notifiers/age_calculator_notifier.dart';

class AgeInputForm extends ConsumerWidget {
  const AgeInputForm({super.key});

  void _showDatePicker(BuildContext context, WidgetRef ref, bool isBirthDate, DateTime initialDate) {
    final theme = Theme.of(context);
    final notifier = ref.read(ageCalculatorProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        DateTime selectedDate = initialDate;
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  Text(
                    isBirthDate ? 'Select Birth Date' : 'Select As of Date',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      if (isBirthDate) {
                        notifier.setBirthDate(selectedDate);
                      } else {
                        notifier.setAsOfDate(selectedDate);
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Confirm',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: theme.brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    maximumDate: DateTime.now().add(const Duration(days: 365 * 100)), // Allow future dates for "as of"
                    minimumDate: DateTime(1900),
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ageCalculatorProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final birthDateText = state.birthDate != null
        ? DateFormat.yMMMMd().format(state.birthDate!)
        : 'Select Date';
    final asOfDateText = DateFormat.yMMMMd().format(state.asOfDate);

    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calculate Age',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: isDark ? Colors.white : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Birth Date Selector
            _buildDateTile(
              context: context,
              title: 'Date of Birth',
              subtitle: birthDateText,
              icon: Icons.cake_outlined,
              color: isDark ? theme.colorScheme.primary : const Color(0xFF4F46E5),
              onTap: () {
                _showDatePicker(
                  context,
                  ref,
                  true,
                  state.birthDate ?? DateTime(2000, 1, 1),
                );
              },
            ),
            const SizedBox(height: 16),
            // As Of Date Selector
            _buildDateTile(
              context: context,
              title: 'Age as of Date',
              subtitle: asOfDateText,
              icon: Icons.calendar_today_outlined,
              color: isDark ? theme.colorScheme.secondary : const Color(0xFF0D9488),
              onTap: () {
                _showDatePicker(
                  context,
                  ref,
                  false,
                  state.asOfDate,
                );
              },
            ),
            const SizedBox(height: 24),
            // Calculate Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: state.birthDate == null
                    ? null
                    : LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: state.birthDate == null
                    ? null
                    : [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: ElevatedButton(
                onPressed: state.birthDate == null
                    ? null
                    : () {
                        ref.read(ageCalculatorProvider.notifier).calculate();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  disabledBackgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.03),
                  elevation: 0,
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
            ),
            color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: subtitle == 'Select Date'
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
