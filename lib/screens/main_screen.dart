import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/screens/about_me_screen.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/screens/dice_roll_screen.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  late final StreamSubscription<QuickAccessAction> _quickAccessSubscription;

  static const _screens = [
    CoinFlipScreen(),
    DiceRollScreen(),
    ListPickerScreen(),
    AboutMeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final quickAccessService = ref.read(quickAccessServiceProvider);
    _quickAccessSubscription = quickAccessService.actions.listen(
      _handleQuickAccessAction,
    );
    _loadInitialQuickAccessAction(quickAccessService);
  }

  Future<void> _loadInitialQuickAccessAction(
    QuickAccessService quickAccessService,
  ) async {
    final action = await quickAccessService.getInitialAction();
    if (!mounted || action == null) {
      return;
    }

    _handleQuickAccessAction(action);
  }

  void _handleQuickAccessAction(QuickAccessAction action) {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = action.tabIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      switch (action) {
        case QuickAccessAction.coin:
          ref.read(coinQuickAccessTriggerProvider.notifier).trigger();
        case QuickAccessAction.dice:
          ref.read(diceQuickAccessTriggerProvider.notifier).trigger();
      }
    });
  }

  @override
  void dispose() {
    _quickAccessSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Sobre mim',
          ),
        ],
      ),
    );
  }
}
