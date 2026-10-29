import 'package:flutter_test/flutter_test.dart';
import 'package:ia_embarcada/models/label_translations.dart';

void main() {
  group('translateLabel', () {
    test('traduz um rótulo conhecido do modelo', () {
      expect(translateLabel('Dog'), 'Cachorro');
      expect(translateLabel('Cup'), 'Xícara');
    });

    test('devolve o texto original quando não há tradução', () {
      expect(translateLabel('Rótulo inexistente'), 'Rótulo inexistente');
    });
  });

  test('dicionário cobre os 447 rótulos do modelo sem valores vazios', () {
    expect(labelTranslationsPt.length, 447);
    expect(
      labelTranslationsPt.values.where((value) => value.trim().isEmpty),
      isEmpty,
    );
  });
}
