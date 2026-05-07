import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/coin_flip_controller.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

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

    return MysticScreenScaffold(
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
                          final showingFront = (spin % (math.pi * 2)) < math.pi;
                          final faceValue = state.isLoading
                              ? (showingFront ? 0 : 1)
                              : (state.result ?? 0);

                          // Perspective plus X/Y rotation keeps the coin toss feeling 3D while
                          // still landing on the resolved Riverpod state after the fetch finishes.
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateX(
                                state.isLoading
                                    ? math.sin(_controller.value * math.pi) *
                                          0.18
                                    : 0.0,
                              )
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
              color: Colors.black.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 12),
            Text(
              isCara ? 'CARA' : 'COROA',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.black.withValues(alpha: 0.82),
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
