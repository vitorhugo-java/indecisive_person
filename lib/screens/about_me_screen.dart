import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

class AboutMeScreen extends ConsumerWidget {
  const AboutMeScreen({super.key});

  static const _githubUsername = 'vitorhugo-java';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(githubProfileProvider(_githubUsername));

    return MysticScreenScaffold(
      title: 'Sobre mim',
      subtitle:
          'Um cantinho com o perfil do criador, puxando o avatar direto da API do GitHub.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: profileAsync.when(
            data: (profile) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(avatarUrl: profile.avatarUrl),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name ?? 'Vitor Hugo',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '@${profile.login}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (profile.bio case final bio?) ...[
                  const SizedBox(height: 20),
                  Text(
                    bio,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1327),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.profileUrl ?? 'https://github.com/${profile.login}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nao foi possivel carregar o perfil agora.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$error', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(githubProfileProvider(_githubUsername));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.isNotEmpty;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFF1A1327),
                  child: Icon(Icons.person, size: 44),
                ),
              )
            : const ColoredBox(
                color: Color(0xFF1A1327),
                child: Icon(Icons.person, size: 44),
              ),
      ),
    );
  }
}
