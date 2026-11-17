import 'package:flutter/foundation.dart';

import '../../data/models/messages.dart';
import '../../data/models/portfolio.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/services/api_client.dart';

/// Contact form state, validation and submission.
class ContactViewModel extends ChangeNotifier {
  ContactViewModel(PortfolioRepository portfolio, this._repository)
      : profile = portfolio.profile,
        lead = portfolio.contactLead,
        inquiryTypes = portfolio.inquiryTypes;

  final ContactRepository _repository;
  final Profile profile;
  final String lead;
  final List<InquiryType> inquiryTypes;

  static const nameMax = 120;
  static const emailMax = 200;
  static const messageMax = 5000;
  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static const successMessage = "Thanks! Your message has been sent. I'll reply soon.";
  static const missingFieldsMessage = 'Please fill in all fields.';
  static const invalidEmailMessage = 'Please provide a valid email address.';
  String get fallbackError => 'Something went wrong. Please email me at ${profile.email}.';

  String? _type;
  bool _sending = false;
  String? _status;
  bool _success = false;
  bool _copied = false;

  String? get type => _type;
  bool get sending => _sending;

  /// Message for the status box; null hides it.
  String? get status => _status;
  bool get success => _success;

  /// True for 2 seconds after the email was copied.
  bool get copied => _copied;

  void selectType(String? value) {
    _type = value;
    notifyListeners();
  }

  /// Validates and sends. Returns true on success so the view can clear its
  /// text fields.
  Future<bool> submit({
    required String name,
    required String email,
    required String message,
  }) async {
    if (_sending) return false;
    name = name.trim();
    email = email.trim();
    message = message.trim();

    final error = name.isEmpty || email.isEmpty || message.isEmpty || _type == null
        ? missingFieldsMessage
        : (!_emailRe.hasMatch(email) ? invalidEmailMessage : null);
    if (error != null) {
      _setStatus(error, success: false);
      return false;
    }

    _sending = true;
    _status = null;
    notifyListeners();
    try {
      await _repository.send(ContactMessage(
        name: name.substring(0, name.length.clamp(0, nameMax)),
        email: email.substring(0, email.length.clamp(0, emailMax)),
        type: _type!,
        message: message.substring(0, message.length.clamp(0, messageMax)),
      ));
      _type = null;
      _sending = false;
      _setStatus(successMessage, success: true);
      return true;
    } on ApiException catch (e) {
      _sending = false;
      _setStatus(e.message ?? fallbackError, success: false);
    } catch (_) {
      _sending = false;
      _setStatus(fallbackError, success: false);
    }
    return false;
  }

  /// Call after the view copied the email to the clipboard.
  Future<void> markCopied({Duration resetAfter = const Duration(seconds: 2)}) async {
    _copied = true;
    notifyListeners();
    await Future<void>.delayed(resetAfter);
    if (_disposed) return;
    _copied = false;
    notifyListeners();
  }

  void _setStatus(String message, {required bool success}) {
    _status = message;
    _success = success;
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
