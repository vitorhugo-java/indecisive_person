import 'package:flutter/material.dart';

const _appName = 'The Universe Decides';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4BFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101223),
        useMaterial3: true,
      ),
      home: const ReleasePrepPage(),
    );
  }
}

class ReleasePrepPage extends StatelessWidget {
  const ReleasePrepPage({super.key});

  static const _featureHighlights = <_HighlightItem>[
    _HighlightItem(
      icon: Icons.flip_camera_android_rounded,
      title: 'Animated Coin Flip',
      description:
          'A cinematic toss that prefers Random.org true randomness and falls back to local math when offline.',
    ),
    _HighlightItem(
      icon: Icons.casino_rounded,
      title: 'RPG Dice Roller',
      description:
          'Support for d4, d6, d8, d10, d12, d20 and d100 with configurable roll counts for quick decisions.',
    ),
    _HighlightItem(
      icon: Icons.playlist_add_check_circle_rounded,
      title: 'Custom List Picker',
      description:
          'Turn any list of choices into one decisive winner so the universe can make the final call.',
    ),
  ];

  static const _releaseChecklist = <_HighlightItem>[
    _HighlightItem(
      icon: Icons.photo_size_select_large_rounded,
      title: 'Polished icon and assets',
      description:
          'Branded launcher assets are now in place and ready to be iterated on with App Icon Forge or flutter_launcher_icons.',
    ),
    _HighlightItem(
      icon: Icons.badge_rounded,
      title: 'Unique package name',
      description:
          'Android and iOS are aligned on com.hugo.theuniversedecides so store submissions share one consistent identity.',
    ),
    _HighlightItem(
      icon: Icons.key_rounded,
      title: 'Android release keystore',
      description:
          'Release signing now reads from android/key.properties so the production keystore can be stored outside source control.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B4BFF), Color(0xFF00A7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _appName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A pre-release dashboard that captures the app vision, confirms store-ready identity, and keeps the last launch blockers visible.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Core experiences',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ..._featureHighlights.map(_buildCard),
              const SizedBox(height: 28),
              Text(
                'Release readiness',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ..._releaseChecklist.map(_buildCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_HighlightItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: const Color(0xFF191D33),
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF5B4BFF).withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: const Color(0xFFB8B2FF)),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              item.description,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightItem {
  const _HighlightItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
