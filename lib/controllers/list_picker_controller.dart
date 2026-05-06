import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/random_org_service.dart';

const _unset = Object();

final listPickerProvider =
    StateNotifierProvider<ListPickerController, ListPickerState>((ref) {
      return ListPickerController(ref.read(randomOrgServiceProvider));
    });

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
