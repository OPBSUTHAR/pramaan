import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// How the app is presented inside a desktop browser.
enum PreviewMode {
  /// 412 x 892 logical pixels - a modern Android phone.
  phone,

  /// 834 x 1112 logical pixels - a small Android tablet.
  tablet,

  /// No frame at all; the app fills the window.
  full,
}

/// Frames the app in a centred Android device when it is opened in a wide
/// browser window.
///
/// On a real phone, in a narrow browser window, and in widget tests this is a
/// no-op: the child is returned untouched. The frame only appears when the
/// platform is web and the viewport is at least 900 logical pixels wide, which
/// is exactly the case where a mobile-first layout would otherwise stretch
/// across a desktop monitor.
class WebShowcase extends StatefulWidget {
  const WebShowcase({required this.child, super.key});

  final Widget child;

  /// Width at which the framed presentation takes over.
  static const double breakpoint = 900;

  @override
  State<WebShowcase> createState() => _WebShowcaseState();
}

class _WebShowcaseState extends State<WebShowcase> {
  PreviewMode _mode = PreviewMode.phone;

  static const Size _phone = Size(412, 892);
  static const Size _tablet = Size(834, 1112);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final framed = kIsWeb && media.size.width >= WebShowcase.breakpoint;

    if (!framed || _mode == PreviewMode.full) {
      return widget.child;
    }

    final size = _mode == PreviewMode.tablet ? _tablet : _phone;

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
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: _ModeSwitch(
                      mode: _mode,
                      onChanged: (mode) => setState(() => _mode = mode),
                    ),
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

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final PreviewMode mode;
  final ValueChanged<PreviewMode> onChanged;

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
          _segment(PreviewMode.phone, Icons.smartphone, 'Phone'),
          const SizedBox(width: 4),
          _segment(PreviewMode.tablet, Icons.tablet_mac, 'Tablet'),
          const SizedBox(width: 4),
          _segment(PreviewMode.full, Icons.open_in_full, 'Full'),
        ],
      ),
    );
  }

  Widget _segment(PreviewMode value, IconData icon, String label) {
    final selected = mode == value;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label preview',
      child: GestureDetector(
        onTap: () => onChanged(value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.saffron : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.ink : AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: selected ? AppColors.ink : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
