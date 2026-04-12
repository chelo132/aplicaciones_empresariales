-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.productos (
  producto_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre_producto text NOT NULL UNIQUE,
  categoria text NOT NULL CHECK (categoria = ANY (ARRAY['Café'::text, 'Pastelería'::text, 'Accesorios'::text])),
  costo_unidad numeric NOT NULL CHECK (costo_unidad >= 0::numeric),
  precio_venta numeric NOT NULL CHECK (precio_venta >= 0::numeric),
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT productos_pkey PRIMARY KEY (producto_id)
);
CREATE TABLE public.productos_diarios (
  fecha date NOT NULL,
  producto_id bigint NOT NULL,
  unidades_vendidas integer NOT NULL DEFAULT 0 CHECK (unidades_vendidas >= 0),
  total_transacciones_dia integer NOT NULL DEFAULT 0 CHECK (total_transacciones_dia >= 0),
  ingresos_ayer numeric NOT NULL DEFAULT 0 CHECK (ingresos_ayer >= 0::numeric),
  stock_actual integer NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
  merma_diaria integer NOT NULL DEFAULT 0 CHECK (merma_diaria >= 0),
  promedio_venta_diaria numeric NOT NULL DEFAULT 0 CHECK (promedio_venta_diaria >= 0::numeric),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT productos_diarios_pkey PRIMARY KEY (fecha, producto_id),
  CONSTRAINT productos_diarios_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(producto_id)
);