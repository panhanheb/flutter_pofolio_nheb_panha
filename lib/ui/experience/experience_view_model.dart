import '../../data/models/portfolio.dart';
import '../../data/repositories/portfolio_repository.dart';

class ExperienceViewModel {
  ExperienceViewModel(PortfolioRepository repository) : jobs = repository.jobs;

  /// Most recent first.
  final List<Job> jobs;

  bool isCurrent(int index) => index == 0;
  bool isLast(int index) => index == jobs.length - 1;
}
