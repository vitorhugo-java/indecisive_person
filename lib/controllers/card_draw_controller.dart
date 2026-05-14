import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/random_org_service.dart';

const _unset = Object();
const _cardRanks = [
  'A',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  'J',
  'Q',
  'K',
];

final cardDrawProvider = NotifierProvider<CardDrawController, CardDrawState>(
  CardDrawController.new,
);

enum CardSuit { hearts, diamonds, clubs, spades }

class PlayingCard {
  const PlayingCard({
    required this.number,
    required this.rank,
    required this.suit,
  });

  factory PlayingCard.fromNumber(int value) {
    final normalized = value.clamp(1, 52) as int;
    final zeroBased = normalized - 1;

    return PlayingCard(
      number: normalized,
      rank: _cardRanks[zeroBased % _cardRanks.length],
      suit: CardSuit.values[zeroBased ~/ _cardRanks.length],
    );
  }

  final int number;
  final String rank;
  final CardSuit suit;

  bool get isRed => suit == CardSuit.hearts || suit == CardSuit.diamonds;

  String get symbol => switch (suit) {
    CardSuit.hearts => '♥',
    CardSuit.diamonds => '♦',
    CardSuit.clubs => '♣',
    CardSuit.spades => '♠',
  };

  String get shortLabel => '$rank$symbol';
}

class CardDrawState {
  const CardDrawState({this.card, this.isLoading = false});

  final PlayingCard? card;
  final bool isLoading;

  CardDrawState copyWith({Object? card = _unset, bool? isLoading}) {
    return CardDrawState(
      card: identical(card, _unset) ? this.card : card as PlayingCard?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CardDrawController extends Notifier<CardDrawState> {
  late final RandomOrgService _randomOrgService;

  @override
  CardDrawState build() {
    _randomOrgService = ref.read(randomOrgServiceProvider);
    return const CardDrawState();
  }

  Future<void> drawCard() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final values = await _randomOrgService.fetchIntegers(
      count: 1,
      min: 1,
      max: 52,
    );
    state = state.copyWith(
      isLoading: false,
      card: PlayingCard.fromNumber(values.isEmpty ? 1 : values.first),
    );
  }
}
