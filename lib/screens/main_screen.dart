import 'package:flutter/material.dart';

import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/screens/dice_roll_screen.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    CoinFlipScreen(),
    DiceRollScreen(),
    ListPickerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Universe Decides'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
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
        ],
      ),
    );
  }
}
