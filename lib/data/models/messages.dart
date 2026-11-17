/// One chat turn, in the shape /api/chat expects for `history`.
class ChatMessage {
  const ChatMessage({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;

  Map<String, dynamic> toJson() => {
        'role': fromUser ? 'user' : 'model',
        'parts': [
          {'text': text},
        ],
      };
}

/// Body of POST /api/contact.
class ContactMessage {
  const ContactMessage({
    required this.name,
    required this.email,
    required this.type,
    required this.message,
  });
  final String name;
  final String email;
  final String type;
  final String message;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'type': type,
        'message': message,
      };
}
