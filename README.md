# NÚCLEO ZERO (Godot 4)

Jogo **incremental offline para Android**, desenvolvido em Godot **4.5.2**, com identidade original. O código está organizado em GDScript, sem WebView, contas, anúncios ou ligações a servidores.

## Jogabilidade

- Reator táctil: toca para gerar energia e receber cápsulas.
- 30 relíquias colecionáveis distribuídas por seis raridades.
- Economia: moedas, venda de itens e cinco melhorias.
- Produção automática, golpes críticos e sorte.
- Quatro ecrãs: Reator, Oficina, Arquivo e Ascensão.
- Talentos permanentes e sistema de prestígio.
- Gravação JSON local e recuperação até oito horas offline.
- Feedback háptico no Android e interface vertical.

## Abrir o projeto

Instala o [Godot 4](https://godotengine.org/download/), abre \`project.godot\` e executa com F5. O projeto usa GDScript, sem .NET.

Para testes headless: \`godot --headless --editor --path . --quit\`, depois \`godot --headless --path . --script res://tests/smoke_test.gd\`.

## APK Android

O envio de alterações para \`main\` inicia o workflow [Compilar APK Android (debug)](https://github.com/PulseBreakPT/NucleoZero/actions). A Action instala o Godot 4.5.2, Android SDK e templates, corre os testes, exporta a aplicação em ARM64 e disponibiliza o artefacto **NucleoZero-Android-APK** com \`NucleoZero.apk\`.

O APK de debug é para instalação e testes, não para publicação comercial na Google Play. O jogo não solicita permissão de internet.

## Estrutura

\`project.godot\`, \`scenes/Main.tscn\`, \`scripts/GameData.gd\`, \`scripts/Main.gd\`, \`tests/smoke_test.gd\`, \`assets/atmosphere.svg\`, \`assets/icon.svg\` e \`export_presets.cfg\`.

**Estado:** protótipo aberto à evolução. Design, economia e equilíbrio de recompensas sujeitos a testes reais.
