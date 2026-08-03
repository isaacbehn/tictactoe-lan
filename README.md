# Tres en línea (Tic-Tac-Toe) - Multijugador LAN en Godot

Mini juego de 2 jugadores que se conectan **por la misma red WiFi/local**, cada uno desde su propio celular. Uno crea la partida (host) y el otro se une escribiendo la IP del host.

## Cómo probarlo en el editor

1. Instala **Godot 4.3** (Standard, no hace falta la versión .NET): https://godotengine.org/download
2. Abre este proyecto (`project.godot`) con Godot.
3. Corre el proyecto dos veces (dos instancias, o dos celulares/PCs en la misma red).
4. En una instancia pulsa **"Crear partida (Host)"**.
5. En la otra escribe la IP local que muestra la pantalla del host (ej. `192.168.1.5`) y pulsa **"Unirse a partida"**.
6. Cuando ambos se conectan, empieza el juego automáticamente. El host juega con **X**, quien se une juega con **O**.

> Ambos dispositivos deben estar en la **misma red WiFi** (no funciona con datos móviles ni redes distintas, a menos que configures port-forwarding o una VPN tipo Radmin/Hamachi/Tailscale).

## Compilar el APK automáticamente con GitHub Actions

Ya incluí el workflow `.github/workflows/build-apk.yml`, que usa la imagen `barichello/godot-ci` (trae Godot + plantillas de exportación + Android SDK preinstalados, no necesitas configurar nada más).

Pasos para activarlo:

1. Crea un repositorio nuevo en GitHub y sube este proyecto tal cual:
   ```bash
   cd tictactoe-lan
   git init
   git add .
   git commit -m "Proyecto inicial"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
   git push -u origin main
   ```
2. En cuanto hagas push a `main`, GitHub Actions compilará el APK automáticamente (pestaña **Actions** del repo).
3. Cuando termine (unos minutos), entra al workflow run → sección **Artifacts** → descarga `tictactoe-lan-apk`. Ahí está tu `tictactoe-lan.apk` listo para instalar.
4. También puedes lanzarlo manualmente desde la pestaña Actions con el botón **"Run workflow"** (gracias a `workflow_dispatch`).

### Notas sobre la firma del APK

- El workflow genera un **keystore de depuración (debug)** dentro del propio runner, así que el APK resultante es un build de *debug*, perfecto para instalar y probar entre amigos.
- Si más adelante quieres publicarlo en Google Play, necesitarás generar un keystore de **release** propio y usar `--export-release` en vez de `--export-debug`, además de guardar la contraseña como *GitHub Secret* (no hardcodeada en el repo).

### Instalar el APK en el celular

- Descarga el `.apk` del artifact y pásalo al celular (por cable, Drive, Telegram, etc.).
- Activa "Instalar apps de orígenes desconocidos" si Android lo pide.
- Instálalo en ambos celulares y listo.

## Estructura del proyecto

```
tictactoe-lan/
├── project.godot
├── export_presets.cfg          # configuración de exportación a Android
├── icon.svg
├── scenes/
│   ├── Main.tscn / Main.gd     # menú: crear partida / unirse por IP
│   └── Game.tscn / Game.gd     # tablero y lógica de red
└── .github/workflows/
    └── build-apk.yml           # compila el APK en cada push a main
```

## Ideas para extender

- Marcador de partidas ganadas por sesión.
- Animación al ganar / resaltar la línea ganadora.
- Chat de texto simple entre los dos jugadores usando otro RPC.
- Reconexión si alguien pierde la señal WiFi.
