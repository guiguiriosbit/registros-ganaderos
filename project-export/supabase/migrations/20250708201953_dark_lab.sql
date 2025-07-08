/*
  # Crear sistema de registros ganaderos

  1. Nuevas Tablas
    - `registros`
      - `id` (uuid, clave primaria)
      - `socio` (text, nombre del socio)
      - `fecha` (date, fecha del registro)
      - `entradas` (integer, cantidad de animales que entran)
      - `salidas` (integer, cantidad de animales que salen)
      - `saldo` (integer, balance de entradas menos salidas)
      - `kg_totales` (numeric, peso total en kilogramos)
      - `vr_kilo` (numeric, valor por kilogramo)
      - `fletes` (numeric, costo de fletes)
      - `comision` (numeric, comisión)
      - `valor_animal` (numeric, valor calculado por animal)
      - `total` (numeric, valor total calculado)
      - `created_at` (timestamp, fecha de creación)
      - `updated_at` (timestamp, fecha de actualización)

    - `salidas_detalle`
      - `id` (uuid, clave primaria)
      - `registro_id` (uuid, referencia al registro)
      - `socio` (text, nombre del socio)
      - `fecha` (date, fecha de la salida)
      - `cantidad` (integer, cantidad de animales)
      - `causa` (text, causa de la salida: ventas, muerte, robo)
      - `created_at` (timestamp, fecha de creación)

  2. Seguridad
    - Habilitar RLS en ambas tablas
    - Permitir todas las operaciones para usuarios públicos (para simplicidad)

  3. Índices
    - Índices en campos de búsqueda frecuente (socio, fecha)
    - Índice en la relación entre tablas

  4. Funciones
    - Trigger para actualizar automáticamente updated_at
*/

-- Crear función para actualizar updated_at
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

-- Crear políticas de seguridad (permitir todas las operaciones para simplicidad)
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

-- Crear trigger para actualizar updated_at automáticamente
CREATE TRIGGER update_registros_updated_at
  BEFORE UPDATE ON registros
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();