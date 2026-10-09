# NÚCLEO ZERO

Jogo incremental **offline** para Android, desenvolvido em **Godot 4 / GDScript**. Projeto original com reator interativo, cápsulas, 30 relíquias, seis raridades, melhorias, produção automática, ascensão e gravação local.

## APK Android

Acede a [GitHub Actions](https://github.com/PulseBreakPT/NucleoZero/actions) e abre **Compilar APK Android (debug)**. Depois de uma execução com sucesso, descarrega o artefacto **NucleoZero-Android-APK** e extrai o ficheiro `NucleoZero.apk`.

O APK de debug é instalável em dispositivos Android ARM64 e não requer internet para jogar. Ainda não é uma versão de produção da Google Play.

## Abrir no Godot

Abre `project.godot` no Godot **4.5.2 Standard** e executa com F5. A pasta `scripts/` contém a lógica e interface; `assets/` contém os recursos gráficos SVG.

## Automatização

O workflow `.github/workflows/android-debug.yml` instala Godot e Android SDK, testa a lógica e a cena principal, exporta e disponibiliza o APK.

**Nota sobre o primeiro envio:** o projeto será inicialmente sincronizado num pacote de arranque e expandido para os ficheiros normais pelo primeiro workflow, para permitir a publicação através da ligação GitHub. O código será legível e editável diretamente no repositório após essa sincronização.

Este projeto é um protótipo em desenvolvimento. A compilação e o teste físico num telemóvel serão validados separadamente.
