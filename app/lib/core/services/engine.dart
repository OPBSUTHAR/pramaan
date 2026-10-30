import 'package:scam_engine/scam_engine.dart';

/// One scanner for the whole app: the rule set and the Scam DNA corpus are
/// built once at startup and reused for every check.
abstract final class Engine {
  static final ScamScanner scanner = ScamScanner();

  static ScanReport scan(String input) => scanner.scan(input);

  static UpiIntent inspectUpi(String input) => scanner.inspectUpi(input);

  static int get ruleCount => scanner.rules.length;

  static int get templateCount => scanner.templateCount;
}
