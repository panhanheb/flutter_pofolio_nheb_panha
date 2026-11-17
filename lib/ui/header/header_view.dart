import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../app/theme_view_model.dart';
import '../home/home_view.dart';
import '../home/home_view_model.dart';

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lg = context.isLg;
    final vm = context.watch<HomeViewModel>();
    final name = context.read<PortfolioRepository>().profile.name;
    final menuOpen = vm.menuOpen && !lg;
    final solid = vm.scrolled || menuOpen;
    final active = vm.activeSection;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: solid ? pal.bg.withValues(alpha: 0.94) : pal.bg.withValues(alpha: 0),
        border: Border(
          bottom: BorderSide(color: solid ? pal.border : pal.border.withValues(alpha: 0)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: headerHeight,
            child: PageContainer(
              child: Row(
                children: [
                  if (lg)
                    _Brand(name: name, onTap: () => vm.navigateTo(null))
                  else
                    Flexible(child: _Brand(name: name, onTap: () => vm.navigateTo(null))),
                  if (lg)
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              for (final n in HomeViewModel.navItems)
                                _NavLink(
                                  label: n.label,
                                  active: active == n.id,
                                  onTap: () => vm.navigateTo(n.id),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  AppIconButton(
                    icon: Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    tooltip: 'Toggle theme',
                    onPressed: () =>
                        context.read<ThemeViewModel>().toggle(Theme.of(context).brightness),
                  ),
                  if (context.isSm) ...[
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'Contact me',
                      compact: true,
                      onPressed: () => vm.navigateTo('contact'),
                    ),
                  ],
                  if (!lg) ...[
                    const SizedBox(width: 8),
                    AppIconButton(
                      icon: menuOpen ? Icons.close : Icons.menu,
                      tooltip: menuOpen ? 'Close menu' : 'Open menu',
                      onPressed: vm.toggleMenu,
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: menuOpen
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: pal.border)),
                    ),
                    child: PageContainer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final n in HomeViewModel.navItems)
                              _MobileLink(
                                label: n.label,
                                active: active == n.id,
                                onTap: () => vm.navigateTo(n.id),
                              ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Contact me',
                              expand: true,
                              onPressed: () => vm.navigateTo('contact'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}


class _Brand extends StatelessWidget {
  const _Brand({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Semantics(
      button: true,
      label: '$name, back to top',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: pal.border),
                ),
                child: Image.asset('assets/logo.png', excludeFromSemantics: true),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: pal.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Semantics(
      link: true,
      selected: widget.active,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.active || _hover ? pal.text : pal.muted,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileLink extends StatelessWidget {
  const _MobileLink({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Semantics(
      link: true,
      selected: active,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: active ? pal.accent : pal.text,
            ),
          ),
        ),
      ),
    );
  }
}
