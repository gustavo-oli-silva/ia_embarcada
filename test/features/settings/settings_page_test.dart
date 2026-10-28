import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ia_embarcada/features/settings/data/settings_repository.dart';
import 'package:ia_embarcada/features/settings/domain/app_settings.dart';
import 'package:ia_embarcada/features/settings/presentation/settings_controller.dart';
import 'package:ia_embarcada/features/settings/presentation/settings_page.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const AppSettings()]);
  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings s) async => settings = s;
}

void main() {
  testWidgets('SettingsPage exibe elementos e permite alterar limiar via chip',
      (tester) async {
    final repo = FakeSettingsRepository();
    final controller = SettingsController(repo);
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(controller: controller),
      ),
    );

    // Verifica se os textos principais estão na tela
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Limiar de Confiança'), findsOneWidget);
    expect(find.text('Modo de Exibição'), findsOneWidget);
    expect(find.text('0.50'), findsOneWidget);

    // Toca no chip 0.9
    final chip09 = find.widgetWithText(ChoiceChip, '0.9');
    expect(chip09, findsOneWidget);
    await tester.tap(chip09);
    await tester.pumpAndSettle();

    expect(controller.threshold, 0.9);
    expect(find.text('0.90'), findsOneWidget);

    // Alterna para o modo Cards
    final cardsSegment = find.text('Cards');
    expect(cardsSegment, findsOneWidget);
    await tester.ensureVisible(cardsSegment);
    await tester.pumpAndSettle();
    await tester.tap(cardsSegment);
    await tester.pumpAndSettle();

    expect(controller.displayMode, DisplayMode.cards);
  });
}
