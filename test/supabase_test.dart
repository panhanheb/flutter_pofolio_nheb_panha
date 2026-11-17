// Supabase loading: request shape, row mapping, and fallback to bundled content.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:panha_portfolio/data/repositories/portfolio_repository.dart';
import 'package:panha_portfolio/data/services/supabase_service.dart';
import 'package:panha_portfolio/ui/projects/projects_view_model.dart';
import 'package:panha_portfolio/ui/writing/writing_view_model.dart';

const config = SupabaseConfig(url: 'https://demo.supabase.co', anonKey: 'anon-key');

PortfolioRepository repoWith(MockClientHandler handler, {SupabaseConfig cfg = config}) =>
    PortfolioRepository(supabase: SupabaseService(cfg, httpClient: MockClient(handler)));

http.Response jsonResponse(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

void main() {
  const bundled = PortfolioRepository();

  test('sends anon key headers and ordered select to /rest/v1/projects', () async {
    late http.Request seen;
    final repo = repoWith((req) async {
      seen = req;
      return jsonResponse([
        {'title': 'A', 'category': 'Web', 'description': 'd', 'icon': 'web', 'tags': ['Nuxt']},
      ]);
    });
    await repo.fetchProjects();
    expect(seen.method, 'GET');
    expect(seen.url.path, '/rest/v1/projects');
    expect(seen.url.queryParameters['select'], '*');
    expect(seen.url.queryParameters['order'], 'sort_order.asc,created_at.asc');
    expect(seen.headers['apikey'], 'anon-key');
    expect(seen.headers['Authorization'], 'Bearer anon-key');
  });

  test('maps project rows, icons, tags (both shapes) and links', () async {
    final repo = repoWith((_) async => jsonResponse([
          {
            'title': 'Remote One',
            'category': 'Web',
            'description': 'From Supabase',
            'icon': 'storefront',
            'tags': ['Nuxt', 'Vue 3'],
            'demo_url': 'https://demo.example',
            'source_url': null,
          },
          {
            'title': 'Remote Two',
            'category': 'Mobile',
            'description': 'Old tag shape',
            'icon': 'unknown-key',
            'tags': [
              {'name': 'Flutter', 'icon': 'logos:flutter'},
            ],
          },
          {'title': 'Broken row without category'},
        ]));
    final projects = await repo.fetchProjects();
    expect(projects.map((p) => p.title), ['Remote One', 'Remote Two']);
    expect(projects[0].icon, Icons.storefront_outlined);
    expect(projects[0].tags, ['Nuxt', 'Vue 3']);
    expect(projects[0].hasDemo, isTrue);
    expect(projects[0].hasSource, isFalse);
    expect(projects[1].icon, Icons.code);
    expect(projects[1].tags, ['Flutter']);
  });

  test('maps blog post rows', () async {
    final repo = repoWith((_) async => jsonResponse([
          {
            'title': 'Post',
            'category': 'Notes',
            'summary': 's',
            'content': 'Intro\n\n### H\nBody',
            'read_time': '3 min read',
            'published_at': 'Nov 2026',
            'tags': ['Dart'],
          },
        ]));
    final post = (await repo.fetchPosts()).single;
    expect(post.date, 'Nov 2026');
    expect(post.readTime, '3 min read');
    expect(WritingViewModel.parse(post.content).where((b) => b.isHeading).single.text, 'H');
  });

  group('falls back to bundled content', () {
    test('when the anon key is missing (no request made)', () async {
      var calls = 0;
      final repo = repoWith((_) async {
        calls++;
        return jsonResponse([]);
      }, cfg: const SupabaseConfig(url: 'https://demo.supabase.co', anonKey: ''));
      expect(await repo.fetchProjects(), bundled.projects);
      expect(calls, 0);
    });

    test('on HTTP errors (e.g. table missing → 404, bad key → 401)', () async {
      final repo = repoWith((_) async => jsonResponse({'message': 'nope'}, 404));
      expect(await repo.fetchProjects(), bundled.projects);
      expect(await repo.fetchPosts(), bundled.posts);
    });

    test('on network failure', () async {
      final repo = repoWith((_) async => throw http.ClientException('offline'));
      expect(await repo.fetchPosts(), bundled.posts);
    });

    test('when the table is empty', () async {
      final repo = repoWith((_) async => jsonResponse([]));
      expect(await repo.fetchProjects(), bundled.projects);
    });
  });

  test('ProjectsViewModel shows bundled first, then remote after load', () async {
    final repo = repoWith((_) async => jsonResponse([
          {'title': 'Remote', 'category': 'Web', 'description': 'd', 'tags': []},
        ]));
    final vm = ProjectsViewModel(repo)..selectCategory('Merchant App');
    expect(vm.visible.single.title, 'RED ANT Merchant');

    var notified = 0;
    vm.addListener(() => notified++);
    await vm.load();
    expect(notified, 1);
    // The selected category no longer exists, so the filter resets to All.
    expect(vm.category, ProjectsViewModel.allCategory);
    expect(vm.categories, ['All', 'Web']);
    expect(vm.visible.single.title, 'Remote');
  });

  test('WritingViewModel keeps bundled posts when Supabase fails', () async {
    final vm = WritingViewModel(repoWith((_) async => jsonResponse({}, 500)));
    var notified = 0;
    vm.addListener(() => notified++);
    await vm.load();
    expect(notified, 0);
    expect(vm.posts, bundled.posts);
  });
}
