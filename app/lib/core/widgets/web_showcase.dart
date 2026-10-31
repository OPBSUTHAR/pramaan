import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/preview_controller.dart';
import '../theme/app_colors.dart';

/// Frames the app in a centred Android device when it is opened in a wide
/// browser window.
///
/// On a real phone, in a narrow browser window, and in widget tests this is a
/// no-op: the child is returned untouched. The frame only appears when the
/// platform is web and the viewport is at least 900 logical pixels wide, which
/// is exactly the case where a mobile-first layout would otherwise stretch
/// across a desktop monitor.
///
/// The chosen mode lives in [PreviewController] so it can be changed from the
/// pill under the frame, from the floating pill in full-width mode, or from
/// Settings.
class WebShowcase extends StatelessWidget {
  const WebShowcase({required this.child, super.key});

  final Widget child;

  /// Width at which the framed presentation takes over.
  static const double breakpoint = 900;

  static const Size _phone = Size(412, 892);
  static const Size _tablet = Size(834, 1112);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final wide = kIsWeb && media.size.width >= breakpoint;
    if (!wide) return child;

    final controller = PreviewScope.maybeOf(context);
    final mode = controller?.mode ?? PreviewMode.phone;
    void select(PreviewMode next) => controller?.setMode(next);

    if (mode == PreviewMode.full) {
      // Full width hides the frame. The way back to a framed view must stay
      // reachable even when the browser chrome hides (mobile/scroll), so we
      // keep a clearly labeled switch at BOTH the top and the bottom edge;
      // the phone icon is the most prominent of the three so it cannot be
      // missed.
      return Stack(
        children: [
          Positioned.fill(child: child),
          // Top, compact switch (visible when address bar is shown).
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: PreviewModeSwitch(
                  mode: mode,
                  onChanged: select,
                  compact: true,
                ),
              ),
            ),
          ),
          // Bottom, full switch (always shows all three labels).
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PreviewModeSwitch(mode: mode, onChanged: select),
              ),
            ),
          ),
        ],
      );
    }

    final size = mode == PreviewMode.tablet ? _tablet : _phone;

    return ColoredBox(
      color: AppColors.ink,
      child: Stack(
        children: [
          const Positioned.fill(child: _Backdrop()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _DeviceShell(
                          size: size,
                          child: MediaQuery(
                            data: media.copyWith(
                              size: size,
                              padding: EdgeInsets.zero,
                              viewPadding: EdgeInsets.zero,
                              viewInsets: EdgeInsets.zero,
                              systemGestureInsets: EdgeInsets.zero,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: PreviewModeSwitch(mode: mode, onChanged: select),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceShell extends StatelessWidget {
  const _DeviceShell({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const bezel = 12.0;
    final outerRadius = size.width >= 700 ? 42.0 : 48.0;

    return Container(
      width: size.width + bezel * 2,
      height: size.height + bezel * 2,
      padding: const EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF07090F),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(color: const Color(0xFF2C3554), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 70,
            spreadRadius: 2,
            offset: const Offset(0, 30),
          ),
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.1),
            blurRadius: 110,
            spreadRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(outerRadius - bezel),
        child: SizedBox(width: size.width, height: size.height, child: child),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.05,
            colors: [Color(0xFF17203A), Color(0xFF0B1020), Color(0xFF05070E)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Center(
          child: Container(
            width: 760,
            height: 760,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.saffron.withValues(alpha: 0.09),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented control for [PreviewMode].
///
/// Shown under the device frame, floating over the app in full-width mode, and
/// reused in Settings so the current presentation is always visible.
class PreviewModeSwitch extends StatelessWidget {
  const PreviewModeSwitch({
    required this.mode,
    required this.onChanged,
    this.compact = false,
    super.key,
  });

  final PreviewMode mode;
  final ValueChanged<PreviewMode> onChanged;

  /// Icon-only variant, used when the control floats over the app.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.inkCard.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.inkLine),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(
            context,
            PreviewMode.phone,
            Icons.smartphone,
            'display.phone',
          ),
          const SizedBox(width: 4),
          _segment(
            context,
            PreviewMode.tablet,
            Icons.tablet_mac,
            'display.tablet',
          ),
          const SizedBox(width: 4),
          _segment(
            context,
            PreviewMode.full,
            Icons.open_in_full,
            'display.full',
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    PreviewMode value,
    IconData icon,
    String labelKey,
  ) {
    final selected = mode == value;
    final label = context.t(labelKey);
    final foreground = selected ? AppColors.ink : AppColors.textSecondary;

    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 400),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: () => onChanged(value),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.saffron : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: foreground),
                if (!compact) ...[
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: foreground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
