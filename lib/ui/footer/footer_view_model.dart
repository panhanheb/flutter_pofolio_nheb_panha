import '../../data/repositories/portfolio_repository.dart';

class FooterLink {
  const FooterLink(this.label, this.url);
  final String label;
  final String url;
}

class FooterViewModel {
  FooterViewModel(PortfolioRepository repository, {DateTime Function()? clock})
      : _name = repository.profile.name,
        links = [
          FooterLink('GitHub', repository.profile.githubUrl),
          FooterLink('Telegram', repository.profile.telegramUrl),
          FooterLink('Email', 'mailto:${repository.profile.email}'),
        ],
        _clock = clock ?? DateTime.now;

  final String _name;
  final DateTime Function() _clock;
  final List<FooterLink> links;

  String get copyright => '© ${_clock().year} $_name. All rights reserved.';
}
