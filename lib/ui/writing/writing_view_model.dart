import 'package:flutter/foundation.dart';

import '../../data/models/portfolio.dart';
import '../../data/repositories/portfolio_repository.dart';

/// A rendered piece of an article body.
class ArticleBlock {
  const ArticleBlock.heading(this.text) : isHeading = true;
  const ArticleBlock.paragraph(this.text) : isHeading = false;
  final String text;
  final bool isHeading;
}

class WritingViewModel extends ChangeNotifier {
  WritingViewModel(this._repository)
      : _posts = _repository.posts,
        lead = _repository.writingLead,
        author = _repository.profile.name;

  final PortfolioRepository _repository;
  final String lead;
  final String author;
  List<Post> _posts;
  bool _disposed = false;

  /// Bundled posts at first, replaced by Supabase posts after [load].
  List<Post> get posts => _posts;

  Future<void> load() async {
    final loaded = await _repository.fetchPosts();
    if (_disposed || identical(loaded, _posts)) return;
    _posts = loaded;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

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
