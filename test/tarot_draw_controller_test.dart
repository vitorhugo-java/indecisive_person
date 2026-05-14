import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/controllers/tarot_draw_controller.dart';

void main() {
  test('tarot deck mapping covers major and minor arcana boundaries', () {
    expect(TarotCard.fromDeckNumber(1).title, 'The Fool');
    expect(TarotCard.fromDeckNumber(22).title, 'The World');
    expect(TarotCard.fromDeckNumber(23).title, 'Ace of Wands');
    expect(TarotCard.fromDeckNumber(36).title, 'King of Wands');
    expect(TarotCard.fromDeckNumber(37).title, 'Ace of Cups');
    expect(TarotCard.fromDeckNumber(78).title, 'King of Pentacles');
  });
}
