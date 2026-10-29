# IA Embarcada 📱🤖

Aplicativo educacional em **Flutter** demonstrando o funcionamento de **Inteligência Artificial Embarcada (on-device)** através do pacote [Google ML Kit Image Labeling](https://pub.dev/packages/google_mlkit_image_labeling).

---

## 1. O que é IA Embarcada?

* **IA Embarcada (on-device):** O modelo roda inteiramente no processador do próprio celular. Não há envio de imagens para nenhum servidor, não consome franquia de dados e funciona perfeitamente sem conexão com a internet.
* **Comparação com a Nuvem:** A nuvem é como telefonar para um especialista (tem capacidade enorme, mas exige sinal de internet, latência de rede e custo por requisição). A IA embarcada é um guia de bolso (mais especializada e compacta, mas rápida, gratuita por uso e sempre disponível).

---

## 2. O que o App Faz

* Recebe uma foto (escolhida da **Galeria** ou capturada pela **Câmera**).
* Executa a inferência localmente via ML Kit e devolve os rótulos reconhecidos acompanhados da nota de certeza (ex: `Dog 92%`, `Coffee cup 85%`).
* Mede e exibe o **tempo exato de inferência** em milissegundos (`ms`).
* Permite ajustar em tempo real o **limiar de confiança** e o modo visual de exibição (**Lista** ou **Cards**).
* Persiste os ajustes definidos no banco de dados local **SQLite** (`sqflite`).

---

## 3. O Conceito-Chave: O Limiar de Confiança

Cada rótulo identificado pelo modelo recebe uma pontuação entre `0.0` e `1.0`. O limiar é o valor mínimo para que o rótulo seja exibido na tela:

* **Limiar Baixo (`0.30`):** O modelo é permissivo; aparecem muitos rótulos, inclusive suposições e palpites imprecisos.
* **Limiar Intermediário (`0.60`):** Equilíbrio entre cobertura e assertividade.
* **Limiar Alto (`0.90`):** O modelo é rigoroso; exibe apenas os rótulos sobre os quais o modelo tem altíssima certeza.

---

## 4. Estrutura do Código (MVCS)

O projeto segue o padrão **MVCS** (Model, View, Controller, Service):

```text
lib/
├── main.dart                         # Ponto de entrada, inicialização do SQLite
├── app.dart                          # MaterialApp, injeção de dependências e tema
├── theme/app_theme.dart              # Tema visual Material 3
├── models/                           # Dados da aplicação
│   ├── analysis_result.dart          # LabelResult e AnalysisResult
│   ├── app_settings.dart             # Configurações (limiar e modo de exibição)
│   └── label_translations.dart       # Dicionário inglês → português dos 447 rótulos
├── views/                            # Telas e widgets
│   ├── labeling_page.dart            # Tela principal (foto, métricas e resultados)
│   ├── settings_page.dart            # Tela com Slider, chips 0.3/0.6/0.9 e toggle
│   └── widgets/
│       ├── labels_list_view.dart     # Visualização em lista com barras de progresso
│       └── labels_cards_view.dart    # Visualização em grade de cartões
├── controllers/                      # Estado reativo (ChangeNotifier)
│   ├── labeling_controller.dart      # Captura da foto e fluxo da análise
│   └── settings_controller.dart      # Leitura e alteração dos ajustes
└── services/                         # Acesso a recursos externos
    ├── image_labeler_service.dart    # Interface abstrata do rotulador
    ├── mlkit_image_labeler_service.dart  # 👈 ONDE A IA É EXECUTADA
    ├── app_database.dart             # Conexão e criação da tabela no SQLite
    └── settings_repository.dart      # Leitura e gravação dos ajustes no SQLite
```

### Onde a IA roda no código (4 passos):

1. **Captura da foto:** [`labeling_controller.dart`](lib/controllers/labeling_controller.dart) via `ImagePicker.pickImage()`.
2. **Conversão do formato:** [`mlkit_image_labeler_service.dart`](lib/services/mlkit_image_labeler_service.dart) instancia `InputImage.fromFilePath(imagePath)`.
3. **Configuração com o limiar:** `ImageLabelerOptions(confidenceThreshold: threshold)`.
4. **Inferência on-device:** `await labeler.processImage(inputImage)`. Aqui o processador local do celular executa o modelo neural.

---

## 5. Como Executar em Desenvolvimento

> **Atenção:** O Google ML Kit utiliza bibliotecas nativas de visão computacional para dispositivos móveis (Android e iOS). **Não** utilize Chrome ou Windows Desktop para testar o reconhecimento de imagens.

### Pré-requisitos
* Flutter SDK (3.47.x ou compatível) via [FVM](https://fvm.app/) ou Flutter global.
* Emulador Android (API 21+) configurado com Google Play Services, ou celular Android conectado via USB (com Depuração USB ativada).

### Comandos:
```bash
# Obter as dependências
fvm flutter pub get

# Executar a análise estática
fvm flutter analyze

# Rodar os testes de unidade e widgets
fvm flutter test

# Iniciar o app no emulador ou dispositivo conectado
fvm flutter run
```

*Dica para emuladores:* Arraste imagens do seu computador diretamente para a janela do emulador Android para adicioná-las à galeria do emulador.

---

## 6. Como Gerar o APK para a Turma

Para disponibilizar o aplicativo pronto para instalação direta em celulares Android (sideload):

```bash
fvm flutter build apk --release --split-per-abi
```

O comando gerará APKs otimizados na pasta `build/app/outputs/flutter-apk/`:
* `app-arm64-v8a-release.apk`: Para praticamente todos os celulares modernos (64 bits).
* `app-armeabi-v7a-release.apk`: Para celulares mais antigos ou básicos (32 bits).
* `app-x86_64-release.apk`: Para emuladores de PC.

### Como a turma instala:
1. Disponibilize o arquivo `app-arm64-v8a-release.apk` (via Google Drive ou GitHub Releases).
2. Projete um **QR Code** na tela da sala com o link direto para download.
3. No celular, o aluno baixa o arquivo e autoriza a opção **"Instalar de fontes desconhecidas"**.
4. Instalação concluída em menos de 2 minutos.

---

## 7. Roteiro da Atividade Prática em Sala

1. **Instalação:** Todos instalam o APK.
2. **Teste do Modo Avião:** Ative o **Modo Avião** (desconecte Wi-Fi e dados móveis) e execute o app. Como o modelo é embarcado, a inferência funciona com a mesma velocidade e precisão.
3. **Exploração do Limiar:**
   * Fotografe um objeto (ex: garrafa, mochila, lanche).
   * Teste com o limiar em **`0.3`**, depois **`0.6`**, e por fim **`0.9`**. Observe os rótulos que desaparecem.
4. **Variação de Luz e Ângulo:**
   * Mude o ângulo, afaste ou aproxime a câmera, reduza a luz da foto.
   * Observe a variação na nota de certeza (%).
5. **Tentando "Enganar" a IA:**
   * Fotografe desenhos feitos à mão, sombras ou objetos incomuns.
6. **Comparação de Desempenho:**
   * Compare o tempo em milissegundos (`ms`) entre aparelhos diferentes da sala.

---

## 8. Limitações do Modelo Pré-Treinado

* **Vocabulário Genérico:** O modelo base do ML Kit reconhece cerca de 400 categorias comuns (ex: comida, móveis, plantas, animais).
* **Idioma:** O modelo devolve os rótulos em **inglês**. O app traduz para português de forma offline, usando um dicionário fixo em [`label_translations.dart`](lib/models/label_translations.dart), e mostra o original em inglês logo abaixo.
* **Sem distinções hiperespecíficas:** O modelo reconhece *"Plant"* ou *"Flower"*, mas não identifica doenças foliares específicas ou espécies raras.
