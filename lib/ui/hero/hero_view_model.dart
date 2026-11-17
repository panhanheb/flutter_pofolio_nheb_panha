import '../../data/models/portfolio.dart';
import '../../data/repositories/portfolio_repository.dart';

class HeroViewModel {
  HeroViewModel(PortfolioRepository repository) : profile = repository.profile;
  final Profile profile;
}
