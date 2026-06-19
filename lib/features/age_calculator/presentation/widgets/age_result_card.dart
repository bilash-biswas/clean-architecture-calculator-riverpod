import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calculator/features/age_calculator/domain/entities/age_entity.dart';

class AgeResultCard extends StatelessWidget {
  final AgeEntity result;

  const AgeResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final numberFormat = NumberFormat('#,###');

    // Next Birthday calculations
    final daysUntilBirthday = result.nextBirthday.difference(DateTime.now()).inDays + 1;
    final birthdayMonthName = DateFormat('MMMM d').format(result.nextBirthday);
    final birthdayWeekday = DateFormat('EEEE').format(result.nextBirthday);

    // Calculate detailed breakdown
    final totalMonths = result.years * 12 + result.months;
    final totalWeeks = (result.totalDays / 7).toStringAsFixed(1);
    final totalHours = result.totalDays * 24;
    final totalMinutes = totalHours * 60;
    final totalSeconds = totalMinutes * 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Core Age Display Card
        Card(
          elevation: 0,
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
            child: Column(
              children: [
                Text(
                  'Your Current Age',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAgeUnit(context, result.years.toString(), 'Years'),
                    _buildUnitSeparator(context),
                    _buildAgeUnit(context, result.months.toString(), 'Months'),
                    _buildUnitSeparator(context),
                    _buildAgeUnit(context, result.days.toString(), 'Days'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total Days Lived: ${numberFormat.format(result.totalDays)} days',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Next Birthday Card with Circular Progress Countdown
        Card(
          elevation: 0,
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: CircularProgressIndicator(
                        value: daysUntilBirthday <= 0 ? 1.0 : (365 - daysUntilBirthday) / 365,
                        strokeWidth: 5,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? theme.colorScheme.secondary : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.cake_outlined,
                      color: isDark ? theme.colorScheme.secondary : theme.colorScheme.primary,
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Birthday',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        daysUntilBirthday <= 0
                            ? 'Today is your Birthday! 🎉'
                            : 'In $daysUntilBirthday ${daysUntilBirthday == 1 ? 'day' : 'days'}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'It will land on a $birthdayWeekday ($birthdayMonthName)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white30 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3. Detailed Stats Card - Grid Layout
        Card(
          elevation: 0,
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Detailed Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildStatGridItem(context, 'Total Months', numberFormat.format(totalMonths), Icons.calendar_view_month),
                    _buildStatGridItem(context, 'Total Weeks', totalWeeks, Icons.grid_3x3),
                    _buildStatGridItem(context, 'Total Days', numberFormat.format(result.totalDays), Icons.today),
                    _buildStatGridItem(context, 'Total Hours', numberFormat.format(totalHours), Icons.schedule),
                    _buildStatGridItem(context, 'Total Minutes', numberFormat.format(totalMinutes), Icons.timer),
                    _buildStatGridItem(context, 'Total Seconds', numberFormat.format(totalSeconds), Icons.hourglass_empty),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeUnit(BuildContext context, String value, String unit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 38,
            color: isDark ? Colors.white : theme.colorScheme.primary,
            fontWeight: FontWeight.w200,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitSeparator(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      ':',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w200,
        color: isDark ? Colors.white24 : Colors.black12,
      ),
    );
  }

  Widget _buildStatGridItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.01) : Colors.black.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white30 : Colors.black.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white.withValues(alpha: 0.8) : theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
