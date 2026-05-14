import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/screens/about_me_screen.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/screens/dice_roll_screen.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';
import 'package:theuniversedecides/screens/tarot_draw_screen.dart';
import 'package:theuniversedecides/widgets/snack_bar_custom.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  late final StreamSubscription<QuickAccessAction> _quickAccessSubscription;
  late final StreamSubscription<RandomOrgFallbackEvent>
  _randomOrgFallbackSubscription;

  static const _screens = [
    CoinFlipScreen(),
    DiceRollScreen(),
    ListPickerScreen(),
    TarotDrawScreen(),
    AboutMeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final quickAccessService = ref.read(quickAccessServiceProvider);
    final randomOrgService = ref.read(randomOrgServiceProvider);
    _quickAccessSubscription = quickAccessService.actions.listen(
      _handleQuickAccessAction,
    );
    _randomOrgFallbackSubscription = randomOrgService.fallbackEvents.listen((
      _,
    ) {
      if (!mounted) {
        return;
      }

      SnackBarCustom.buildErrorMessage(
        AppLocalizations.of(context)!.randomOrgFallbackNotice,
        context: context,
      );
    });
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
    _randomOrgFallbackSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.monetization_on_outlined),
            selectedIcon: const Icon(Icons.monetization_on),
            label: l10n.navCoin,
          ),
          NavigationDestination(
            icon: const Icon(Icons.casino_outlined),
            selectedIcon: const Icon(Icons.casino),
            label: l10n.navDice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: l10n.navLists,
          ),
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: l10n.navTarot,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navAboutMe,
          ),
        ],
      ),
    );
  }
}
