import 'package:equatable/equatable.dart';

class BmiEntity extends Equatable {
  final double bmi;
  final String category;
  final String idealWeightRange;
  final List<String> healthTips;
  final String statusColorHex; // e.g., 'FF4CAF50' for Green, 'FFFF9800' for Orange, etc.

  const BmiEntity({
    required this.bmi,
    required this.category,
    required this.idealWeightRange,
    required this.healthTips,
    required this.statusColorHex,
  });

  @override
  List<Object?> get props => [
        bmi,
        category,
        idealWeightRange,
        healthTips,
        statusColorHex,
      ];
}
