import '../entities/bmi_entity.dart';

class CalculateBmi {
  BmiEntity call({
    required double weight,
    required double height, // cm for metric, inches for imperial
    required String unitSystem,
  }) {
    double bmi = 0.0;
    double minIdealWeight = 0.0;
    double maxIdealWeight = 0.0;
    String idealWeightRange = '';

    if (unitSystem == 'metric') {
      final heightM = height / 100.0;
      if (heightM > 0) {
        bmi = weight / (heightM * heightM);
        minIdealWeight = 18.5 * (heightM * heightM);
        maxIdealWeight = 24.9 * (heightM * heightM);
      }
      idealWeightRange = '${minIdealWeight.toStringAsFixed(1)} - ${maxIdealWeight.toStringAsFixed(1)} kg';
    } else {
      if (height > 0) {
        bmi = (weight / (height * height)) * 703;
        minIdealWeight = (18.5 * (height * height)) / 703;
        maxIdealWeight = (24.9 * (height * height)) / 703;
      }
      idealWeightRange = '${minIdealWeight.toStringAsFixed(1)} - ${maxIdealWeight.toStringAsFixed(1)} lbs';
    }

    // Classify
    String category;
    String colorHex;
    List<String> tips;

    if (bmi < 18.5) {
      category = 'Underweight';
      colorHex = 'FFFA9F1B'; // Amber
      tips = [
        'Include nutrient-dense foods (nuts, dried fruits, lean proteins) in your meals.',
        'Eat smaller, more frequent meals throughout the day.',
        'Consider strength training to build muscle mass safely.',
      ];
    } else if (bmi >= 18.5 && bmi < 25.0) {
      category = 'Normal';
      colorHex = 'FF2ECC71'; // Green
      tips = [
        'Congratulations! You have a healthy weight. Keep up the good work!',
        'Participate in 150 minutes of moderate cardiovascular activity weekly.',
        'Stay hydrated and ensure you get 7-8 hours of sleep daily.',
      ];
    } else if (bmi >= 25.0 && bmi < 30.0) {
      category = 'Overweight';
      colorHex = 'FFE67E22'; // Orange
      tips = [
        'Incorporate more whole foods, fibers, and vegetables into your meals.',
        'Monitor portion sizes and limit intake of sugary or processed foods.',
        'Aim for at least 30-45 minutes of moderate physical activity daily.',
      ];
    } else {
      category = 'Obese';
      colorHex = 'FFE74C3C'; // Red
      tips = [
        'Consult a healthcare provider or dietitian for a personalized wellness plan.',
        'Focus on slow, sustainable changes rather than restrictive crash diets.',
        'Start with low-impact exercises like walking or swimming to protect joints.',
      ];
    }

    return BmiEntity(
      bmi: bmi,
      category: category,
      idealWeightRange: idealWeightRange,
      healthTips: tips,
      statusColorHex: colorHex,
    );
  }
}
