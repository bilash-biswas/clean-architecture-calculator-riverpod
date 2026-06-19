import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calculator/app.dart';
import 'package:calculator/features/age_calculator/presentation/screens/age_calculator_screen.dart';
import 'package:calculator/features/age_calculator/presentation/notifiers/age_calculator_notifier.dart';
import 'package:calculator/features/standard_calculator/presentation/screens/standard_calculator_screen.dart';
import 'package:calculator/features/standard_calculator/presentation/notifiers/calculator_notifier.dart';
import 'package:calculator/features/bmi_calculator/presentation/screens/bmi_calculator_screen.dart';
import 'package:calculator/features/bmi_calculator/presentation/notifiers/bmi_calculator_notifier.dart';
import 'package:calculator/features/length_converter/presentation/screens/length_converter_screen.dart';
import 'package:calculator/features/length_converter/presentation/notifiers/length_converter_notifier.dart';
import 'package:calculator/features/weight_converter/presentation/screens/weight_converter_screen.dart';
import 'package:calculator/features/weight_converter/presentation/notifiers/weight_converter_notifier.dart';

class ActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

final activeTabProvider = NotifierProvider<ActiveTabNotifier, int>(ActiveTabNotifier.new);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screens = const [
      StandardCalculatorScreen(),
      AgeCalculatorScreen(),
      BMICalculatorScreen(),
      LengthConverterScreen(),
      WeightConverterScreen(),
    ];

    return Scaffold(
      extendBody: true, // Crucial for floating bottom navigation bar
      body: Stack(
        children: [
          // Dynamic Luxurious Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF07050F),
                        const Color(0xFF0E0B1E),
                        const Color(0xFF19112E),
                      ]
                    : [
                        const Color(0xFFF9FAFF),
                        const Color(0xFFECE7FF),
                        const Color(0xFFE0E7FF),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Active Screen
          IndexedStack(
            index: activeTab,
            children: screens.map((screen) {
              // Wrap screen AppBars with theme togglers
              return Theme(
                data: theme.copyWith(
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                      systemNavigationBarColor: Colors.transparent,
                      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                    ),
                    iconTheme: IconThemeData(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    titleTextStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    return Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        title: Text(
                          activeTab == 0
                              ? 'Standard Calculator'
                              : activeTab == 1
                                  ? 'Age Calculator'
                                  : activeTab == 2
                                      ? 'BMI Calculator'
                                      : activeTab == 3
                                          ? 'Length Converter'
                                          : 'Weight Converter',
                        ),
                        leading: Consumer(
                          builder: (context, ref, child) {
                            final themeMode = ref.watch(themeModeProvider);
                            final isDark = themeMode == ThemeMode.dark;
                            return IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return RotationTransition(
                                    turns: animation,
                                    child: ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  isDark ? Icons.wb_sunny_outlined : Icons.mode_night_outlined,
                                  key: ValueKey<bool>(isDark),
                                  color: isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.7),
                                ),
                              ),
                              onPressed: () {
                                ref.read(themeModeProvider.notifier).toggle();
                              },
                            );
                          },
                        ),
                        actions: [
                          if (activeTab == 0) ...[
                            IconButton(
                              icon: const Icon(Icons.history_outlined),
                              onPressed: () {
                                _showStandardHistoryBottomSheet(context, ref);
                              },
                            ),
                          ] else if (activeTab == 1) ...[
                            IconButton(
                              icon: const Icon(Icons.refresh_outlined),
                              onPressed: () {
                                ref.read(ageCalculatorProvider.notifier).reset();
                              },
                            ),
                          ] else if (activeTab == 2) ...[
                            IconButton(
                              icon: const Icon(Icons.refresh_outlined),
                              onPressed: () {
                                ref.read(bmiCalculatorProvider.notifier).reset();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.history_outlined),
                              onPressed: () {
                                _showBmiHistoryBottomSheet(context, ref);
                              },
                            ),
                          ] else if (activeTab == 3) ...[
                            IconButton(
                              icon: const Icon(Icons.refresh_outlined),
                              onPressed: () {
                                ref.read(lengthConverterProvider.notifier).reset();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.history_outlined),
                              onPressed: () {
                                _showLengthHistoryBottomSheet(context, ref);
                              },
                            ),
                          ] else if (activeTab == 4) ...[
                            IconButton(
                              icon: const Icon(Icons.refresh_outlined),
                              onPressed: () {
                                ref.read(weightConverterProvider.notifier).reset();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.history_outlined),
                              onPressed: () {
                                _showWeightHistoryBottomSheet(context, ref);
                              },
                            ),
                          ]
                        ],
                      ),
                      body: screen,
                    );
                  },
                ),
              );
            }).toList(),
          ),

          // Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildBottomNavigationBar(context, ref, activeTab),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int activeTab) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF13111C).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF9D4EDD).withValues(alpha: 0.15)
                  : const Color(0xFF4F46E5).withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF4F46E5).withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavButton(
                context: context,
                ref: ref,
                index: 0,
                activeTab: activeTab,
                icon: Icons.calculate_outlined,
                activeIcon: Icons.calculate,
                label: 'Calculator',
              ),
              _buildNavButton(
                context: context,
                ref: ref,
                index: 1,
                activeTab: activeTab,
                icon: Icons.cake_outlined,
                activeIcon: Icons.cake,
                label: 'Age',
              ),
              _buildNavButton(
                context: context,
                ref: ref,
                index: 2,
                activeTab: activeTab,
                icon: Icons.health_and_safety_outlined,
                activeIcon: Icons.health_and_safety,
                label: 'BMI',
              ),
              _buildNavButton(
                context: context,
                ref: ref,
                index: 3,
                activeTab: activeTab,
                icon: Icons.straighten_outlined,
                activeIcon: Icons.straighten,
                label: 'Length',
              ),
              _buildNavButton(
                context: context,
                ref: ref,
                index: 4,
                activeTab: activeTab,
                icon: Icons.monitor_weight_outlined,
                activeIcon: Icons.monitor_weight,
                label: 'Weight',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required int activeTab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = index == activeTab;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = theme.colorScheme.primary;
    final inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(activeTabProvider.notifier).setTab(index);
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGlassmorphicBottomSheet({
    required BuildContext context,
    required String title,
    required bool hasHistory,
    required VoidCallback onClearAll,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 480,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF13111C).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFF4F46E5).withValues(alpha: 0.08),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      if (hasHistory)
                        TextButton.icon(
                          onPressed: () {
                            onClearAll();
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.delete_sweep_outlined, size: 18, color: theme.colorScheme.error),
                          label: Text(
                            'Clear All',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStandardHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(calculatorProvider);

    _showGlassmorphicBottomSheet(
      context: context,
      title: 'Calculation History',
      hasHistory: state.history.isNotEmpty,
      onClearAll: () => ref.read(calculatorProvider.notifier).clearHistory(),
      child: state.history.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  size: 50,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  'No equations solved yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final entry = state.history[index];
                final formattedTime = DateFormat.jm().format(entry.timestamp);

                return Dismissible(
                  key: Key(entry.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(calculatorProvider.notifier).deleteHistoryItem(entry.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        entry.expression,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      subtitle: Text(
                        '= ${entry.result}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : theme.colorScheme.primary,
                        ),
                      ),
                      trailing: Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                      onTap: () {
                        ref.read(calculatorProvider.notifier).loadFromHistory(entry);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showBmiHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(bmiCalculatorProvider);

    _showGlassmorphicBottomSheet(
      context: context,
      title: 'BMI Calculation History',
      hasHistory: state.history.isNotEmpty,
      onClearAll: () => ref.read(bmiCalculatorProvider.notifier).clearHistory(),
      child: state.history.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  size: 50,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  'No calculations solved yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final entry = state.history[index];
                final formattedTime = DateFormat.yMMMd().add_jm().format(entry.timestamp);

                String detailsText = '';
                if (entry.unitSystem == 'metric') {
                  detailsText = 'H: ${entry.height.toInt()} cm | W: ${entry.weight.toInt()} kg';
                } else {
                  final totalInches = entry.height.toInt();
                  final feet = totalInches ~/ 12;
                  final inches = totalInches % 12;
                  detailsText = 'H: $feet\' $inches" | W: ${entry.weight.toInt()} lbs';
                }

                return Dismissible(
                  key: Key(entry.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(bmiCalculatorProvider.notifier).deleteHistoryItem(entry.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        'BMI: ${entry.bmi.toStringAsFixed(1)} (${entry.category})',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : theme.colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        '$detailsText\n$formattedTime',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showLengthHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(lengthConverterProvider);

    _showGlassmorphicBottomSheet(
      context: context,
      title: 'Length Conversion History',
      hasHistory: state.history.isNotEmpty,
      onClearAll: () => ref.read(lengthConverterProvider.notifier).clearHistory(),
      child: state.history.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  size: 50,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  'No conversions saved yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final entry = state.history[index];
                final formattedTime = DateFormat.yMMMd().add_jm().format(entry.timestamp);

                return Dismissible(
                  key: Key(entry.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(lengthConverterProvider.notifier).deleteHistoryItem(entry.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        '${entry.fromValue} ${entry.fromUnit} = ${entry.toValue} ${entry.toUnit}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : theme.colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        formattedTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showWeightHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(weightConverterProvider);

    _showGlassmorphicBottomSheet(
      context: context,
      title: 'Weight Conversion History',
      hasHistory: state.history.isNotEmpty,
      onClearAll: () => ref.read(weightConverterProvider.notifier).clearHistory(),
      child: state.history.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  size: 50,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  'No conversions saved yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final entry = state.history[index];
                final formattedTime = DateFormat.yMMMd().add_jm().format(entry.timestamp);

                return Dismissible(
                  key: Key(entry.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(weightConverterProvider.notifier).deleteHistoryItem(entry.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        '${entry.fromValue} ${entry.fromUnit} = ${entry.toValue} ${entry.toUnit}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : theme.colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        formattedTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
