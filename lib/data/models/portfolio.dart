import 'package:flutter/widgets.dart';

/// Owner details shown across the site.
class Profile {
  const Profile({
    required this.name,
    required this.role,
    required this.email,
    required this.githubUrl,
    required this.telegramUrl,
    required this.telegramHandle,
    required this.location,
    required this.timezone,
    required this.availability,
    required this.intro,
    required this.facts,
  });

  final String name;
  final String role;
  final String email;
  final String githubUrl;
  final String telegramUrl;
  final String telegramHandle;
  final String location;
  final String timezone;
  final String availability;
  final String intro;

  /// Hero facts row: (label, value).
  final List<(String, String)> facts;
}

class Service {
  const Service(this.icon, this.title, this.text);
  final IconData icon;
  final String title;
  final String text;
}

class Job {
  const Job({
    required this.period,
    required this.role,
    required this.company,
    required this.location,
    required this.type,
    required this.summary,
    required this.highlights,
    required this.tech,
  });
  final String period, role, company, location, type, summary;
  final List<String> highlights, tech;
}

class Project {
  const Project({
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.tags,
    this.demoUrl,
    this.sourceUrl,
  });
  final String title, category, description;
  final IconData icon;
  final List<String> tags;
  final String? demoUrl, sourceUrl;

  bool get hasDemo => _isLink(demoUrl);
  bool get hasSource => _isLink(sourceUrl);

  static bool _isLink(String? url) => url != null && url.startsWith('http');
}

class SkillGroup {
  const SkillGroup(this.icon, this.title, this.items);
  final IconData icon;
  final String title;

  /// (name, optional note).
  final List<(String, String?)> items;
}

class Post {
  const Post({
    required this.title,
    required this.category,
    required this.date,
    required this.readTime,
    required this.summary,
    required this.content,
    required this.tags,
  });
  final String title, category, date, readTime, summary, content;
  final List<String> tags;
}

/// Contact form topic: value sent to the API and label shown to the user.
class InquiryType {
  const InquiryType(this.value, this.label);
  final String value;
  final String label;
}

/// Chat quick prompt: chip label and the question it sends.
class QuickPrompt {
  const QuickPrompt(this.label, this.question);
  final String label;
  final String question;
}
