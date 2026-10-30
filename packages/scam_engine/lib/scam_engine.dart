/// Pramaan's on-device scam detection engine.
///
/// Pure Dart, zero dependencies, zero network access. Drop it into a Flutter
/// app, a CLI, or a serverless function and it behaves identically.
///
/// ```dart
/// import 'package:scam_engine/scam_engine.dart';
///
/// final ScamScanner scanner = ScamScanner();
/// final ScanReport report = scanner.scan('Dear customer, your KYC expires today...');
/// print('${report.score} ${report.level.labelEn}');
/// ```
library;

export 'src/context/scan_context.dart';
export 'src/data/known_domains.dart';
export 'src/data/psp_handles.dart';
export 'src/data/scam_templates.dart';
export 'src/matching/template_matcher.dart';
export 'src/models/risk_level.dart';
export 'src/models/scan_report.dart';
export 'src/models/scam_signal.dart';
export 'src/models/severity.dart';
export 'src/models/upi_intent.dart';
export 'src/rules/rule_catalog.dart';
export 'src/rules/scam_rule.dart';
export 'src/scanner.dart';
export 'src/scoring/risk_scorer.dart';
export 'src/text/normalizer.dart';
export 'src/text/similarity.dart';
export 'src/upi/upi_link_parser.dart';
export 'src/upi/vpa.dart';
