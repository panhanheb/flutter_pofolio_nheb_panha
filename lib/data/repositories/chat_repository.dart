import '../models/messages.dart';
import '../services/api_client.dart';

/// Talks to POST /api/chat.
class ChatRepository {
  ChatRepository(this._api);
  final ApiClient _api;

  /// Returns the assistant's reply. Throws [ApiException] on failure.
  Future<String> ask(String prompt, List<ChatMessage> history) async {
    final data = await _api.postJson('/api/chat', {
      'prompt': prompt,
      'history': [for (final m in history) m.toJson()],
    });
    final text = data['responseText'];
    if (text is! String || text.trim().isEmpty) throw ApiException(null);
    return text;
  }
}
