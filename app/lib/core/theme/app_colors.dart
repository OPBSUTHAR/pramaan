import 'package:flutter/material.dart';
import 'package:scam_engine/scam_engine.dart' show RiskLevel, Severity;

/// Pramaan's palette. Deep indigo night sky + a warm saffron signal accent,
/// so the app feels Indian without falling back to flag clichés.
abstract final class AppColors {
  static const Color ink = Color(0xFF0B1020);
  static const Color inkSoft = Color(0xFF141A2E);
  static const Color inkCard = Color(0xFF1A2138);
  static const Color inkLine = Color(0xFF2A3352);

  static const Color saffron = Color(0xFFFF9F1C);
  static const Color saffronDeep = Color(0xFFE07B00);
  static const Color mint = Color(0xFF2BD9A3);
  static const Color sky = Color(0xFF5AA9FF);
  static const Color lilac = Color(0xFF9B8CFF);

  static const Color safe = Color(0xFF2BD9A3);
  static const Color caution = Color(0xFFFFD166);
  static const Color suspicious = Color(0xFFFF9F1C);
  static const Color dangerous = Color(0xFFFF6B4A);
  static const Color critical = Color(0xFFFF3B5C);

  static const Color textPrimary = Color(0xFFF4F6FF);
  static const Color textSecondary = Color(0xFFA8B0CC);
  static const Color textMuted = Color(0xFF6F7899);

  static Color forRisk(RiskLevel level) => switch (level) {
    RiskLevel.safe => safe,
    RiskLevel.caution => caution,
    RiskLevel.suspicious => suspicious,
    RiskLevel.dangerous => dangerous,
    RiskLevel.critical => critical,
  };

  static Color forSeverity(Severity severity) => switch (severity) {
    Severity.info => sky,
    Severity.low => caution,
    Severity.medium => suspicious,
    Severity.high => dangerous,
    Severity.critical => critical,
  };
}
