import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/list_picker_controller.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

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

    return MysticScreenScaffold(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Escolhido pelo universo',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(color: Colors.white70),
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
                                  final isSelected =
                                      state.selectedIndex == index;
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
                                                  .withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected
                                            ? theme.colorScheme.primary
                                            : theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text(
                                        state.items[index],
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? theme
                                                    .colorScheme
                                                    .onPrimaryContainer
                                              : null,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () =>
                                            controller.removeItem(index),
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
