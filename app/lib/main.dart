import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/l10n/l10n.dart';
import 'core/services/history_store.dart';
import 'core/services/preview_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/web_showcase.dart';
import 'root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final locale = LocaleController();
  final history = HistoryStore();
  final preview = PreviewController();
  try {
    final prefs = await SharedPreferences.getInstance();
    debugPrint(
      'PROBE keys=${prefs.getKeys()} raw=${prefs.getString('pramaan.language')}',
    );
  } catch (error) {
    debugPrint('PROBE error=$error');
  }
  await Future.wait([locale.restore(), history.load(), preview.restore()]);
  debugPrint(
    'PROBE lang=${locale.isHindi} mode=${preview.mode.name} '
    'history=${history.items.length}',
  );

  runApp(PramaanApp(locale: locale, history: history, preview: preview));

  Future<void>.delayed(const Duration(seconds: 3), () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    debugPrint(
      'PROBE2 keys=${prefs.getKeys()} raw=${prefs.getString('pramaan.language')}',
    );
    await prefs.setString('pramaan.probe', DateTime.now().toIso8601String());
    debugPrint('PROBE3 wrote probe');
  });
}

class PramaanApp extends StatelessWidget {
  const PramaanApp({
    required this.locale,
    required this.history,
    this.preview,
    super.key,
  });

  final LocaleController locale;
  final HistoryStore history;
  final PreviewController? preview;

  @override
  Widget build(BuildContext context) {
    final previewController = preview ?? PreviewController();

    return AppScope(
      controller: locale,
      child: HistoryScope(
        store: history,
        child: PreviewScope(
          controller: previewController,
          child: AnimatedBuilder(
            animation: locale,
            builder: (context, _) {
              return MaterialApp(
                title: 'Pramaan',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.dark(),
                locale: locale.locale,
                supportedLocales: const [Locale('en'), Locale('hi')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                // On a wide browser window the mobile layout is shown inside a
                // centred Android device instead of stretching across the page.
                builder: (context, child) =>
                    WebShowcase(child: child ?? const SizedBox.shrink()),
                home: const RootShell(),
              );
            },
          ),
        ),
      ),
    );
  }
}
