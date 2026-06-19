import 'package:calculator/features/age_calculator/domain/entities/age_entity.dart';

class CalculateAge {
  AgeEntity call({required DateTime birthDate, DateTime? asOfDate}) {
    final today = asOfDate ?? DateTime.now();

    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final totalDays = today.difference(birthDate).inDays;

    DateTime nextBirthdayThisYear = DateTime(
      today.year,
      birthDate.month,
      birthDate.day,
    );
    if (nextBirthdayThisYear.isBefore(today)) {
      nextBirthdayThisYear = DateTime(
        today.year + 1,
        birthDate.month,
        birthDate.day,
      );
    }

    return AgeEntity(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      nextBirthday: nextBirthdayThisYear,
    );
  }
}
