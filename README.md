# PepeGrillo

Aplicación de finanzas personales en español con Flutter, Riverpod y SQLite (Drift). Registra ingresos y gastos en pesos mexicanos sin conexión, revisa tu saldo, analiza gastos por categoría y administra suscripciones. El chat de IA está en desarrollo.

## Descargar y ejecutar

En [Releases](https://github.com/will035/PepeGrilloApp/releases) se distribuye el paquete para Linux x86-64. Extrae el `.tar.gz` completo y ejecuta `pepe_grillo_app` junto a `lib/` y `data/`. El archivo `.sha256` permite verificar la descarga con `sha256sum -c`. Esta entrega se compiló para Ubuntu 24.04; otras distribuciones y sistemas requieren validación propia.

## Desarrollo

Se usa Flutter 3.44.8 (Dart 3.12.2). En Linux instala las herramientas de compilación de Flutter para escritorio, GTK 3 y la biblioteca de desarrollo de SQLite (`libsqlite3-dev` en Ubuntu).

```sh
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter run -d linux
```

Los modelos generados de Drift y Riverpod están versionados. Tras modificar sus definiciones, ejecuta `dart run build_runner build --delete-conflicting-outputs`. Para generar el paquete de Linux, ejecuta `./scripts/package-linux.sh`.

## Estructura

| Carpeta | Contenido |
| --- | --- |
| `lib/core/` | Reglas de dinero, persistencia, repositorios, estado y tema |
| `lib/features/` | Pantallas de inicio, análisis, movimientos, suscripciones y ajustes |
| `assets/` | Recursos incluidos en la app y licencia de la tipografía Inter |
| `test/` | Pruebas de integridad y presentación |
| `android/`, `ios/`, `linux/`, `macos/`, `windows/` | Proyectos nativos por plataforma |
| `docs/` | [Esquema, migraciones y garantías de integridad](docs/integridad-datos.md) |
| `scripts/`, `packaging/` | Construcción y archivos de distribución |
| `dist/` | Paquetes generados localmente, excluidos de Git |

Los importes se almacenan en centavos enteros. La actualización desde los esquemas de prueba 1 y 2 reinicia esos datos. Las bases de datos personales, respaldos, claves de firma y cachés no forman parte del repositorio.
