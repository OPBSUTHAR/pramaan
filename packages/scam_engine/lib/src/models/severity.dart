/// How much weight a single detected signal carries when scoring a message.
///
/// The multiplier is applied to the rule's own [ScamSignal.weight] so that a
/// weak-but-relevant rule can never outrank a hard rule (like an OTP request).
enum Severity {
  info(multiplier: 0.35, label: 'Info'),
  low(multiplier: 0.55, label: 'Low'),
  medium(multiplier: 0.75, label: 'Medium'),
  high(multiplier: 1.0, label: 'High'),
  critical(multiplier: 1.25, label: 'Critical');

  const Severity({required this.multiplier, required this.label});

  /// Scaling factor applied to a rule's base weight.
  final double multiplier;

  /// Human readable label used by the UI.
  final String label;

  /// True when this severity on its own is enough to advise the user to stop.
  bool get isBlocking => this == Severity.critical;
}
