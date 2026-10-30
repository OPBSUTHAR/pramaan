import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/l10n.dart';
import 'core/services/history_store.dart';
import 'core/theme/app_theme.dart';
import 'root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final locale = LocaleController();
  final history = HistoryStore();
  await Future.wait([locale.restore(), history.load()]);

  runApp(PramaanApp(locale: locale, history: history));
}

class PramaanApp extends StatelessWidget {
  const PramaanApp({
    required this.locale,
    required this.history,
    super.key,
  });

  final LocaleController locale;
  final HistoryStore history;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: locale,
      child: HistoryScope(
        store: history,
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
              home: const RootShell(),
            );
          },
        ),
      ),
    );
  }
}
