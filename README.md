# Nheb Panha — portfolio (Flutter)

Flutter Web (also Android/iOS) port of the Nuxt portfolio. Spec: `role_flutter.md`.

## Architecture (MVVM)

```
lib/
  main.dart                 composition root: builds services → repositories → app
  core/                     shared, feature-agnostic UI
    theme/app_theme.dart    Palette tokens, buildTheme(), breakpoints
    widgets/                Section, SectionHeading, AppCard, AppButton, Reveal, ...
  data/                     Model layer
    models/                 immutable data classes (Profile, Project, Post, ChatMessage, ...)
    sources/                bundled site content (edit portfolio_content.dart to change text)
    services/               ApiClient (HTTP /api/*), PreferencesService (local storage)
    repositories/           the only data entry point for view models
  ui/                       one folder per feature
    app/                    PortfolioApp (providers, MaterialApp), ThemeViewModel
    home/                   HomeView (page shell, scrolling) + HomeViewModel (nav, scroll-spy)
    <feature>/              <feature>_view.dart + <feature>_view_model.dart
```

Rules:

- **Views** render and forward user events; they read their view model with
  `context.watch` / `context.read` and never import `data/sources` or `data/services`.
- **View models** hold state and logic (`ChangeNotifier` when state changes,
  a plain class for read-only sections). They don't build widgets.
- **Repositories** wrap services/sources. Swap them in tests with fakes
  (see `test/view_models_test.dart`).
- Wiring lives in `lib/ui/app/app.dart` (`MultiProvider`).

## Commands

```
flutter run -d chrome                 # develop (hot reload with r)
flutter analyze && flutter test       # checks: view model unit tests + overflow test
flutter build web --release           # → build/web
npx wrangler dev                      # site + /api/* locally on :8787
npx wrangler deploy                   # publish to Cloudflare
```

Stop `wrangler dev` before running `flutter build web` on Windows: it holds files
in `build/web` open and the build silently ends up incomplete.
