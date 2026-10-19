# Alcance de Dark Finance — Versión 1

App Flutter personal, solo Android, uso local. Esta versión es la base; el alcance crecerá.

## 1. Reparto del ingreso

| Porción              | % |
|----------------------|---|
| Gastos Obligatorios  | 50 |
| Inversión            | 25 |
| Casos de Emergencia  | 15 |
| Gustos               | 10 |

Cada porción muestra cuánto queda de su porcentaje.

## 2. Sueldo mensual

- Hay un apartado para definir el sueldo exacto y editarlo cuando cambie.
- El monto se mantiene hasta que yo lo cambie; la app no lo vuelve a pedir.
- Al iniciar un mes nuevo la app envía una notificación para recordar revisar si hubo cambios de sueldo.

### Qué pasa al cambiar el sueldo

**Caso 1 — Mes sin registros.** Se recalculan todas las porciones.
Ejemplo: $100 → 50/25/15/10; al pasar a $200 → 100/50/30/20.

**Caso 2 — Mes con registros.** La app pregunta si el nuevo monto es de este mes o del próximo.
- Del próximo mes: se aplica al iniciar el siguiente periodo.
- De este mes y mayor: aumentan las porciones, sin alertas.
- De este mes y menor: se recalcula teniendo en cuenta lo ya gastado y se muestran alertas donde lo gastado supere el nuevo tope.

**Caso 3 — Gastos que la app no registró.** Ingreso manualmente lo que me queda en cada porción. La app calcula lo gastado para que el restante coincida con la realidad.

## 3. Pantalla de Resumen

- Saldo disponible del mes, ingreso y gastado.
- Barra 50/25/15/10 con lo usado de cada porción.
- Tarjeta por porción con lo restante.
- Panel **Últimos gastos**: "el día X gasté $Y en [categoría]" (reemplaza a Hábitos de gasto).
- Menú lateral (hamburguesa) con opciones accionables.

## 4. Registro de gastos desde notificaciones

- La app lee las notificaciones de Banco Pichincha (compras, retiros, transferencias).
- Al detectar un gasto, avisa de inmediato con el monto y pregunta a qué porción va: Obligatorios, Gustos, Casos de Emergencia o Inversión (esta última rara vez).
- Luego se elige la categoría (comida, transporte, renta, etc., definidas por mí).
- Porción y categoría son independientes: un pasaje al acuapark es transporte pero va a Gustos; la comida puede ser Obligatoria o Gusto según el caso.
- Al clasificar, el monto se descuenta de la porción elegida.

## 5. Pagos recurrentes

- Defino los días de cobro de pagos fijos (por ejemplo gimnasio el 5 o el 16 de cada mes).
- Sirve para no olvidar cobros que el banco a veces no notifica.

## Notas de diseño acordadas (propuestas, a confirmar)

- Un gasto sin clasificar queda en una bandeja de pendientes, no se pierde.
- La clasificación se pide mediante notificación (Android no permite abrir ventanas solas en segundo plano).
- Los cobros recurrentes se enlazan con la notificación del banco si llega, para no duplicar.

## Decisiones pendientes

1. ¿El mes empieza el día 1 o el día en que se deposita el sueldo?
2. ¿El dinero sobrante se arrastra al mes siguiente o cada mes empieza de cero (por porción)?
3. ¿En qué porción va el gimnasio?
4. ¿Inversión se registra como aporte (cumplido al llegar al 25 %) en lugar de gasto?
5. Textos reales de notificaciones de Pichincha (compra, retiro, transferencia, depósito, cobro del gimnasio) para aprender a leerlos.

## Fuera de la v1 (ideas futuras)

- Dividir un gasto en varias porciones (por ejemplo una compra de supermercado).
- Conciliación contra el saldo real del banco.
- Metas con tope de gasto.
- Estadísticas por categoría y por porción más detalladas.

## Orden de construcción

1. Sueldo, periodos y los tres casos, con registro manual de gastos.
2. Base de datos local y lista de Últimos gastos.
3. Android SDK, lectura de notificaciones y flujo de clasificación con bandeja de pendientes.
4. Pagos recurrentes y recordatorios.
