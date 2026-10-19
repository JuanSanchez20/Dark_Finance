# Dark Finance

App Flutter personal de control financiero. Solo Android, uso local (los datos viven en el teléfono, sin servidor).
El alcance completo está en [`docs/ALCANCE.md`](docs/ALCANCE.md).

## Qué hace hoy

| Pantalla    | Qué permite |
|-------------|-------------|
| Resumen     | Saldo disponible del mes, reparto 50/25/15/10 con lo que queda de cada porción, de dónde salen los ingresos y los últimos gastos. |
| Ingresos    | **Sueldo base**, **ingresos fijos** que se suman cada mes y **ingresos únicos** de un mes. |
| Categorías  | Crear, editar y eliminar categorías de gasto (nombre, icono, color, porción habitual, gasto fijo). |
| Ajustes     | Vacío por ahora (el sueldo se define en Ingresos). |

Movimientos, Presupuesto y Metas aparecen en el menú como "próximamente".
En todas las listas, **desliza hacia abajo para recargar**.

### Sueldo base (pantalla Ingresos)
- Se define una vez y se mantiene cada mes hasta que lo cambies. Avisa "Sueldo definido" o "Error en la definición del sueldo".
- Si el mes **no tiene gastos**, el cambio recalcula todo (100 → 200 pasa de 50/25/15/10 a 100/50/30/20).
- Si el mes **ya tiene gastos**, la app pregunta si el cambio es de este mes o del próximo. Si baja el sueldo y alguna porción ya gastó más de lo permitido, muestra una alerta.

### Ingresos extra: dos tipos
Todo ingreso extra se suma al sueldo y **siempre se reparte en 50/25/15/10**. La diferencia es cuánto dura:

| Tipo | Cómo se registra | Dura | Tiene fecha |
|---|---|---|---|
| **Fijo mensual** (bono, transporte incluido) | "Agregar ingreso" con *Sumar a mi sueldo cada mes* activado | Todos los meses hasta que lo desactives o elimines | No |
| **Único** (arreglé una computadora, vendí algo) | "Agregar ingreso" con el interruptor apagado | Solo el mes en que lo registras | Sí (dentro del mes actual) |

Reglas de los ingresos fijos:
- Cada mes la app copia los fijos activos como un ingreso de ese mes. Así **los meses pasados no cambian** si luego editas el monto.
- Editar, activar/desactivar o eliminar un fijo rige **desde el mes actual**; el pasado no se toca.
- Se editan tocándolos; el interruptor de la fila los activa o desactiva.

El Resumen muestra el ingreso total del mes, de dónde sale cada parte, y si vas bien, con cuidado o te pasaste.

### Categorías
- Vienen 10 categorías de ejemplo. Puedes cambiarlas, borrarlas o crear las tuyas.
- **Los iconos** salen de una lista fija en `features/categories/presentation/category_style.dart` (y las categorías de ejemplo de `core/database/seed/default_data.dart`). Para ofrecer más, agrega emojis a esa lista.
- No se puede eliminar una categoría con movimientos. No se permiten nombres repetidos.

## Cómo está organizado el código

Arquitectura **por funcionalidades ("feature-first") con capas**. Cada funcionalidad es una carpeta en `lib/features/` y se divide siempre igual:

```
domain/        Modelos y reglas de cálculo. Dart puro: no conoce Flutter ni la base de datos.
data/          De dónde salen y dónde se guardan los datos.
presentation/  Pantallas y widgets (lo que se ve).
```

### Mapa de carpetas

```
lib/
├── main.dart            Punto de entrada. Crea la base de datos y los repositorios y arranca la app.
├── app.dart             Tema y rutas (qué pantalla es cada ruta).
│
├── core/                Piezas que usa toda la app, sin lógica de una pantalla concreta.
│   ├── database/        Base de datos local (ver "Base de datos" más abajo).
│   ├── errors/          Excepciones propias (dato inválido con mensaje legible).
│   ├── theme/           Colores (app_colors) y estilo general (app_theme).
│   └── utils/           Funciones pequeñas: formato y lectura de montos, colores hex.
│
├── shared/              Piezas de interfaz reutilizables por varias pantallas.
│   ├── navigation/      Rutas, opciones del menú lateral y cómo se navega.
│   └── widgets/         Menú lateral, tarjeta base, título de sección, avisos (snackbars).
│
└── features/            Una carpeta por funcionalidad.
    ├── budget/          Base común: porciones, cómo se crean los meses, cuánto se gastó por porción.
    ├── home/            Pantalla Resumen.
    ├── income/          Sueldo base, ingresos fijos e ingresos únicos (pantalla Ingresos).
    ├── categories/      Pantalla Categorías.
    └── settings/        Pantalla Ajustes.
```

### Qué hace cada carpeta de una feature

| Carpeta | Para qué sirve | Ejemplo |
|---|---|---|
| `domain/` | Datos y reglas del negocio. Si cambia una *regla* (cómo se calcula lo restante), se toca aquí. | `budget/domain/budget_bucket.dart` |
| `data/*_repository.dart` | **Contrato**: lista de cosas que se pueden pedir, sin decir cómo. | `income/data/income_repository.dart` |
| `data/drift_*_repository.dart` | **Implementación** del contrato usando la base de datos. | `income/data/drift_income_repository.dart` |
| `presentation/` | Pantallas y widgets. Solo dibujan y llaman al contrato. | `home/presentation/home_screen.dart` |

### Base de datos (`core/database/`)

Usa **Drift**, una librería que guarda los datos en SQLite (un archivo en el teléfono).

- `tables/`: define **qué se guarda** (una tabla por archivo).
- `daos/`: **DAO = Data Access Object**, "el encargado de una tabla". Cada DAO reúne las consultas de esa tabla (`TransactionsDao` sabe buscar, insertar y borrar movimientos). El resto de la app nunca escribe consultas sueltas.
- `seed/default_data.dart`: datos con los que nace la base (las 4 porciones y las 10 categorías de ejemplo).
- `app_database.dart`: junta tablas y DAOs y crea los datos iniciales.
- Archivos `*.g.dart`: **los genera Drift automáticamente; no se editan a mano.** Se regeneran con `dart run build_runner build` cuando se cambia una tabla o un DAO.

**Todo se enlaza por id, nunca por nombre:**
- `BucketDefinitions` son las 4 porciones permanentes (cada una con un `key` estable). Renombrar una porción no rompe nada.
- Cada mes tiene sus propias filas en `Buckets`, que apuntan a su definición por `definitionId` y guardan el porcentaje de ese mes.
- Las categorías guardan `defaultBucketId`; los movimientos guardan `bucketId`, `categoryId` y `recurringIncomeId`.
- El tipo de movimiento (`TransactionType`) y su origen (`TransactionSource`) son enumeraciones (`tables/enums.dart`), no textos sueltos.

> **Mientras la app está en pruebas**, subir `schemaVersion` en `app_database.dart` **borra la base y la recrea vacía**. Cuando haya datos reales hay que reemplazar eso por migraciones que los conserven.
>
> **Limitación conocida:** el generador de Drift que se usa (`drift_dev 2.31` con `analyzer 10`) no está creando las restricciones `REFERENCES` entre tablas (da la advertencia "should be a simple class name"). Por eso la base no impide por sí sola un enlace roto, y esas validaciones se hacen en los repositorios (por ejemplo, no se borra una categoría con movimientos). Conviene revisarlo al actualizar Drift.

### Por qué esta organización (principios SOLID)

- **S (una responsabilidad por archivo):** cada widget dibuja un solo bloque; cada repositorio atiende una sola funcionalidad; las reglas de cálculo viven en `domain/`.
- **O (abierto a ampliar, cerrado a modificar):** para una pantalla nueva se agregan archivos (ruta + destino del menú) sin reescribir las existentes.
- **L (sustitución):** cualquier implementación de un contrato (`IncomeRepository`) sirve donde se pide ese contrato; por eso las pruebas usan versiones falsas.
- **I (interfaces pequeñas):** un contrato por funcionalidad (sueldo, ingresos fijos, ingresos únicos, categorías, resumen) en vez de uno gigante.
- **D (depender de contratos):** las pantallas reciben un `*Repository` abstracto. Quién lo implementa se decide solo en `main.dart`.

Flujo de una acción, por ejemplo "guardar sueldo":
`IncomeCard` (presentation) → `IncomeRepository` (contrato) → `DriftIncomeRepository` (implementación) → `PeriodsDao` (consulta) → base de datos.

## Dónde va lo nuevo y dónde cambiar lo existente

| Quiero... | Voy a... |
|---|---|
| Cambiar un color | `core/theme/app_colors.dart` |
| Cambiar nombres o porcentajes iniciales del reparto | `core/database/seed/default_data.dart` (y subir `schemaVersion` para recrear la base) |
| Agregar o quitar una opción del menú lateral | `shared/navigation/app_destinations.dart` |
| Agregar una pantalla nueva | Carpeta nueva en `features/<nombre>/` (`domain`, `data`, `presentation`) + ruta en `app_routes.dart` + entrada en `app.dart` + opción en `app_destinations.dart` + repositorio en `main.dart` |
| Agregar una tabla | Archivo en `core/database/tables/`, DAO en `daos/`, registrarlos en `app_database.dart`, subir `schemaVersion` y regenerar |
| Cambiar cómo se crea un mes nuevo o cómo se aplican los ingresos fijos | `features/budget/data/budget_periods_gateway.dart` |
| Cambiar la regla de alerta al bajar el sueldo | `features/income/domain/income_change.dart` (`findOverspends`) |
| Cambiar las reglas de los ingresos fijos | `features/income/data/drift_recurring_income_repository.dart` |
| Cambiar los iconos o colores que se ofrecen en categorías | `features/categories/presentation/category_style.dart` |
| Cambiar el orden de los bloques del Resumen | `features/home/presentation/home_screen.dart` |
| Mostrar un aviso de éxito o error | `shared/widgets/app_feedback.dart` (`showFeedback`, `showFailure`) |

### Reglas al programar pantallas
- Para recargar una lista, el `setState` **no puede devolver un Future**. Escribe `setState(() { _data = _load(); });` con llaves, no con `=>`. Hacerlo mal produce un error aunque el cambio sí se haya guardado.
- Toda lista debe tener `RefreshIndicator` y `AlwaysScrollableScrollPhysics`, para poder recargar deslizando.

### Dónde irán las próximas funcionalidades
- **Registro de gastos y notificaciones del banco:** `features/transactions/` (lista y alta de movimientos) y `features/notifications/` (lector de notificaciones de Pichincha y bandeja de pendientes por clasificar). Usarán las tablas `Transactions` y `MerchantRules`, que ya existen.
- **Pagos recurrentes (gimnasio):** `features/scheduled_charges/`, sobre la tabla `ScheduledCharges`.
- **Metas:** `features/goals/`, sobre la tabla `Goals`.

## Entorno de desarrollo (Windows)

- Flutter está en `C:\Users\TUF F15\AppData\Local\Programs\flutter\bin` (no está en el PATH).
- **Las rutas con espacios** (`TUF F15`) hacen fallar la compilación de código nativo que traen los paquetes de la base de datos. Se crearon enlaces sin espacios en la raíz de `C:\`: `C:\flutter_sdk` (Flutter), `C:\pub_cache` (paquetes) y `C:\df` (este proyecto). Si `flutter run`, `flutter test` o `dart run build_runner` fallan con `"C:\Users\TUF" no se reconoce...`, usa esas rutas (con `PUB_CACHE=C:\pub_cache`), o mueve Flutter y el proyecto a una carpeta sin espacios (por ejemplo `C:\dev`).
- Para compilar con plugins en Windows hay que activar el **Modo desarrollador** (Configuración → Para programadores).
- Comprobar el código: `dart analyze`. Pruebas: `flutter test` (en `test/`).
