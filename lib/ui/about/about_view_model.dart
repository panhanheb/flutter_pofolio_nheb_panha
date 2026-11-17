import '../../data/models/portfolio.dart';
import '../../data/repositories/portfolio_repository.dart';

class AboutViewModel {
  AboutViewModel(PortfolioRepository repository)
      : paragraphs = repository.aboutParagraphs,
        coreStack = repository.coreStack,
        services = repository.services;

  final List<String> paragraphs;
  final List<String> coreStack;
  final List<Service> services;
}
