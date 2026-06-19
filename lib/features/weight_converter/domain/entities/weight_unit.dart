import 'package:equatable/equatable.dart';

class WeightUnit extends Equatable {
  final String name;
  final String abbreviation;
  final double factorToKg;

  const WeightUnit({
    required this.name,
    required this.abbreviation,
    required this.factorToKg,
  });

  static const List<WeightUnit> units = [
    WeightUnit(name: 'Milligram', abbreviation: 'mg', factorToKg: 0.000001),
    WeightUnit(name: 'Gram', abbreviation: 'g', factorToKg: 0.001),
    WeightUnit(name: 'Kilogram', abbreviation: 'kg', factorToKg: 1.0),
    WeightUnit(name: 'Ounce', abbreviation: 'oz', factorToKg: 0.028349523125),
    WeightUnit(name: 'Pound', abbreviation: 'lb', factorToKg: 0.45359237),
    WeightUnit(name: 'Stone', abbreviation: 'st', factorToKg: 6.35029318),
    WeightUnit(name: 'Ton', abbreviation: 't', factorToKg: 1000.0),
  ];

  static WeightUnit fromAbbreviation(String abbr) {
    return units.firstWhere((u) => u.abbreviation == abbr, orElse: () => units[2]); // Default kg
  }

  @override
  List<Object?> get props => [name, abbreviation, factorToKg];
}
