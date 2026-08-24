-- =============================================================================
--  ventas.sql — tabla grande para el bloque de rendimiento
-- =============================================================================
--
--  Los índices y los planes de ejecución NO se pueden enseñar sobre Northwind:
--  con 830 pedidos, PostgreSQL recorre la tabla entera más rápido de lo que
--  tardaría en consultar un índice. Sin diferencias medibles, nadie se cree
--  que los índices sirvan para algo.
--
--  Este script añade `practica.ventas`: 2.000.000 de filas, unos 115 MB.
--  Con ella las diferencias son de uno a tres órdenes de magnitud y se ven.
--
--  REQUISITO: haber cargado antes practica.sql, que crea el esquema.
--
--  USO
--      psql -d northwind -f practica.sql     # el esquema
--      psql -d northwind -f ventas.sql       # + la tabla grande
--
--  Es también su propio botón de reset: empieza por DROP TABLE. Tarda unos
--  3 segundos. Se carga solo cuando se llega al bloque 10.
-- =============================================================================

DROP TABLE IF EXISTS practica.ventas;

-- -----------------------------------------------------------------------------
-- 1. Dos millones de ventas repartidas entre 5.000 clientes y 500 productos
-- -----------------------------------------------------------------------------
-- Los ::bigint no son decoración: sin ellos, g * 7919 se pasa del rango de
-- integer y da "ERROR: integer out of range".

CREATE TABLE practica.ventas AS
SELECT g::int                                                   AS venta_id,
       DATE '2020-01-01' + (g % 2000)                           AS fecha,
       'C' || lpad(((g::bigint * 7919) % 5000)::text, 5, '0')   AS cliente,
       (((g::bigint * 31) % 500) + 1)::int                      AS producto_id,
       ((g % 9) + 1)::smallint                                  AS cantidad,
       round((((g::bigint * 13) % 50000) / 100.0)::numeric, 2)  AS importe
FROM generate_series(1, 2000000) AS g;

-- -----------------------------------------------------------------------------
-- 2. Estadísticas
-- -----------------------------------------------------------------------------
-- Sin ANALYZE el planificador trabaja a ciegas y elige mal. No es opcional.

ANALYZE practica.ventas;

-- -----------------------------------------------------------------------------
-- 3. Sin índices, a propósito
-- -----------------------------------------------------------------------------
-- Crearlos es el trabajo del alumno en el tema `indices`. La tabla se entrega
-- desnuda para que la primera medición sea un recorrido completo.

-- -----------------------------------------------------------------------------
-- 4. Comprobación
-- -----------------------------------------------------------------------------

SELECT count(*)                                              AS filas,
       pg_size_pretty(pg_total_relation_size('practica.ventas')) AS tamano,
       count(DISTINCT cliente)                               AS clientes,
       min(fecha)                                            AS desde,
       max(fecha)                                            AS hasta
FROM practica.ventas;
