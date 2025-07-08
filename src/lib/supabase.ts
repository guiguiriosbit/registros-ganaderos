import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface Registro {
  id: string;
  socio: string;
  fecha: string;
  entradas: number;
  salidas: number;
  saldo: number;
  kg_totales: number;
  vr_kilo: number;
  fletes: number;
  comision: number;
  valor_animal: number;
  total: number;
  created_at?: string;
  updated_at?: string;
}

export interface SalidaDetalle {
  id: string;
  registro_id: string;
  socio: string;
  fecha: string;
  cantidad: number;
  causa: 'ventas' | 'muerte' | 'robo';
  created_at?: string;
}

export type CausaSalida = 'ventas' | 'muerte' | 'robo';

export const causaSalidaLabels: Record<CausaSalida, string> = {
  ventas: 'Ventas',
  muerte: 'Muerte',
  robo: 'Robo'
};