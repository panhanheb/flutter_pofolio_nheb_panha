import 'package:flutter/foundation.dart';

import '../../data/models/portfolio.dart';
import '../../data/repositories/portfolio_repository.dart';

/// Project search and category filter.
class ProjectsViewModel extends ChangeNotifier {
  ProjectsViewModel(PortfolioRepository repository)
      : _all = repository.projects,
        lead = repository.projectsLead;

  static const allCategory = 'All';

  final List<Project> _all;
  final String lead;

  String _query = '';
  String _category = allCategory;

  String get query => _query;
  String get category => _category;

  /// "All" plus the distinct categories, in data order.
  late final List<String> categories = [
    allCategory,
    ...{for (final p in _all) p.category},
  ];

  /// Projects matching the category and the query (title, category,
  /// description or tag; case-insensitive).
  List<Project> get visible {
    final q = _query.trim().toLowerCase();
    return _all.where((p) {
      if (_category != allCategory && p.category != _category) return false;
      if (q.isEmpty) return true;
      return p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  void search(String query) {
    if (query == _query) return;
    _query = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    if (category == _category) return;
    _category = category;
    notifyListeners();
  }
}
