import 'package:flutter/material.dart' show IconData, Icons;

import '../models/portfolio.dart';
import '../services/supabase_service.dart';
import '../sources/portfolio_content.dart' as content;

/// Site content.
///
/// Profile, skills and section copy come from the bundled source. Projects
/// and posts are loaded from Supabase (`projects`, `blog_posts`) when it is
/// configured; any failure or empty table falls back to the bundled copies,
/// so the site always renders.
class PortfolioRepository {
  const PortfolioRepository({this.supabase});

  final SupabaseService? supabase;

  // ---------------------------------------------------------------- bundled

  Profile get profile => content.profile;

  List<String> get aboutParagraphs => content.aboutParagraphs;
  List<String> get coreStack => content.coreStack;
  List<Service> get services => content.services;
  List<String> get practices => content.practices;

  List<Job> get jobs => content.jobs;
  List<SkillGroup> get skillGroups => content.skillGroups;

  /// Bundled projects and posts: shown immediately and used as the fallback.
  List<Project> get projects => content.projects;
  List<Post> get posts => content.posts;

  String get projectsLead => content.projectsLead;
  String get writingLead => content.writingLead;
  String get contactLead => content.contactLead;

  List<InquiryType> get inquiryTypes => content.inquiryTypes;

  String get chatGreeting => content.chatGreeting;
  String get chatError => content.chatError;
  List<QuickPrompt> get chatQuickPrompts => content.chatQuickPrompts;

  // ---------------------------------------------------------------- remote

  /// Projects from Supabase, or the bundled list on failure / empty table.
  Future<List<Project>> fetchProjects() async {
    final rows = await _rows('projects', order: 'sort_order.asc,created_at.asc');
    final remote = rows?.map(projectFromRow).nonNulls.toList();
    return remote == null || remote.isEmpty ? projects : remote;
  }

  /// Posts from Supabase, or the bundled list on failure / empty table.
  Future<List<Post>> fetchPosts() async {
    final rows = await _rows('blog_posts', order: 'sort_order.asc,created_at.desc');
    final remote = rows?.map(postFromRow).nonNulls.toList();
    return remote == null || remote.isEmpty ? posts : remote;
  }

  Future<List<Map<String, dynamic>>?> _rows(String table, {String? order}) async {
    final supabase = this.supabase;
    if (supabase == null || !supabase.config.isConfigured) return null;
    try {
      return await supabase.select(table, order: order);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------- mapping

  static const _icons = <String, IconData>{
    'shopping_bag': Icons.shopping_bag_outlined,
    'storefront': Icons.storefront_outlined,
    'delivery': Icons.delivery_dining_outlined,
    'phone': Icons.phone_iphone_outlined,
    'web': Icons.web_outlined,
    'dns': Icons.dns_outlined,
    'storage': Icons.storage_outlined,
    'code': Icons.code,
  };

  /// Maps a `projects` row; returns null for rows missing required fields.
  static Project? projectFromRow(Map<String, dynamic> row) {
    final title = _text(row['title']);
    final category = _text(row['category']);
    final description = _text(row['description']);
    if (title == null || category == null || description == null) return null;
    return Project(
      title: title,
      category: category,
      description: description,
      icon: _icons[_text(row['icon'])] ?? Icons.code,
      tags: _tags(row['tags']),
      demoUrl: _text(row['demo_url']),
      sourceUrl: _text(row['source_url']),
    );
  }

  /// Maps a `blog_posts` row; returns null for rows missing required fields.
  static Post? postFromRow(Map<String, dynamic> row) {
    final title = _text(row['title']);
    final category = _text(row['category']);
    final summary = _text(row['summary']);
    final body = _text(row['content']);
    if (title == null || category == null || summary == null || body == null) return null;
    return Post(
      title: title,
      category: category,
      date: _text(row['published_at']) ?? '',
      readTime: _text(row['read_time']) ?? '',
      summary: summary,
      content: body,
      tags: _tags(row['tags']),
    );
  }

  static String? _text(Object? v) =>
      v is String && v.trim().isNotEmpty ? v.trim() : null;

  /// Accepts `["Flutter"]` or the older `[{"name": "Flutter", ...}]` shape.
  static List<String> _tags(Object? v) {
    if (v is! List) return const [];
    return [
      for (final t in v)
        if (t is String && t.trim().isNotEmpty)
          t.trim()
        else if (t is Map && t['name'] is String)
          (t['name'] as String).trim(),
    ];
  }
}
