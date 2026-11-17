import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'data/repositories/chat_repository.dart';
import 'data/repositories/contact_repository.dart';
import 'data/repositories/portfolio_repository.dart';
import 'data/repositories/theme_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/preferences_service.dart';
import 'data/services/supabase_service.dart';
import 'ui/app/app.dart';
import 'ui/app/theme_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();

  // Services → repositories.
  final api = ApiClient();
  final deps = AppDependencies(
    portfolio: PortfolioRepository(
      supabase: SupabaseService(SupabaseConfig.fromEnvironment()),
    ),
    chat: ChatRepository(api),
    contact: ContactRepository(api),
  );
  final theme = ThemeViewModel(ThemeRepository(PreferencesService()));
  await theme.load();

  runApp(PortfolioApp(dependencies: deps, themeViewModel: theme));
}
