import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calculator/features/age_calculator/presentation/notifiers/age_calculator_notifier.dart';
import 'package:calculator/features/age_calculator/presentation/widgets/age_input_form.dart';
import 'package:calculator/features/age_calculator/presentation/widgets/age_result_card.dart';

class AgeCalculatorScreen extends ConsumerWidget {
  const AgeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ageCalculatorProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AgeInputForm(),
              const SizedBox(height: 20),
              if (state.result != null) ...[
                AgeResultCard(result: state.result!),
                const SizedBox(height: 20),
              ],
              _buildHistorySection(context, ref, state),
              const SizedBox(
                height: 80,
              ), // bottom safe padding for floating bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    WidgetRef ref,
    AgeCalculatorState state,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Calculation History',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            if (state.history.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  _showClearHistoryDialog(context, ref);
                },
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Clear All',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (state.history.isEmpty)
          Card(
            elevation: 0,
            color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 32.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off_outlined,
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No calculations logged yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final entry = state.history[index];
              final birthString = DateFormat.yMMMMd().format(entry.birthDate);
              final asOfString = DateFormat.yMMMMd().format(entry.asOfDate);

              return Dismissible(
                key: Key(entry.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (direction) {
                  ref
                      .read(ageCalculatorProvider.notifier)
                      .deleteHistoryItem(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('History item removed'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      '${entry.result.years} Years, ${entry.result.months} Months, ${entry.result.days} Days',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Born: $birthString',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'As of: $asOfString',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    onTap: () {
                      ref
                          .read(ageCalculatorProvider.notifier)
                          .loadFromHistory(entry);
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
            'Are you sure you want to delete all saved calculations?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(ageCalculatorProvider.notifier).clearHistory();
                Navigator.pop(context);
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
