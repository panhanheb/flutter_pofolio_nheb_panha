import 'package:flutter/foundation.dart';

import '../../data/models/messages.dart';
import '../../data/models/portfolio.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/portfolio_repository.dart';

/// Floating AI chat: open state, conversation and sending.
class ChatViewModel extends ChangeNotifier {
  ChatViewModel(PortfolioRepository portfolio, this._repository)
      : greeting = portfolio.chatGreeting,
        errorMessage = portfolio.chatError,
        quickPrompts = portfolio.chatQuickPrompts;

  final ChatRepository _repository;
  final String greeting;
  final String errorMessage;
  final List<QuickPrompt> quickPrompts;

  static const maxPromptLength = 1000;

  bool _open = false;
  bool _busy = false;
  final List<ChatMessage> _messages = [];
  bool _disposed = false;

  bool get open => _open;
  bool get busy => _busy;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Quick prompts show until the first question is asked.
  bool get showQuickPrompts => _messages.isEmpty && !_busy;

  void toggle() {
    _open = !_open;
    _notify();
  }

  void close() {
    if (!_open) return;
    _open = false;
    _notify();
  }

  /// Sends [text]; on any failure the assistant replies with [errorMessage].
  Future<void> send(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty || _busy) return;
    final history = List<ChatMessage>.of(_messages);
    _messages.add(ChatMessage(fromUser: true, text: prompt));
    _busy = true;
    _notify();

    String reply;
    try {
      reply = await _repository.ask(
        prompt.length > maxPromptLength ? prompt.substring(0, maxPromptLength) : prompt,
        history,
      );
    } catch (_) {
      reply = errorMessage;
    }
    if (_disposed) return;
    _messages.add(ChatMessage(fromUser: false, text: reply));
    _busy = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
