import '../entities/length_unit.dart';

class ConvertLength {
  double call({
    required double value,
    required String fromAbbr,
    required String toAbbr,
  }) {
    final fromUnit = LengthUnit.fromAbbreviation(fromAbbr);
    final toUnit = LengthUnit.fromAbbreviation(toAbbr);

    if (fromUnit == toUnit) return value;

    // Convert value to meters first
    final meters = value * fromUnit.factorToMeter;

    // Convert meters to target unit
    final converted = meters / toUnit.factorToMeter;

    return converted;
  }
}
