import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/dice_roll_controller.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

class DiceRollScreen extends ConsumerWidget {
  const DiceRollScreen({super.key});

  static const _availableSides = [4, 6, 8, 10, 12, 20, 100];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(diceRollProvider);
    final controller = ref.read(diceRollProvider.notifier);
    final total = state.results.fold<int>(0, (sum, value) => sum + value);

    return MysticScreenScaffold(
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
