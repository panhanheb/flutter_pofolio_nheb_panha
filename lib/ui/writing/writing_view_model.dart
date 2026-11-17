import '../../data/models/portfolio.dart';
import '../../data/repositories/portfolio_repository.dart';

/// A rendered piece of an article body.
class ArticleBlock {
  const ArticleBlock.heading(this.text) : isHeading = true;
  const ArticleBlock.paragraph(this.text) : isHeading = false;
  final String text;
  final bool isHeading;
}

class WritingViewModel {
  WritingViewModel(PortfolioRepository repository)
      : posts = repository.posts,
        lead = repository.writingLead,
        author = repository.profile.name;

  final List<Post> posts;
  final String lead;
  final String author;

  /// Blocks are separated by a blank line; a line starting with `### ` is a
  /// sub-heading (a block can be `### Heading\nParagraph`).
  static List<ArticleBlock> parse(String content) {
    final blocks = <ArticleBlock>[];
    for (final block in content.split(RegExp(r'\n\s*\n'))) {
      for (final line in block.trim().split('\n')) {
        final text = line.trim();
        if (text.isEmpty) continue;
        blocks.add(text.startsWith('### ')
            ? ArticleBlock.heading(text.substring(4).trim())
            : ArticleBlock.paragraph(text));
      }
    }
    return blocks;
  }
}
