/*
  # Crear esquema para sistema de registros ganaderos

  1. Nuevas Tablas
    - `registros`
      - `id` (uuid, primary key)
      - `socio` (text, required)
      - `fecha` (date, required)
      - `entradas` (integer, default 0)
      - `salidas` (integer, default 0)
      - `saldo` (integer, default 0)
      - `kg_totales` (numeric, default 0)
      - `vr_kilo` (numeric, default 0)
      - `fletes` (numeric, default 0)
      - `comision` (numeric, default 0)
      - `valor_animal` (numeric, default 0)
      - `total` (numeric, default 0)
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())
    
    - `salidas_detalle`
      - `id` (uuid, primary key)
      - `registro_id` (uuid, foreign key to registros)
      - `socio` (text, required)
      - `fecha` (date, required)
      - `cantidad` (integer, required)
      - `causa` (text, check constraint for ventas/muerte/robo)
      - `created_at` (timestamptz, default now())

  2. Seguridad
    - Habilitar RLS en ambas tablas
    - Políticas para permitir todas las operaciones a usuarios públicos

  3. Índices
    - Índices en campos de búsqueda frecuente para optimizar consultas

  4. Triggers
    - Trigger para actualizar updated_at automáticamente
*/

-- Crear función para actualizar updated_at si no existe
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear tabla registros
CREATE TABLE IF NOT EXISTS registros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  socio text NOT NULL,
  fecha date NOT NULL,
  entradas integer DEFAULT 0,
  salidas integer DEFAULT 0,
  saldo integer DEFAULT 0,
  kg_totales numeric(10,2) DEFAULT 0,
  vr_kilo numeric(10,2) DEFAULT 0,
  fletes numeric(10,2) DEFAULT 0,
  comision numeric(10,2) DEFAULT 0,
  valor_animal numeric(10,2) DEFAULT 0,
  total numeric(10,2) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Crear tabla salidas_detalle
CREATE TABLE IF NOT EXISTS salidas_detalle (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  registro_id uuid REFERENCES registros(id) ON DELETE CASCADE,
  socio text NOT NULL,
  fecha date NOT NULL,
  cantidad integer NOT NULL,
  causa text NOT NULL CHECK (causa IN ('ventas', 'muerte', 'robo')),
  created_at timestamptz DEFAULT now()
);

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_registros_socio ON registros(socio);
CREATE INDEX IF NOT EXISTS idx_registros_fecha ON registros(fecha);
CREATE INDEX IF NOT EXISTS idx_salidas_detalle_registro_id ON salidas_detalle(registro_id);
CREATE INDEX IF NOT EXISTS idx_salidas_detalle_socio ON salidas_detalle(socio);

-- Habilitar Row Level Security
ALTER TABLE registros ENABLE ROW LEVEL SECURITY;
ALTER TABLE salidas_detalle ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si existen y crear nuevas
DO $$
BEGIN
  -- Eliminar política de registros si existe
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'registros' 
    AND policyname = 'Allow all operations on registros'
  ) THEN
    DROP POLICY "Allow all operations on registros" ON registros;
  END IF;
  
  -- Eliminar política de salidas_detalle si existe
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'salidas_detalle' 
    AND policyname = 'Allow all operations on salidas_detalle'
  ) THEN
    DROP POLICY "Allow all operations on salidas_detalle" ON salidas_detalle;
  END IF;
END $$;

-- Crear políticas de seguridad
CREATE POLICY "Allow all operations on registros"
  ON registros
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all operations on salidas_detalle"
  ON salidas_detalle
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- Crear trigger para actualizar updated_at automáticamente si no existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_registros_updated_at'
  ) THEN
    CREATE TRIGGER update_registros_updated_at
      BEFORE UPDATE ON registros
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;