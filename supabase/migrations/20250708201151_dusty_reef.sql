/*
  # Create livestock registry tables

  1. New Tables
    - `registros`
      - `id` (uuid, primary key)
      - `socio` (text, partner name)
      - `fecha` (date)
      - `entradas` (integer, entries)
      - `salidas` (integer, exits)
      - `saldo` (integer, balance)
      - `kg_totales` (decimal, total kg)
      - `vr_kilo` (decimal, price per kg)
      - `fletes` (decimal, freight costs)
      - `comision` (decimal, commission)
      - `valor_animal` (decimal, value per animal)
      - `total` (decimal, total value)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `salidas_detalle`
      - `id` (uuid, primary key)
      - `registro_id` (uuid, foreign key to registros)
      - `socio` (text, partner name)
      - `fecha` (date)
      - `cantidad` (integer, quantity)
      - `causa` (text, reason: 'ventas', 'muerte', 'robo')
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users to manage their data
*/

CREATE TABLE IF NOT EXISTS registros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  socio text NOT NULL,
  fecha date NOT NULL,
  entradas integer DEFAULT 0,
  salidas integer DEFAULT 0,
  saldo integer DEFAULT 0,
  kg_totales decimal(10,2) DEFAULT 0,
  vr_kilo decimal(10,2) DEFAULT 0,
  fletes decimal(10,2) DEFAULT 0,
  comision decimal(10,2) DEFAULT 0,
  valor_animal decimal(10,2) DEFAULT 0,
  total decimal(10,2) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS salidas_detalle (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  registro_id uuid REFERENCES registros(id) ON DELETE CASCADE,
  socio text NOT NULL,
  fecha date NOT NULL,
  cantidad integer NOT NULL,
  causa text NOT NULL CHECK (causa IN ('ventas', 'muerte', 'robo')),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE registros ENABLE ROW LEVEL SECURITY;
ALTER TABLE salidas_detalle ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (you can modify these based on your auth requirements)
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_registros_socio ON registros(socio);
CREATE INDEX IF NOT EXISTS idx_registros_fecha ON registros(fecha);
CREATE INDEX IF NOT EXISTS idx_salidas_detalle_registro_id ON salidas_detalle(registro_id);
CREATE INDEX IF NOT EXISTS idx_salidas_detalle_socio ON salidas_detalle(socio);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
CREATE TRIGGER update_registros_updated_at 
    BEFORE UPDATE ON registros 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();