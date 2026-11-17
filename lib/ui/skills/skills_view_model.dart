import '../../data/models/portfolio.dart';
import '../../data/repositories/portfolio_repository.dart';

class SkillsViewModel {
  SkillsViewModel(PortfolioRepository repository)
      : groups = repository.skillGroups,
        practices = repository.practices;

  final List<SkillGroup> groups;

  /// "How I work" statements.
  final List<String> practices;
}
