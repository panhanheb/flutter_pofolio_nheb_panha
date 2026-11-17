import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../about/about_view.dart';
import '../chat/chat_view.dart';
import '../contact/contact_view.dart';
import '../experience/experience_view.dart';
import '../footer/footer_view.dart';
import '../header/header_view.dart';
import '../hero/hero_view.dart';
import '../projects/projects_view.dart';
import '../skills/skills_view.dart';
import '../writing/writing_view.dart';
import 'home_view_model.dart';

const headerHeight = 64.0;

/// Single scrolling page. Owns the scroll controller and section keys, reports
/// positions to [HomeViewModel] and performs the scrolls it requests.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scroll = ScrollController();
  final _keys = {for (final n in HomeViewModel.navItems) n.id: GlobalKey()};
  late final HomeViewModel _vm = context.read<HomeViewModel>();
  bool _reportQueued = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _vm.attachScroller(_scrollTo);
  }

  @override
  void dispose() {
    _vm.detachScroller();
    _scroll.dispose();
    super.dispose();
  }

  /// Throttled to once per frame.
  void _onScroll() {
    if (_reportQueued) return;
    _reportQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportQueued = false;
      if (!mounted || !_scroll.hasClients) return;
      final pos = _scroll.position;
      _vm.onScroll(
        offset: pos.pixels,
        atBottom: pos.maxScrollExtent > 0 && pos.pixels >= pos.maxScrollExtent - 2,
        sectionTops: {
          for (final e in _keys.entries)
            e.key: ?_topOf(e.value),
        },
      );
    });
  }

  double? _topOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero).dy;
  }

  void _scrollTo(String? id) {
    if (!_scroll.hasClients) return;
    double target = 0;
    if (id != null) {
      final top = _keys[id] == null ? null : _topOf(_keys[id]!);
      if (top == null) return;
      target = _scroll.offset + top - headerHeight;
    }
    target = target.clamp(0, _scroll.position.maxScrollExtent);
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pal.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HeroView(),
                  KeyedSubtree(key: _keys['about'], child: const AboutView()),
                  KeyedSubtree(key: _keys['experience'], child: const ExperienceView()),
                  KeyedSubtree(key: _keys['projects'], child: const ProjectsView()),
                  KeyedSubtree(key: _keys['skills'], child: const SkillsView()),
                  KeyedSubtree(key: _keys['writing'], child: const WritingView()),
                  KeyedSubtree(key: _keys['contact'], child: const ContactView()),
                  const FooterView(),
                ],
              ),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: HeaderView()),
          const Positioned(right: 24, bottom: 24, child: ChatView()),
        ],
      ),
    );
  }
}
