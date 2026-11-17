// Renders the whole app at many sizes in light and dark, opens the mobile
// menu, every project dialog, every article and the chat panel, and fails on
// any "overflowed" layout error, reporting the lib/...dart:line it came from.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panha_portfolio/core/theme/app_theme.dart';
import 'package:panha_portfolio/data/repositories/chat_repository.dart';
import 'package:panha_portfolio/data/repositories/contact_repository.dart';
import 'package:panha_portfolio/data/repositories/portfolio_repository.dart';
import 'package:panha_portfolio/data/repositories/theme_repository.dart';
import 'package:panha_portfolio/data/services/api_client.dart';
import 'package:panha_portfolio/data/services/preferences_service.dart';
import 'package:panha_portfolio/ui/app/app.dart';
import 'package:panha_portfolio/ui/app/theme_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sizes = <Size>[
  Size(320, 568),
  Size(360, 740),
  Size(390, 844),
  Size(640, 900),
  Size(768, 1024),
  Size(1024, 768),
  Size(1280, 800),
  Size(1440, 900),
];

final _locRe = RegExp(r'lib/[\w/]+\.dart:\d+(:\d+)?');

void main() {
  setUpAll(() {
    useWebFonts = false;
    SharedPreferences.setMockInitialValues({});
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in sizes) {
      final name = '${mode.name} ${size.width.toInt()}x${size.height.toInt()}';
      testWidgets('no overflow: $name', (tester) async {
        final overflows = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          final text = details.toString();
          if (text.contains('overflowed')) {
            final locs = _locRe.allMatches(text).map((m) => m.group(0)).toSet();
            overflows.add('${details.exceptionAsString().split('\n').first} '
                'at ${locs.isEmpty ? '(unknown)' : locs.join(', ')}');
          } else {
            previous?.call(details);
          }
        };
        addTearDown(() => FlutterError.onError = previous);

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(mode));
        await _settle(tester);

        // Scroll through the whole page so every Reveal runs.
        final scrollable = find.byType(Scrollable).first;
        for (var i = 0; i < 40; i++) {
          await tester.drag(scrollable, const Offset(0, -600), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 50));
        }
        await _settle(tester);

        // Mobile menu.
        if (size.width < Bp.lg) {
          await tester.tap(find.byTooltip('Open menu'), warnIfMissed: false);
          await _settle(tester);
          expect(find.byTooltip('Close menu'), findsOneWidget);
          await tester.tap(find.byTooltip('Close menu'), warnIfMissed: false);
          await _settle(tester);
        }

        // Every project dialog.
        for (final p in repo.projects) {
          final title = find.text(p.title).first;
          await _center(tester, title);
          await _settle(tester);
          await tester.tap(title, warnIfMissed: false);
          await _settle(tester);
          expect(find.byType(Dialog), findsOneWidget, reason: 'dialog for ${p.title}');
          await tester.tap(find.byTooltip('Close').last, warnIfMissed: false);
          await _settle(tester);
        }

        // Every article.
        for (final post in repo.posts) {
          final title = find.text(post.title).first;
          await _center(tester, title);
          await _settle(tester);
          await tester.tap(title, warnIfMissed: false);
          await _settle(tester);
          expect(find.byType(Dialog), findsOneWidget, reason: 'reader for ${post.title}');
          expect(find.text('By ${repo.profile.name}'), findsOneWidget);
          await tester.tap(find.byTooltip('Close').last, warnIfMissed: false);
          await _settle(tester);
        }

        // Chat panel.
        await tester.tap(find.byTooltip('Chat with an AI assistant'), warnIfMissed: false);
        await _settle(tester);
        expect(find.text('Ask about Panha'), findsOneWidget);
        await tester.tap(find.byTooltip('Close chat').first, warnIfMissed: false);
        await _settle(tester);

        expect(overflows, isEmpty, reason: overflows.join('\n'));
      });
    }
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5));
}

/// Scroll [f] to the middle of the viewport (clear of the fixed header).
Future<void> _center(WidgetTester tester, Finder f) async {
  await tester.runAsync(() async {});
  final ctx = tester.element(f);
  final done = Scrollable.ensureVisible(ctx, alignment: 0.5);
  await tester.pumpAndSettle();
  await done;
}

const repo = PortfolioRepository();

Widget _app(ThemeMode mode) {
  final api = ApiClient();
  return PortfolioApp(
    dependencies: AppDependencies(
      portfolio: repo,
      chat: ChatRepository(api),
      contact: ContactRepository(api),
    ),
    themeViewModel: ThemeViewModel(ThemeRepository(PreferencesService()), initialMode: mode),
  );
}
