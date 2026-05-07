import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/random_org_service.dart';

final diceRollProvider = NotifierProvider<DiceRollController, DiceRollState>(
  DiceRollController.new,
);

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

class DiceRollController extends Notifier<DiceRollState> {
  late final RandomOrgService _randomOrgService;

  @override
  DiceRollState build() {
    _randomOrgService = ref.read(randomOrgServiceProvider);
    return const DiceRollState();
  }

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
