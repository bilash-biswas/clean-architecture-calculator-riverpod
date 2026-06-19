import 'package:equatable/equatable.dart';

class LengthUnit extends Equatable {
  final String name;
  final String abbreviation;
  final double factorToMeter;

  const LengthUnit({
    required this.name,
    required this.abbreviation,
    required this.factorToMeter,
  });

  static const List<LengthUnit> units = [
    LengthUnit(name: 'Millimeter', abbreviation: 'mm', factorToMeter: 0.001),
    LengthUnit(name: 'Centimeter', abbreviation: 'cm', factorToMeter: 0.01),
    LengthUnit(name: 'Meter', abbreviation: 'm', factorToMeter: 1.0),
    LengthUnit(name: 'Kilometer', abbreviation: 'km', factorToMeter: 1000.0),
    LengthUnit(name: 'Inch', abbreviation: 'in', factorToMeter: 0.0254),
    LengthUnit(name: 'Foot', abbreviation: 'ft', factorToMeter: 0.3048),
    LengthUnit(name: 'Yard', abbreviation: 'yd', factorToMeter: 0.9144),
    LengthUnit(name: 'Mile', abbreviation: 'mi', factorToMeter: 1609.344),
  ];

  static LengthUnit fromAbbreviation(String abbr) {
    return units.firstWhere((u) => u.abbreviation == abbr, orElse: () => units[2]); // Default meter
  }

  @override
  List<Object?> get props => [name, abbreviation, factorToMeter];
}
