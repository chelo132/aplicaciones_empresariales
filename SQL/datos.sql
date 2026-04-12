BEGIN;

WITH productos_seed AS (
  INSERT INTO public.productos (
    nombre_producto, categoria, costo_unidad, precio_venta, activo
  )
  VALUES
    ('Espresso El Grano', 'Café',         1.00, 2.50, true),
    ('Americano Clásico', 'Café',        1.10, 2.75, true),
    ('Cappuccino Nube', 'Café',         1.20, 3.25, true),
    ('Latte Vainilla', 'Café',          1.30, 3.50, true),
    ('Mocha Chocolate', 'Café',         1.40, 3.75, true),

    ('Cortado Doble', 'Café',            1.15, 2.95, true),
    ('Frappe Caramelo', 'Café',         1.60, 4.25, true),
    ('Té Matcha', 'Café',               1.40, 3.90, true),

    ('Croissant Mantequilla', 'Pastelería', 0.80, 2.25, true),
    ('Donas Glaseadas', 'Pastelería',       0.70, 2.00, true),
    ('Tarta de Queso', 'Pastelería',        1.20, 3.75, true),
    ('Brownie Chocolate', 'Pastelería',    0.90, 2.90, true),

    ('Galletas surtidas', 'Pastelería',     0.60, 1.95, true),
    ('Eclair Crema', 'Pastelería',         1.00, 2.85, true),
    ('Pan de Plátano', 'Pastelería',       0.85, 2.60, true),
    ('Tiramisú vaso', 'Pastelería',       1.10, 3.30, true),

    ('Taza El Grano', 'Accesorios',     3.00, 7.50, true),
    ('Cucharilla de Barista', 'Accesorios', 1.50, 4.00, true),
    ('Bolsa de Café 250g', 'Accesorios', 5.00, 12.50, true),
    ('Filtro Reutilizable', 'Accesorios', 2.20, 5.50, true)

  ON CONFLICT (nombre_producto) DO UPDATE
    SET categoria = EXCLUDED.categoria,
        costo_unidad = EXCLUDED.costo_unidad,
        precio_venta = EXCLUDED.precio_venta,
        activo = EXCLUDED.activo
  RETURNING producto_id, nombre_producto
),
productos_seed_num AS (
  -- Fijamos el orden por nombre_producto para hacer el mapeo estable
  SELECT
    producto_id,
    ROW_NUMBER() OVER (ORDER BY nombre_producto) AS rn
  FROM productos_seed
),
operativos AS (
  SELECT * FROM (
    VALUES
      -- (unidades_vendidas, total_transacciones_dia, ingresos_ayer, stock_actual, merma_diaria, promedio_venta_diaria)
      (120,  95, 120 * 2.50,  50,  2, 20),
      ( 95,  75,  95 * 2.75,  45,  2, 20),
      (110,  85, 110 * 3.25,  55,  2, 20),
      ( 90,  70,  90 * 3.50,  45,  3, 18),
      ( 80,  60,  80 * 3.75,  40,  3, 16),

      (100,  80, 100 * 2.95,  48,  2, 18),
      ( 70,  55,  70 * 4.25,  40,  5, 14),
      ( 60,  45,  60 * 3.90,  35,  3, 12),

      (140, 105, 140 * 2.25,  60,  4, 25),
      (160, 120, 160 * 2.00,  70,  5, 25),
      ( 90,  70,  90 * 3.75,  50,  6, 18),
      (120,  90, 120 * 2.90,  58,  4, 20),

      (130,  95, 130 * 1.95,  62,  6, 22),
      ( 85,  65,  85 * 2.85,  45,  4, 15),
      ( 75,  60,  75 * 2.60,  38,  8, 13),
      ( 65,  50,  65 * 3.30,  35,  6, 12),

      ( 40,  30,  40 * 7.50,  55,  1, 20),
      ( 25,  20,  25 * 4.00,  45,  1, 16),
      ( 20,  15,  20 * 12.50, 55,  2, 18),
      ( 30,  25,  30 * 5.50,  50,  2, 18)
  ) s(
    unidades_vendidas,
    total_transacciones_dia,
    ingresos_ayer,
    stock_actual,
    merma_diaria,
    promedio_venta_diaria
  )
),
operativos_num AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS rn
  FROM operativos
)
INSERT INTO public.productos_diarios (
  fecha,
  producto_id,
  unidades_vendidas,
  total_transacciones_dia,
  ingresos_ayer,
  stock_actual,
  merma_diaria,
  promedio_venta_diaria
)
SELECT
  CURRENT_DATE,
  psn.producto_id,
  o.unidades_vendidas,
  o.total_transacciones_dia,
  o.ingresos_ayer,
  o.stock_actual,
  o.merma_diaria,
  o.promedio_venta_diaria
FROM productos_seed_num psn
JOIN operativos_num o
  ON o.rn = psn.rn;

COMMIT;