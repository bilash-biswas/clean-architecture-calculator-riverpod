import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/weight_converter_notifier.dart';
import '../../domain/entities/weight_unit.dart';

class WeightConverterScreen extends ConsumerWidget {
  const WeightConverterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weightConverterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // 1. Converter Panels & Swap Section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Source unit panel
                _buildUnitPanel(
                  context: context,
                  ref: ref,
                  isFrom: true,
                  unitAbbr: state.fromUnit,
                  valueStr: state.fromValue,
                  isFocused: state.isFromFocused,
                ),
                const SizedBox(height: 12),

                // Swap floating button
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.swap_vert, color: theme.colorScheme.primary),
                        iconSize: 28,
                        onPressed: () => ref.read(weightConverterProvider.notifier).swapUnits(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Target unit panel
                _buildUnitPanel(
                  context: context,
                  ref: ref,
                  isFrom: false,
                  unitAbbr: state.toUnit,
                  valueStr: state.toValue,
                  isFocused: !state.isFromFocused,
                ),
                const SizedBox(height: 20),

                // Save to history button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary.withValues(alpha: 0.12), theme.colorScheme.secondary.withValues(alpha: 0.12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(weightConverterProvider.notifier).saveToHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conversion log saved successfully!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(Icons.bookmark_add_outlined, size: 20, color: theme.colorScheme.primary),
                    label: Text(
                      'Save to Logs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Customized Numerical Keypad
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF13111C).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(36),
            ),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Column(
            children: [
              _buildKeypadRow(context, ref, ['7', '8', '9', '⌫']),
              _buildKeypadRow(context, ref, ['4', '5', '6', 'C']),
              _buildKeypadRow(context, ref, ['1', '2', '3', '.']),
              _buildKeypadRow(context, ref, ['0']),
            ],
          ),
        ),
        const SizedBox(height: 76), // Spacing for floating navbar
      ],
    );
  }

  Widget _buildUnitPanel({
    required BuildContext context,
    required WidgetRef ref,
    required bool isFrom,
    required String unitAbbr,
    required String valueStr,
    required bool isFocused,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unit = WeightUnit.fromAbbreviation(unitAbbr);

    final borderColor = isFocused
        ? theme.colorScheme.primary
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03));

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: InkWell(
          onTap: () => ref.read(weightConverterProvider.notifier).selectTab(isFrom),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: isFocused
                  ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.05 : 0.02)
                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Unit selector & abbreviation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFrom ? 'FROM' : 'TO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isFocused ? theme.colorScheme.primary : (isDark ? Colors.white38 : Colors.black38),
                        letterSpacing: 1.2,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showUnitSelectorBottomSheet(context, ref, isFrom),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${unit.name} (${unit.abbreviation})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bottom row: Large numeric value
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    valueStr,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: isFocused
                          ? (isDark ? Colors.white : theme.colorScheme.primary)
                          : (isDark ? Colors.white60 : Colors.black45),
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(
    BuildContext context,
    WidgetRef ref,
    List<String> keys,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: _buildKeypadButton(context, ref, key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifier = ref.read(weightConverterProvider.notifier);

    final isAction = text == '⌫' || text == 'C';

    Color btnColor;
    Color textColor;

    if (isAction) {
      btnColor = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04);
      textColor = isDark ? Colors.cyan : theme.colorScheme.secondary;
    } else {
      btnColor = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.white;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return _WeightKeypadButton(
      text: text,
      btnColor: btnColor,
      textColor: textColor,
      isAction: isAction,
      onTap: () {
        if (text == 'C') {
          notifier.clear();
        } else if (text == '⌫') {
          notifier.backspace();
        } else {
          notifier.appendDigit(text);
        }
      },
    );
  }

  void _showUnitSelectorBottomSheet(BuildContext context, WidgetRef ref, bool isFrom) {
    final theme = Theme.of(context);

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
              height: 400,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF13111C).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFrom ? 'Select Source Unit' : 'Select Target Unit',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: WeightUnit.units.length,
                      itemBuilder: (context, index) {
                        final unit = WeightUnit.units[index];
                        return ListTile(
                          title: Text(unit.name),
                          trailing: Text(
                            unit.abbreviation,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          onTap: () {
                            if (isFrom) {
                              ref.read(weightConverterProvider.notifier).setFromUnit(unit.abbreviation);
                            } else {
                              ref.read(weightConverterProvider.notifier).setToUnit(unit.abbreviation);
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeightKeypadButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color btnColor;
  final Color textColor;
  final bool isAction;

  const _WeightKeypadButton({
    required this.text,
    required this.onTap,
    required this.btnColor,
    required this.textColor,
    required this.isAction,
  });

  @override
  State<_WeightKeypadButton> createState() => _WeightKeypadButtonState();
}

class _WeightKeypadButtonState extends State<_WeightKeypadButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AspectRatio(
          aspectRatio: widget.text == '0' ? 4.5 : 1.3,
          child: Container(
            decoration: BoxDecoration(
              color: widget.btnColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: widget.isAction ? FontWeight.bold : FontWeight.w500,
                  color: widget.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
