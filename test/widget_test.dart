import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theuniversedecides/main.dart';
import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

void main() {
  testWidgets('coin screen uses the random service', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final service = _FakeRandomOrgService([
      [1],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-java',
                avatarUrl: '',
                name: 'Vitor Hugo',
              ),
            ),
          ),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.tap(find.text('Lançar a moeda'));
    await tester.pumpAndSettle();

    expect(find.text('COROA'), findsWidgets);
    expect(service.requests, [(1, 0, 1)]);
  });

  testWidgets('dice screen requests the selected dice configuration', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [2, 3],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-java',
                avatarUrl: '',
                name: 'Vitor Hugo',
              ),
            ),
          ),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.tap(find.text('Dados'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rolar os dados'));
    await tester.pumpAndSettle();

    expect(find.text('Total: 5'), findsOneWidget);
    expect(service.requests, [(2, 1, 20)]);
  });

  testWidgets('list screen picks one item through the random service', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [1],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-java',
                avatarUrl: '',
                name: 'Vitor Hugo',
              ),
            ),
          ),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.tap(find.text('Listas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Chá');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Café');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher por mim'));
    await tester.pumpAndSettle();

    expect(find.text('Café'), findsWidgets);
    expect(service.requests, [(1, 0, 1)]);
  });

  testWidgets('about tab loads profile and main screen has no top bar', (
    WidgetTester tester,
  ) async {
    final randomService = _FakeRandomOrgService(const []);
    final githubService = _FakeGitHubProfileService(
      const GitHubProfile(
        login: 'vitorhugo-java',
        avatarUrl: '',
        name: 'Vitor Hugo',
        bio: 'Developer',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => randomService),
          githubProfileServiceProvider.overrideWith((ref) => githubService),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sobre mim'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Vitor Hugo'), findsOneWidget);
    expect(find.text('@vitorhugo-java'), findsOneWidget);
    expect(githubService.usernames, ['vitorhugo-java']);
  });
}

class _FakeRandomOrgService extends RandomOrgService {
  _FakeRandomOrgService(List<List<int>> responses)
    : _responses = Queue.of(responses),
      super(
        client: MockClient((_) async => http.Response('', 200)),
        random: math.Random(1),
      );

  final Queue<List<int>> _responses;
  final List<(int, int, int)> requests = [];

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async {
    requests.add((count, min, max));
    return _responses.isEmpty ? const [] : _responses.removeFirst();
  }

  @override
  void dispose() {}
}

class _FakeGitHubProfileService extends GitHubProfileService {
  _FakeGitHubProfileService(this.profile)
    : super(client: MockClient((_) async => http.Response('', 200)));

  final GitHubProfile profile;
  final List<String> usernames = [];

  @override
  Future<GitHubProfile> fetchProfile({required String username}) async {
    usernames.add(username);
    return profile;
  }

  @override
  void dispose() {}
}
