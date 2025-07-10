# Registros Ganaderos

Sistema de control de inventario y cálculo de valores para registro ganadero por socios.

## Características

- ✅ Registro de entradas y salidas de ganado por socio
- ✅ Cálculo automático de valores por animal
- ✅ Gestión de detalles de salidas (ventas, muerte, robo)
- ✅ Visualización por socio individual
- ✅ Estadísticas y reportes
- ✅ Interfaz responsive y moderna
- ✅ Base de datos con Supabase

## Tecnologías

- **Frontend**: React + TypeScript + Vite
- **Estilos**: Tailwind CSS
- **Iconos**: Lucide React
- **Base de datos**: Supabase (PostgreSQL)
- **Despliegue**: Netlify

## Instalación

1. Clona el repositorio
```bash
git clone https://github.com/guiguiriosbit/registros-ganaderos2.git
cd registros-ganaderos2
```

2. Instala las dependencias
```bash
npm install
```

3. Configura las variables de entorno
```bash
cp .env.example .env
```

4. Configura Supabase
- Crea un proyecto en [Supabase](https://supabase.com)
- Ejecuta las migraciones en `supabase/migrations/`
- Actualiza las variables de entorno con tus credenciales

5. Ejecuta el proyecto
```bash
npm run dev
```

## Estructura del Proyecto

```
src/
├── components/          # Componentes React
│   ├── ExitReasonsModal.tsx
│   └── ExitDetailsModal.tsx
├── lib/
│   └── supabase.ts     # Configuración de Supabase
├── App.tsx             # Componente principal
└── main.tsx           # Punto de entrada

supabase/
└── migrations/        # Migraciones de base de datos
```

## Base de Datos

El sistema utiliza dos tablas principales:

### `registros`
- Almacena los registros principales de cada socio
- Incluye entradas, salidas, cálculos de valores
- Campos: socio, fecha, entradas, salidas, kg_totales, vr_kilo, fletes, etc.

### `salidas_detalle`
- Detalla las causas específicas de las salidas
- Relacionada con `registros` por foreign key
- Causas: ventas, muerte, robo

## Funcionalidades Principales

### Registro de Datos
- Formulario para ingresar nuevos registros
- Cálculo automático de valores
- Validación de datos

### Visualización por Socio
- Selector de socio para filtrar registros
- Estadísticas individuales
- Historial completo de transacciones

### Gestión de Salidas
- Modal para especificar causas de salidas
- Distribución por tipo (ventas, muerte, robo)
- Visualización de detalles

### Cálculos Automáticos
- Saldo = Entradas - Salidas
- Valor Total = (Kg × Precio/Kg) + (Fletes ÷ Entradas del mismo día)
- Valor por Animal = Valor Total ÷ Entradas

## Despliegue

El proyecto está configurado para desplegarse automáticamente en Netlify cuando se hace push a la rama `main`.

### Variables de Entorno en Netlify

Asegúrate de configurar estas variables en tu panel de Netlify:

- `VITE_SUPABASE_URL`: URL de tu proyecto Supabase
- `VITE_SUPABASE_ANON_KEY`: Clave anónima de Supabase

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT.