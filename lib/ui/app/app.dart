import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../about/about_view_model.dart';
import '../chat/chat_view_model.dart';
import '../contact/contact_view_model.dart';
import '../experience/experience_view_model.dart';
import '../footer/footer_view_model.dart';
import '../hero/hero_view_model.dart';
import '../home/home_view.dart';
import '../home/home_view_model.dart';
import '../projects/projects_view_model.dart';
import '../skills/skills_view_model.dart';
import '../writing/writing_view_model.dart';
import 'theme_view_model.dart';

/// Repositories the view models are built from.
class AppDependencies {
  const AppDependencies({
    required this.portfolio,
    required this.chat,
    required this.contact,
  });
  final PortfolioRepository portfolio;
  final ChatRepository chat;
  final ContactRepository contact;
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key, required this.dependencies, required this.themeViewModel});
  final AppDependencies dependencies;
  final ThemeViewModel themeViewModel;

  @override
  Widget build(BuildContext context) {
    final repo = dependencies.portfolio;
    return MultiProvider(
      providers: [
        // Repositories.
        Provider.value(value: repo),
        Provider.value(value: dependencies.chat),
        Provider.value(value: dependencies.contact),
        // App-wide view models.
        ChangeNotifierProvider.value(value: themeViewModel),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        // Section view models.
        Provider(create: (_) => HeroViewModel(repo)),
        Provider(create: (_) => AboutViewModel(repo)),
        Provider(create: (_) => ExperienceViewModel(repo)),
        ChangeNotifierProvider(create: (_) => ProjectsViewModel(repo)),
        Provider(create: (_) => SkillsViewModel(repo)),
        Provider(create: (_) => WritingViewModel(repo)),
        ChangeNotifierProvider(create: (_) => ContactViewModel(repo, dependencies.contact)),
        Provider(create: (_) => FooterViewModel(repo)),
        ChangeNotifierProvider(create: (_) => ChatViewModel(repo, dependencies.chat)),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, theme, _) => MaterialApp(
          title: '${repo.profile.name} — ${repo.profile.role}',
          debugShowCheckedModeBanner: false,
          themeMode: theme.mode,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: const HomeView(),
        ),
      ),
    );
  }
}
