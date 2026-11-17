// Unit tests for the view models: pure Dart logic, no widgets, no network.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panha_portfolio/data/models/messages.dart';
import 'package:panha_portfolio/data/repositories/chat_repository.dart';
import 'package:panha_portfolio/data/repositories/contact_repository.dart';
import 'package:panha_portfolio/data/repositories/portfolio_repository.dart';
import 'package:panha_portfolio/data/repositories/theme_repository.dart';
import 'package:panha_portfolio/data/services/api_client.dart';
import 'package:panha_portfolio/data/services/preferences_service.dart';
import 'package:panha_portfolio/ui/app/theme_view_model.dart';
import 'package:panha_portfolio/ui/chat/chat_view_model.dart';
import 'package:panha_portfolio/ui/contact/contact_view_model.dart';
import 'package:panha_portfolio/ui/footer/footer_view_model.dart';
import 'package:panha_portfolio/ui/home/home_view_model.dart';
import 'package:panha_portfolio/ui/projects/projects_view_model.dart';
import 'package:panha_portfolio/ui/writing/writing_view_model.dart';

// ---------------------------------------------------------------- Fakes

class FakeContactRepository implements ContactRepository {
  Object? error;
  final sent = <ContactMessage>[];

  @override
  Future<void> send(ContactMessage message) async {
    if (error != null) throw error!;
    sent.add(message);
  }
}

class FakeChatRepository implements ChatRepository {
  String reply = 'Hello';
  Object? error;
  final calls = <(String, List<ChatMessage>)>[];

  @override
  Future<String> ask(String prompt, List<ChatMessage> history) async {
    calls.add((prompt, history));
    if (error != null) throw error!;
    return reply;
  }
}

class MemoryPreferences implements PreferencesService {
  final values = <String, String>{};
  @override
  Future<String?> getString(String key) async => values[key];
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
}

const repo = PortfolioRepository();

void main() {
  group('ProjectsViewModel', () {
    test('categories are All plus distinct categories in data order', () {
      final vm = ProjectsViewModel(repo);
      expect(vm.categories, ['All', 'E-Commerce', 'Merchant App', 'Delivery App']);
    });

    test('filters by category', () {
      final vm = ProjectsViewModel(repo)..selectCategory('E-Commerce');
      expect(vm.visible.map((p) => p.title), ['RED ANT Express', 'E-Shop Native']);
    });

    test('searches title, category, description and tags case-insensitively', () {
      final vm = ProjectsViewModel(repo);
      vm.search('KOTLIN');
      expect(vm.visible.single.title, 'E-Shop Native');
      vm.search('driver');
      expect(vm.visible.single.title, 'RED ANT Driver');
      vm.search('merchant app');
      expect(vm.visible.single.title, 'RED ANT Merchant');
    });

    test('search and category combine; no match gives empty list', () {
      final vm = ProjectsViewModel(repo)
        ..selectCategory('Delivery App')
        ..search('swift');
      expect(vm.visible, isEmpty);
    });

    test('notifies only on change', () {
      final vm = ProjectsViewModel(repo);
      var n = 0;
      vm.addListener(() => n++);
      vm.selectCategory('All');
      vm.search('');
      expect(n, 0);
      vm.search('x');
      expect(n, 1);
    });
  });

  group('ContactViewModel', () {
    late FakeContactRepository fake;
    late ContactViewModel vm;
    setUp(() {
      fake = FakeContactRepository();
      vm = ContactViewModel(repo, fake);
    });

    test('requires all fields including topic', () async {
      final ok = await vm.submit(name: 'A', email: 'a@b.co', message: 'Hi');
      expect(ok, isFalse);
      expect(vm.status, ContactViewModel.missingFieldsMessage);
      expect(vm.success, isFalse);
      expect(fake.sent, isEmpty);
    });

    test('rejects an invalid email', () async {
      vm.selectType('General Inquiry');
      final ok = await vm.submit(name: 'A', email: 'not-an-email', message: 'Hi');
      expect(ok, isFalse);
      expect(vm.status, ContactViewModel.invalidEmailMessage);
    });

    test('sends trimmed values, shows success and resets the topic', () async {
      vm.selectType('Backend / API');
      final ok = await vm.submit(name: '  Ann ', email: ' ann@x.io ', message: ' Hello ');
      expect(ok, isTrue);
      expect(fake.sent.single.toJson(), {
        'name': 'Ann',
        'email': 'ann@x.io',
        'type': 'Backend / API',
        'message': 'Hello',
      });
      expect(vm.status, ContactViewModel.successMessage);
      expect(vm.success, isTrue);
      expect(vm.type, isNull);
      expect(vm.sending, isFalse);
    });

    test("shows the server's statusMessage on failure", () async {
      fake.error = ApiException('Message could not be delivered right now.', statusCode: 503);
      vm.selectType('General Inquiry');
      final ok = await vm.submit(name: 'A', email: 'a@b.co', message: 'Hi');
      expect(ok, isFalse);
      expect(vm.status, 'Message could not be delivered right now.');
      expect(vm.success, isFalse);
    });

    test('falls back to the email message when the server gives none', () async {
      fake.error = ApiException(null);
      vm.selectType('General Inquiry');
      await vm.submit(name: 'A', email: 'a@b.co', message: 'Hi');
      expect(vm.status, contains(repo.profile.email));
    });

    test('copied resets after the delay', () async {
      final done = vm.markCopied(resetAfter: const Duration(milliseconds: 10));
      expect(vm.copied, isTrue);
      await done;
      expect(vm.copied, isFalse);
    });
  });

  group('ChatViewModel', () {
    late FakeChatRepository fake;
    late ChatViewModel vm;
    setUp(() {
      fake = FakeChatRepository();
      vm = ChatViewModel(repo, fake);
    });

    test('toggle and close', () {
      vm.toggle();
      expect(vm.open, isTrue);
      vm.close();
      expect(vm.open, isFalse);
    });

    test('sends prompt with previous history and appends reply', () async {
      expect(vm.showQuickPrompts, isTrue);
      await vm.send(' Hi ');
      fake.reply = 'Second';
      await vm.send('Again');

      expect(fake.calls[0].$1, 'Hi');
      expect(fake.calls[0].$2, isEmpty);
      expect(fake.calls[1].$2.map((m) => m.text), ['Hi', 'Hello']);
      expect(vm.messages.map((m) => (m.fromUser, m.text)), [
        (true, 'Hi'),
        (false, 'Hello'),
        (true, 'Again'),
        (false, 'Second'),
      ]);
      expect(vm.busy, isFalse);
      expect(vm.showQuickPrompts, isFalse);
    });

    test('ignores empty prompts', () async {
      await vm.send('   ');
      expect(fake.calls, isEmpty);
      expect(vm.messages, isEmpty);
    });

    test('replies with the friendly error on failure', () async {
      fake.error = ApiException(null);
      await vm.send('Hi');
      expect(vm.messages.last.text, repo.chatError);
      expect(vm.messages.last.fromUser, isFalse);
    });

    test('history serialises in the /api/chat shape', () {
      expect(const ChatMessage(fromUser: false, text: 'x').toJson(), {
        'role': 'model',
        'parts': [
          {'text': 'x'},
        ],
      });
    });
  });

  group('HomeViewModel', () {
    test('scroll-spy picks the last section within the threshold', () {
      final vm = HomeViewModel();
      vm.onScroll(offset: 900, atBottom: false, sectionTops: {
        'about': -400,
        'experience': 120,
        'projects': 600,
      });
      expect(vm.scrolled, isTrue);
      expect(vm.activeSection, 'experience');
    });

    test('at the very bottom Contact is active', () {
      final vm = HomeViewModel();
      vm.onScroll(offset: 5000, atBottom: true, sectionTops: {'about': -3000});
      expect(vm.activeSection, 'contact');
    });

    test('at the top nothing is active and header is transparent', () {
      final vm = HomeViewModel();
      vm.onScroll(offset: 0, atBottom: false, sectionTops: {'about': 800});
      expect(vm.scrolled, isFalse);
      expect(vm.activeSection, isNull);
    });

    test('navigateTo closes the menu and calls the attached scroller', () {
      final vm = HomeViewModel();
      final targets = <String?>[];
      vm.attachScroller(targets.add);
      vm.toggleMenu();
      expect(vm.menuOpen, isTrue);
      vm.navigateTo('projects');
      vm.navigateTo(null);
      expect(vm.menuOpen, isFalse);
      expect(targets, ['projects', null]);
    });
  });

  group('ThemeViewModel', () {
    test('defaults to system, toggles and persists', () async {
      final prefs = MemoryPreferences();
      final vm = ThemeViewModel(ThemeRepository(prefs));
      await vm.load();
      expect(vm.mode, ThemeMode.system);

      await vm.toggle(Brightness.light);
      expect(vm.mode, ThemeMode.dark);
      expect(prefs.values['theme'], 'dark');

      final reloaded = ThemeViewModel(ThemeRepository(prefs));
      await reloaded.load();
      expect(reloaded.mode, ThemeMode.dark);
    });
  });

  group('WritingViewModel.parse', () {
    test('splits blocks and recognises ### headings inside a block', () {
      final blocks = WritingViewModel.parse('Intro line.\n\n### Title\nBody text.\n\nOutro.');
      expect(blocks.map((b) => (b.isHeading, b.text)), [
        (false, 'Intro line.'),
        (true, 'Title'),
        (false, 'Body text.'),
        (false, 'Outro.'),
      ]);
    });

    test('every bundled post has at least one sub-heading', () {
      for (final p in repo.posts) {
        expect(WritingViewModel.parse(p.content).where((b) => b.isHeading), isNotEmpty);
      }
    });
  });

  test('FooterViewModel builds copyright from the clock', () {
    final vm = FooterViewModel(repo, clock: () => DateTime(2031));
    expect(vm.copyright, '© 2031 ${repo.profile.name}. All rights reserved.');
    expect(vm.links.map((l) => l.label), ['GitHub', 'Telegram', 'Email']);
    expect(vm.links.last.url, 'mailto:${repo.profile.email}');
  });
}
