import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/bmi_calculator_notifier.dart';
import '../../domain/entities/bmi_entity.dart';

class BMICalculatorScreen extends ConsumerWidget {
  const BMICalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bmiCalculatorProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Gender Selection Row
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  context: context,
                  ref: ref,
                  genderKey: 'male',
                  label: 'Male',
                  icon: Icons.male_outlined,
                  activeColor: Colors.cyan,
                  isSelected: state.gender == 'male',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderCard(
                  context: context,
                  ref: ref,
                  genderKey: 'female',
                  label: 'Female',
                  icon: Icons.female_outlined,
                  activeColor: Colors.pinkAccent,
                  isSelected: state.gender == 'female',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Unit System Toggle & Sliders Card
          _buildGlassCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Metric / Imperial segment switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildUnitTab(
                          label: 'Metric (kg, cm)',
                          isActive: state.unitSystem == 'metric',
                          onTap: () => ref.read(bmiCalculatorProvider.notifier).setUnitSystem('metric'),
                          isDark: isDark,
                          theme: theme,
                        ),
                      ),
                      Expanded(
                        child: _buildUnitTab(
                          label: 'Imperial (lbs, ft-in)',
                          isActive: state.unitSystem == 'imperial',
                          onTap: () => ref.read(bmiCalculatorProvider.notifier).setUnitSystem('imperial'),
                          isDark: isDark,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Height Slider
                _buildHeightSection(context, ref, state),
                const SizedBox(height: 24),

                // Weight Slider
                _buildWeightSection(context, ref, state),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Age Selector & Actions Row
          _buildGlassCard(
            context: context,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AGE',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.age}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildRoundButton(
                      icon: Icons.remove,
                      onPressed: state.age > 1
                          ? () => ref.read(bmiCalculatorProvider.notifier).setAge(state.age - 1)
                          : null,
                      isDark: isDark,
                      theme: theme,
                    ),
                    const SizedBox(width: 12),
                    _buildRoundButton(
                      icon: Icons.add,
                      onPressed: state.age < 120
                          ? () => ref.read(bmiCalculatorProvider.notifier).setAge(state.age + 1)
                          : null,
                      isDark: isDark,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: () => ref.read(bmiCalculatorProvider.notifier).calculate(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety_outlined, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Calculate BMI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5. Results Area
          if (state.bmiEntity != null) ...[
            _buildResultPanel(context, state.bmiEntity!, isDark, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderCard({
    required BuildContext context,
    required WidgetRef ref,
    required String genderKey,
    required String label,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(bmiCalculatorProvider.notifier).setGender(genderKey),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
                : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 44,
                color: isSelected ? activeColor : (isDark ? Colors.white38 : Colors.black38),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? (isDark ? Colors.white : theme.colorScheme.primary) : (isDark ? Colors.white38 : Colors.black45),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeightSection(BuildContext context, WidgetRef ref, BmiCalculatorState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String labelText = 'HEIGHT';
    String valueText = '';
    double minVal = 100.0;
    double maxVal = 220.0;

    if (state.unitSystem == 'metric') {
      valueText = '${state.height.toInt()} cm';
      minVal = 100.0;
      maxVal = 220.0;
    } else {
      final totalInches = state.height.toInt();
      final feet = totalInches ~/ 12;
      final inches = totalInches % 12;
      valueText = '$feet\' $inches"';
      minVal = 40.0;
      maxVal = 90.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              valueText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: state.height.clamp(minVal, maxVal),
            min: minVal,
            max: maxVal,
            onChanged: (val) {
              ref.read(bmiCalculatorProvider.notifier).setHeight(val.roundToDouble());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightSection(BuildContext context, WidgetRef ref, BmiCalculatorState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String labelText = 'WEIGHT';
    String valueText = '';
    double minVal = 30.0;
    double maxVal = 180.0;

    if (state.unitSystem == 'metric') {
      valueText = '${state.weight.toInt()} kg';
      minVal = 30.0;
      maxVal = 180.0;
    } else {
      valueText = '${state.weight.toInt()} lbs';
      minVal = 70.0;
      maxVal = 400.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              valueText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: state.weight.clamp(minVal, maxVal),
            min: minVal,
            max: maxVal,
            onChanged: (val) {
              ref.read(bmiCalculatorProvider.notifier).setWeight(val.roundToDouble());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon),
          color: isDark ? Colors.white : Colors.black87,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildResultPanel(
    BuildContext context,
    BmiEntity entity,
    bool isDark,
    ThemeData theme,
  ) {
    final statusColor = Color(int.parse('0x${entity.statusColorHex}'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGlassCard(
          context: context,
          child: Column(
            children: [
              Text(
                'YOUR RESULT',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.black54,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Gauge score
              Text(
                entity.bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 8),
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Text(
                  entity.category.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Ideal Weight indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ideal weight range:',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    entity.idealWeightRange,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Visual Gauge Range bar
              _buildRangeGaugeBar(entity.bmi, statusColor),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Personalized Tips checklist
        _buildGlassCard(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'PERSONALIZED INSIGHTS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...entity.healthTips.map((tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: statusColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRangeGaugeBar(double score, Color statusColor) {
    // Standard ranges: Underweight (<18.5), Normal (18.5 - 24.9), Overweight (25 - 29.9), Obese (>=30)
    // We map BMI (range 15 to 35) to standard linear position percentages: 0.0 to 1.0
    final double percentage = ((score - 15) / (35 - 15)).clamp(0.01, 0.99);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Marker pointer
        Row(
          children: [
            Spacer(flex: (percentage * 100).toInt()),
            Transform.translate(
              offset: const Offset(-8, 4),
              child: CustomPaint(
                size: const Size(16, 10),
                painter: _TrianglePainter(color: statusColor),
              ),
            ),
            Spacer(flex: ((1.0 - percentage) * 100).toInt()),
          ],
        ),
        const SizedBox(height: 4),
        // Gauge bar gradient
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: 10,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFA9F1B), // Underweight
                  Color(0xFF2ECC71), // Normal
                  Color(0xFFE67E22), // Overweight
                  Color(0xFFE74C3C), // Obese
                ],
                stops: [0.15, 0.45, 0.70, 0.95],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15.0', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.2))),
            Text('18.5', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.2))),
            Text('25.0', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.2))),
            Text('30.0', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.2))),
            Text('35.0', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.2))),
          ],
        )
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
