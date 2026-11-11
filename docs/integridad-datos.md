# Integridad financiera — esquema 3

## Alcance

Primera etapa del MVP: MXN, dinero entero, validación y escrituras atómicas.
No incluye CRUD completo, transferencias, empaquetado ni garantías de rendimiento.

## Dinero

- `Accounts.balanceCents`, `Transactions.amountCents` y
  `Subscriptions.amountCents` son INTEGER en SQLite.
- El texto se convierte directamente a centavos, sin `double`, redondeo ni truncado.
- `10`, `10.1`, `10.12` y `10,12` son válidos; `10.125`, `10.120`, negativos,
  cero, notación exponencial y separadores de miles se rechazan.
- Se permiten saldos negativos; el tipo de movimiento determina el signo.
- Límite defensivo por movimiento y valor absoluto de saldo:
  999,999,999,999 centavos (9,999,999,999.99 MXN).
- La presentación utiliza división entera y resto. Solo los valores geométricos
  del gráfico se convierten a double; no se reutilizan para cálculos financieros.

## Migración de desarrollo

El usuario autorizó eliminar los datos de prueba anteriores. Al abrir una base
con esquema 1 o 2, la migración a 3 elimina las cuatro tablas dentro de una
transacción, crea el esquema nuevo y agrega Efectivo, Banco y tres categorías.
No convierte ni redondea importes anteriores. Una base en versión 3 no se reinicia.
Las migraciones posteriores de producción deberán preservar los datos.

## Escrituras

`FinanceRepository` valida texto, tipo, fecha, categoría, cuenta, moneda y nota.
Inserción del movimiento y actualización SQL del saldo comparten una transacción.
La eliminación y reversión del saldo también son atómicas. Todas las escrituras
se esperan con await. La UI bloquea guardados repetidos mientras existe uno pendiente
conservando el formulario si ocurre un error.

SQLite usa claves foráneas activas, restricciones CHECK, espera por bloqueo de
5 segundos y synchronous=FULL. El sistema operativo y hardware también condicionan
la durabilidad; las pruebas no simulan todos los fallos físicos de almacenamiento.

Las fechas se validan como instantes UTC, se almacenan con la precisión de segundos
predeterminada de Drift y se muestran en hora local. Cambiar la zona horaria puede
cambiar el día local mostrado, pero no el instante registrado.

## Respaldos existentes

Los respaldos nuevos declaran formatVersion=3, currency=MXN y moneyUnit=cent.
Los anteriores se rechazan explícitamente. Se verifican importes enteros,
identificadores, relaciones y coherencia entre saldos y movimientos antes de
reemplazar datos. La importación es transaccional y la exportación usa una lectura
transaccional consistente. El respaldo automático de recuperación queda para
la etapa dedicada a respaldos, aún pendiente.

## Verificación

```sh
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze --no-pub
flutter test
```

En Linux, las pruebas nativas de SQLite necesitan que el cargador encuentre
`libsqlite3.so` (por ejemplo, mediante el paquete de desarrollo SQLite de la distro).
Este entorno solo tenía `libsqlite3.so.0`; se ejecutaron las pruebas con un enlace
local temporal y LD_LIBRARY_PATH, sin modificar las bibliotecas del sistema.

Las 16 pruebas cubren conversión y formato exactos, límites, rollback ante errores
SQL simulados, concurrencia, eliminación repetida, referencias, fechas con offset,
respaldos, migración 1/2 → 3, reapertura y bloqueo de doble pulsación.
