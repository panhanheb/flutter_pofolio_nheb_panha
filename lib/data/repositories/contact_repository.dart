import '../models/messages.dart';
import '../services/api_client.dart';

/// Talks to POST /api/contact.
class ContactRepository {
  ContactRepository(this._api);
  final ApiClient _api;

  /// Throws [ApiException] carrying the server's statusMessage on failure.
  Future<void> send(ContactMessage message) => _api.postJson('/api/contact', message.toJson());
}
