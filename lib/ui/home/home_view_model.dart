import 'package:flutter/foundation.dart';

/// A page section the header can link to.
class NavItem {
  const NavItem(this.id, this.label);
  final String id;
  final String label;
}

/// Page-level navigation state: header style, active link (scroll-spy) and
/// the mobile menu. Scrolling itself is done by the view, which registers a
/// handler with [attachScroller].
class HomeViewModel extends ChangeNotifier {
  static const navItems = <NavItem>[
    NavItem('about', 'About'),
    NavItem('experience', 'Experience'),
    NavItem('projects', 'Projects'),
    NavItem('skills', 'Skills'),
    NavItem('writing', 'Writing'),
    NavItem('contact', 'Contact'),
  ];

  /// Header turns solid after this many pixels.
  static const solidHeaderOffset = 8.0;

  /// A section is active once its top is within this distance of the viewport top.
  static const spyThreshold = 140.0;

  bool _scrolled = false;
  String? _activeSection;
  bool _menuOpen = false;
  void Function(String? id)? _scroller;

  bool get scrolled => _scrolled;
  String? get activeSection => _activeSection;
  bool get menuOpen => _menuOpen;

  void attachScroller(void Function(String? id) scroller) => _scroller = scroller;
  void detachScroller() => _scroller = null;

  /// Called by the view on scroll with the offset and each section's top
  /// (relative to the viewport), in page order.
  void onScroll({
    required double offset,
    required bool atBottom,
    required Map<String, double> sectionTops,
  }) {
    final scrolled = offset > solidHeaderOffset;
    String? active;
    if (atBottom) {
      active = navItems.last.id;
    } else {
      for (final item in navItems) {
        final top = sectionTops[item.id];
        if (top != null && top <= spyThreshold) active = item.id;
      }
    }
    if (scrolled == _scrolled && active == _activeSection) return;
    _scrolled = scrolled;
    _activeSection = active;
    notifyListeners();
  }

  void toggleMenu() {
    _menuOpen = !_menuOpen;
    notifyListeners();
  }

  void closeMenu() {
    if (!_menuOpen) return;
    _menuOpen = false;
    notifyListeners();
  }

  /// Scrolls to section [id], or to the top when null. Closes the menu.
  void navigateTo(String? id) {
    closeMenu();
    _scroller?.call(id);
  }

  @override
  void dispose() {
    _scroller = null;
    super.dispose();
  }
}
