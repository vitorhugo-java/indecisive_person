import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/random_org_service.dart';

const _unset = Object();

final coinFlipProvider = NotifierProvider<CoinFlipController, CoinFlipState>(
  CoinFlipController.new,
);

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

class CoinFlipController extends Notifier<CoinFlipState> {
  late final RandomOrgService _randomOrgService;

  @override
  CoinFlipState build() {
    _randomOrgService = ref.read(randomOrgServiceProvider);
    return const CoinFlipState();
  }

  Future<void> flip() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final values = await _randomOrgService.fetchIntegers(
      count: 1,
      min: 0,
      max: 1,
    );
    state = state.copyWith(
      isLoading: false,
      result: values.isEmpty ? 0 : values.first,
    );
  }
}
