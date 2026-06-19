import 'package:equatable/equatable.dart';

class AgeEntity extends Equatable {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final DateTime nextBirthday;

  const AgeEntity({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.nextBirthday,
  });

  @override
  List<Object?> get props => [years, months, days, totalDays, nextBirthday];

  @override
  String toString() =>
      '$years years, $months months, $days days ($totalDays total days)';
}
