import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _githubApiBaseUrl = 'https://api.github.com/users/';
const _githubTimeout = Duration(seconds: 6);

final githubProfileServiceProvider = Provider<GitHubProfileService>((ref) {
  final service = GitHubProfileService();
  ref.onDispose(service.dispose);
  return service;
});

final githubProfileProvider = FutureProvider.family<GitHubProfile, String>((
  ref,
  username,
) {
  final service = ref.read(githubProfileServiceProvider);
  return service.fetchProfile(username: username);
});

class GitHubProfile {
  const GitHubProfile({
    required this.login,
    required this.avatarUrl,
    this.name,
    this.bio,
    this.profileUrl,
  });

  final String login;
  final String avatarUrl;
  final String? name;
  final String? bio;
  final String? profileUrl;
}

class GitHubProfileService {
  GitHubProfileService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<GitHubProfile> fetchProfile({required String username}) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw ArgumentError.value(username, 'username', 'must not be empty');
    }

    final uri = Uri.parse('$_githubApiBaseUrl$trimmedUsername');
    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'User-Agent': 'the-universe-decides',
          },
        )
        .timeout(_githubTimeout);

    if (response.statusCode == 404) {
      throw StateError('GitHub user not found: $trimmedUsername');
    }

    if (response.statusCode != 200) {
      throw StateError('GitHub API request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid GitHub API payload');
    }

    final login = decoded['login'];
    final avatarUrl = decoded['avatar_url'];
    if (login is! String || login.isEmpty) {
      throw const FormatException('Missing GitHub login');
    }
    if (avatarUrl is! String) {
      throw const FormatException('Missing GitHub avatar URL');
    }

    final name = decoded['name'];
    final bio = decoded['bio'];
    final profileUrl = decoded['html_url'];

    return GitHubProfile(
      login: login,
      avatarUrl: avatarUrl,
      name: name is String && name.isNotEmpty ? name : null,
      bio: bio is String && bio.isNotEmpty ? bio : null,
      profileUrl: profileUrl is String && profileUrl.isNotEmpty
          ? profileUrl
          : null,
    );
  }

  void dispose() {
    _client.close();
  }
}
