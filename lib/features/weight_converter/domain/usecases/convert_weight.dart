import '../entities/weight_unit.dart';

class ConvertWeight {
  double call({
    required double value,
    required String fromAbbr,
    required String toAbbr,
  }) {
    final fromUnit = WeightUnit.fromAbbreviation(fromAbbr);
    final toUnit = WeightUnit.fromAbbreviation(toAbbr);

    if (fromUnit == toUnit) return value;

    // Convert value to kg first
    final kg = value * fromUnit.factorToKg;

    // Convert kg to target unit
    final converted = kg / toUnit.factorToKg;

    return converted;
  }
}
