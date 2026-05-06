import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _appTitle = 'The Universe Decides';
/// Random.org plain integer endpoint used with fixed formatting parameters so
/// each request returns one base-10 integer per line.
const _randomOrgBaseUrl = 'https://www.random.org/integers/';
const _randomOrgTimeout = Duration(seconds: 6);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.randomOrgService});

  final RandomOrgService? randomOrgService;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF090611),
        cardTheme: CardThemeData(
          color: const Color(0xFF151021),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.22),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF120C1C),
          indicatorColor: colorScheme.primary.withOpacity(0.22),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final isSelected = states.contains(MaterialState.selected);
            return TextStyle(
              color: isSelected
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF20172F),
          contentTextStyle: TextStyle(color: colorScheme.onSurface),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF171124),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.18),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
          ),
        ),
      ),
      home: UniverseDecidesApp(randomOrgService: randomOrgService),
    );
  }
}

class UniverseDecidesApp extends StatefulWidget {
  const UniverseDecidesApp({super.key, this.randomOrgService});

  final RandomOrgService? randomOrgService;

  @override
  State<UniverseDecidesApp> createState() => _UniverseDecidesAppState();
}

class _UniverseDecidesAppState extends State<UniverseDecidesApp> {
  late final RandomOrgService _randomOrgService;
  late final bool _ownsRandomOrgService;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _ownsRandomOrgService = widget.randomOrgService == null;
    _randomOrgService = widget.randomOrgService ?? RandomOrgService();
  }

  @override
  void dispose() {
    if (_ownsRandomOrgService) {
      _randomOrgService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_appTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            CoinFlipScreen(randomOrgService: _randomOrgService),
            DiceRollerScreen(randomOrgService: _randomOrgService),
            ListPickerScreen(randomOrgService: _randomOrgService),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.brightness_3_outlined),
            selectedIcon: Icon(Icons.brightness_2),
            label: 'Moeda',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: 'Dados',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Listas',
          ),
        ],
      ),
    );
  }
}

class RandomOrgService {
  RandomOrgService({http.Client? client, math.Random? random})
    : _client = client ?? http.Client(),
      _random = random ?? math.Random();

  final http.Client _client;
  final math.Random _random;

  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async {
    if (count <= 0 || max < min) {
      return const [];
    }

    final fallback = List<int>.generate(
      count,
      (_) => min + _random.nextInt(max - min + 1),
    );

    final uri = Uri.parse(_randomOrgBaseUrl).replace(
      queryParameters: {
        'num': '$count',
        'min': '$min',
        'max': '$max',
        'col': '1',
        'base': '10',
        'format': 'plain',
        'rnd': 'new',
      },
    );

    try {
      // Keep the wait short so the UI can fall back quickly on slow networks.
      final response = await _client.get(uri).timeout(_randomOrgTimeout);
      if (response.statusCode != 200) {
        return fallback;
      }

      final values = response.body
          .trim()
          .split(RegExp(r'\s+'))
          .where((value) => value.isNotEmpty)
          .map(int.tryParse)
          .whereType<int>()
          .toList();

      if (values.length != count) {
        // Unexpected payloads should feel the same as offline mode to callers.
        return fallback;
      }

      return values;
    } on TimeoutException {
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  void dispose() {
    _client.close();
  }
}

class CoinFlipScreen extends StatefulWidget {
  const CoinFlipScreen({super.key, required this.randomOrgService});

  final RandomOrgService randomOrgService;

  @override
  State<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _flipCoin() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final animation = _controller.forward(from: 0);
    final values = await widget.randomOrgService.fetchIntegers(
      count: 1,
      min: 0,
      max: 1,
    );
    final result = values.isEmpty ? 0 : values.first;

    await animation;
    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultLabel = switch (_result) {
      0 => 'CARA',
      1 => 'COROA',
      _ => 'Entregue a decisão ao universo',
    };

    return _MysticScreenScaffold(
      title: 'Moeda',
      subtitle:
          'Uma moeda encantada que consulta o Random.org e cai de volta no acaso local quando necessário.',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final spin = _isLoading
                              ? _controller.value * math.pi * 8
                              : (_result ?? 0) == 1
                              ? math.pi
                              : 0.0;
                          final showingFront =
                              (spin % (math.pi * 2)) < math.pi;
                          final faceValue = _isLoading
                              ? (showingFront ? 0 : 1)
                              : (_result ?? 0);

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateX(_isLoading
                                  ? math.sin(_controller.value * math.pi) * 0.18
                                  : 0.0)
                              ..rotateY(spin),
                            child: _CoinFace(value: faceValue),
                          );
                        },
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            key: ValueKey(resultLabel),
                            children: [
                              Text(
                                resultLabel,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _result == null
                                    ? 'Toque para descobrir o veredito.'
                                    : 'O universo escolheu o seu lado.',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _flipCoin,
                    icon: const Icon(Icons.cyclone),
                    label: const Text('Lançar a moeda'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCara = value == 0;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isCara
              ? const [Color(0xFFFCE38A), Color(0xFFF9B44C)]
              : const [Color(0xFFE3D7FF), Color(0xFF8B7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
        border: Border.all(color: Colors.white24, width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCara ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              size: 44,
              color: Colors.black.withOpacity(0.75),
            ),
            const SizedBox(height: 12),
            Text(
              isCara ? 'CARA' : 'COROA',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.black.withOpacity(0.82),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key, required this.randomOrgService});

  final RandomOrgService randomOrgService;

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  static const _availableSides = [4, 6, 8, 10, 12, 20, 100];

  int _diceCount = 1;
  int _selectedSides = 20;
  bool _isLoading = false;
  List<int> _results = const [];

  Future<void> _rollDice() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await widget.randomOrgService.fetchIntegers(
      count: _diceCount,
      min: 1,
      max: _selectedSides,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _results.fold<int>(0, (sum, value) => sum + value);
    final theme = Theme.of(context);

    return _MysticScreenScaffold(
      title: 'Dados',
      subtitle:
          'Role seus dados de RPG com múltiplos lados e deixe o destino somar o resultado final.',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantidade de dados',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: List.generate(
                      5,
                      (index) => ButtonSegment<int>(
                        value: index + 1,
                        label: Text('${index + 1}'),
                      ),
                    ),
                    selected: {_diceCount},
                    onSelectionChanged: (selection) {
                      setState(() => _diceCount = selection.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lados do dado',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableSides
                        .map(
                          (sides) => ChoiceChip(
                            label: Text('d$sides'),
                            selected: _selectedSides == sides,
                            onSelected: (_) {
                              setState(() => _selectedSides = sides);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _rollDice,
                    icon: const Icon(Icons.casino),
                    label: const Text('Rolar os dados'),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _results.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1327),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Escolha a combinação e role para ver cada valor e a soma final.',
                            ),
                          )
                        : Column(
                            key: ValueKey(_results.join(',')),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resultados',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _results.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 1.35,
                                    ),
                                itemBuilder: (context, index) {
                                  final value = _results[index];
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primaryContainer,
                                          theme.colorScheme.secondaryContainer,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$value',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Total: $total',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListPickerScreen extends StatefulWidget {
  const ListPickerScreen({super.key, required this.randomOrgService});

  final RandomOrgService randomOrgService;

  @override
  State<ListPickerScreen> createState() => _ListPickerScreenState();
}

class _ListPickerScreenState extends State<ListPickerScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _items = [];
  bool _isLoading = false;
  int? _selectedIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      return;
    }

    setState(() {
      _items.add(value);
      _controller.clear();
      _selectedIndex = null;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_selectedIndex == index) {
        _selectedIndex = null;
      } else if (_selectedIndex != null && _selectedIndex! > index) {
        _selectedIndex = _selectedIndex! - 1;
      }
    });
  }

  Future<void> _pickItem() async {
    if (_items.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedIndex = null;
    });

    final values = await widget.randomOrgService.fetchIntegers(
      count: 1,
      min: 0,
      max: _items.length - 1,
    );
    final chosenIndex = values.isEmpty ? 0 : values.first;

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = chosenIndex;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _MysticScreenScaffold(
      title: 'Listas',
      subtitle:
          'Escreva possibilidades, convide o universo e destaque um único destino para a sua próxima decisão.',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addItem(),
                          decoration: const InputDecoration(
                            labelText: 'Adicionar opção',
                            hintText: 'Ex.: Viajar, dormir, pedir pizza...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _addItem,
                        child: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: (_items.isEmpty || _isLoading) ? null : _pickItem,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Escolher por mim'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: CircularProgressIndicator(),
                          )
                        : _items.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1327),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Adicione itens à lista para deixar a escolha nas mãos do universo.',
                            ),
                          )
                        : Column(
                            key: ValueKey('${_items.length}-${_selectedIndex ?? -1}'),
                            children: [
                              if (_selectedIndex != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3E2D73),
                                        Color(0xFF7A4FFF),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Escolhido pelo universo',
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _items[_selectedIndex!],
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _items.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final isSelected = _selectedIndex == index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: isSelected
                                          ? theme.colorScheme.primaryContainer
                                          : const Color(0xFF171124),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline
                                                  .withOpacity(0.15),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.surfaceVariant,
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text(
                                        _items[index],
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? theme.colorScheme.onPrimaryContainer
                                              : null,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () => _removeItem(index),
                                        icon: const Icon(Icons.close),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MysticScreenScaffold extends StatelessWidget {
  const _MysticScreenScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF090611), Color(0xFF12091E), Color(0xFF090611)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1D55), Color(0xFF120C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
