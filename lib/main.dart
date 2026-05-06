import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _appTitle = 'The Universe Decides';

/// Random.org plain integer endpoint used with fixed formatting parameters so
/// each request returns one base-10 integer per line.
const _randomOrgBaseUrl = 'https://www.random.org/integers/';
const _randomOrgTimeout = Duration(seconds: 6);
const _unset = Object();

final randomOrgServiceProvider = Provider<RandomOrgService>((ref) {
  final service = RandomOrgService();
  ref.onDispose(service.dispose);
  return service;
});

final navigationIndexProvider = StateProvider<int>((ref) => 0);

final coinFlipProvider =
    StateNotifierProvider<CoinFlipController, CoinFlipState>((ref) {
      return CoinFlipController(ref.read(randomOrgServiceProvider));
    });

final diceRollProvider =
    StateNotifierProvider<DiceRollController, DiceRollState>((ref) {
      return DiceRollController(ref.read(randomOrgServiceProvider));
    });

final listPickerProvider =
    StateNotifierProvider<ListPickerController, ListPickerState>((ref) {
      return ListPickerController(ref.read(randomOrgServiceProvider));
    });

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.overrides = const <Override>[]});

  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
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
        home: const UniverseDecidesApp(),
      ),
    );
  }
}

class UniverseDecidesApp extends ConsumerWidget {
  const UniverseDecidesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(_appTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: const [
            CoinFlipScreen(),
            DiceRollerScreen(),
            ListPickerScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
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

class CoinFlipState {
  const CoinFlipState({this.result, this.isLoading = false});

  final int? result;
  final bool isLoading;

  CoinFlipState copyWith({Object? result = _unset, bool? isLoading}) {
    return CoinFlipState(
      result: identical(result, _unset) ? this.result : result as int?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CoinFlipController extends StateNotifier<CoinFlipState> {
  CoinFlipController(this._randomOrgService) : super(const CoinFlipState());

  final RandomOrgService _randomOrgService;

  Future<void> flip() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final values = await _randomOrgService.fetchIntegers(count: 1, min: 0, max: 1);
    state = state.copyWith(
      isLoading: false,
      result: values.isEmpty ? 0 : values.first,
    );
  }
}

class DiceRollState {
  const DiceRollState({
    this.diceCount = 1,
    this.selectedSides = 20,
    this.isLoading = false,
    this.results = const [],
  });

  final int diceCount;
  final int selectedSides;
  final bool isLoading;
  final List<int> results;

  DiceRollState copyWith({
    int? diceCount,
    int? selectedSides,
    bool? isLoading,
    List<int>? results,
  }) {
    return DiceRollState(
      diceCount: diceCount ?? this.diceCount,
      selectedSides: selectedSides ?? this.selectedSides,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
    );
  }
}

class DiceRollController extends StateNotifier<DiceRollState> {
  DiceRollController(this._randomOrgService) : super(const DiceRollState());

  final RandomOrgService _randomOrgService;

  void setDiceCount(int value) {
    state = state.copyWith(diceCount: value);
  }

  void setSelectedSides(int value) {
    state = state.copyWith(selectedSides: value);
  }

  Future<void> roll() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final results = await _randomOrgService.fetchIntegers(
      count: state.diceCount,
      min: 1,
      max: state.selectedSides,
    );
    state = state.copyWith(isLoading: false, results: results);
  }
}

class ListPickerState {
  const ListPickerState({
    this.items = const [],
    this.isLoading = false,
    this.selectedIndex,
  });

  final List<String> items;
  final bool isLoading;
  final int? selectedIndex;

  ListPickerState copyWith({
    List<String>? items,
    bool? isLoading,
    Object? selectedIndex = _unset,
  }) {
    return ListPickerState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      selectedIndex: identical(selectedIndex, _unset)
          ? this.selectedIndex
          : selectedIndex as int?,
    );
  }
}

class ListPickerController extends StateNotifier<ListPickerState> {
  ListPickerController(this._randomOrgService) : super(const ListPickerState());

  final RandomOrgService _randomOrgService;

  void addItem(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = state.copyWith(
      items: [...state.items, trimmed],
      selectedIndex: null,
    );
  }

  void removeItem(int index) {
    final updatedItems = [...state.items]..removeAt(index);
    int? selectedIndex = state.selectedIndex;

    if (selectedIndex == index) {
      selectedIndex = null;
    } else if (selectedIndex != null && selectedIndex > index) {
      selectedIndex = selectedIndex - 1;
    }

    state = state.copyWith(items: updatedItems, selectedIndex: selectedIndex);
  }

  Future<void> pickItem() async {
    if (state.items.isEmpty || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, selectedIndex: null);
    final values = await _randomOrgService.fetchIntegers(
      count: 1,
      min: 0,
      max: state.items.length - 1,
    );
    state = state.copyWith(
      isLoading: false,
      selectedIndex: values.isEmpty ? 0 : values.first,
    );
  }
}

class CoinFlipScreen extends ConsumerStatefulWidget {
  const CoinFlipScreen({super.key});

  @override
  ConsumerState<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends ConsumerState<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
    final controller = ref.read(coinFlipProvider.notifier);
    if (ref.read(coinFlipProvider).isLoading) {
      return;
    }

    final animation = _controller.forward(from: 0);
    await controller.flip();
    await animation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(coinFlipProvider);
    final resultLabel = switch (state.result) {
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
                          final spin = state.isLoading
                              ? _controller.value * math.pi * 8
                              : (state.result ?? 0) == 1
                              ? math.pi
                              : 0.0;
                          final showingFront =
                              (spin % (math.pi * 2)) < math.pi;
                          final faceValue = state.isLoading
                              ? (showingFront ? 0 : 1)
                              : (state.result ?? 0);

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateX(state.isLoading
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
                    child: state.isLoading
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
                                state.result == null
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
                    onPressed: state.isLoading ? null : _flipCoin,
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

class DiceRollerScreen extends ConsumerStatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  ConsumerState<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends ConsumerState<DiceRollerScreen> {
  static const _availableSides = [4, 6, 8, 10, 12, 20, 100];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(diceRollProvider);
    final controller = ref.read(diceRollProvider.notifier);
    final total = state.results.fold<int>(0, (sum, value) => sum + value);

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
                    selected: {state.diceCount},
                    onSelectionChanged: (selection) {
                      controller.setDiceCount(selection.first);
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
                            selected: state.selectedSides == sides,
                            onSelected: (_) {
                              controller.setSelectedSides(sides);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: state.isLoading ? null : controller.roll,
                    icon: const Icon(Icons.casino),
                    label: const Text('Rolar os dados'),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: state.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : state.results.isEmpty
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
                            key: ValueKey(state.results.join(',')),
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
                                itemCount: state.results.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 1.35,
                                    ),
                                itemBuilder: (context, index) {
                                  final value = state.results[index];
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

class ListPickerScreen extends ConsumerStatefulWidget {
  const ListPickerScreen({super.key});

  @override
  ConsumerState<ListPickerScreen> createState() => _ListPickerScreenState();
}

class _ListPickerScreenState extends ConsumerState<ListPickerScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    ref.read(listPickerProvider.notifier).addItem(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(listPickerProvider);
    final controller = ref.read(listPickerProvider.notifier);

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
                      onPressed: (state.items.isEmpty || state.isLoading)
                          ? null
                          : controller.pickItem,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Escolher por mim'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: state.isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: CircularProgressIndicator(),
                          )
                        : state.items.isEmpty
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
                            key: ValueKey(
                              '${state.items.length}-${state.selectedIndex ?? -1}',
                            ),
                            children: [
                              if (state.selectedIndex != null) ...[
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
                                        state.items[state.selectedIndex!],
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
                                itemCount: state.items.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final isSelected = state.selectedIndex == index;
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
                                        state.items[index],
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
                                        onPressed: () => controller.removeItem(index),
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
