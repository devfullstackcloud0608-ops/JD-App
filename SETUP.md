# Portal Empresarial - Guía de Configuración

## Descripción
Portal centralizado para gestionar el acceso a todas las aplicaciones de tu empresa. Sistema con autenticación, permisos por usuario y diseño responsive.

## Configuración Inicial

### 1. Base de Datos
Las tablas ya están creadas en tu base de datos Supabase:
- `applications` - Almacena las aplicaciones disponibles
- `user_permissions` - Define qué usuarios pueden acceder a cada aplicación

### 2. Crear Usuario de Prueba

Para probar la aplicación, necesitas crear un usuario:

**Opción A: Desde la interfaz**
1. La aplicación incluye una página de login
2. Usa las credenciales de un usuario existente en Supabase Auth

**Opción B: Desde Supabase Dashboard**
1. Ve a Authentication > Users
2. Crea un nuevo usuario con email y contraseña
3. Anota el ID del usuario (lo necesitarás para el siguiente paso)

### 3. Cargar Aplicaciones de Ejemplo

1. Abre el archivo `sample-data.sql`
2. Ve a tu proyecto Supabase > SQL Editor
3. Copia y pega el contenido del archivo
4. **IMPORTANTE**: Reemplaza `'YOUR_USER_ID'` con el ID real del usuario que creaste
5. Ejecuta el script

Esto creará 12 aplicaciones de ejemplo:
- CRM
- ERP
- Recursos Humanos
- Contabilidad
- Almacén
- Ventas
- Marketing
- Soporte
- Proyectos
- Documentos
- BI Dashboard
- Email

### 4. Probar la Aplicación

1. Inicia sesión con el usuario que creaste
2. Verás las aplicaciones a las que tienes acceso
3. Haz clic en cualquier aplicación para abrirla (se abrirá en una nueva pestaña con los datos de autenticación en la URL)

## Gestión de Aplicaciones y Permisos

### Agregar una Nueva Aplicación

```sql
INSERT INTO applications (name, description, icon, url, color)
VALUES (
  'Nombre de la App',
  'Descripción',
  'IconName', -- Nombre del icono de lucide-react
  'https://url-de-tu-app.com',
  '#HEX_COLOR'
);
```

### Dar Acceso a un Usuario

```sql
INSERT INTO user_permissions (user_id, application_id)
VALUES (
  'user-id-here'::uuid,
  'application-id-here'::uuid
);
```

### Iconos Disponibles
Usa cualquier icono de lucide-react: https://lucide.dev/icons/
Ejemplos: `Users`, `Package`, `Mail`, `Settings`, `Database`, etc.

## Seguridad

- Row Level Security (RLS) está activado
- Los usuarios solo pueden ver las aplicaciones a las que tienen permisos
- Las credenciales se pasan de forma segura a través de parámetros URL
- La autenticación usa Supabase Auth (email/password)

## Arquitectura

### Frontend
- React + TypeScript
- Tailwind CSS para estilos
- Lucide React para iconos
- Diseño responsive (mobile, tablet, desktop)

### Backend
- Supabase (PostgreSQL)
- Supabase Auth para autenticación
- Row Level Security para control de accesos

### Flujo de Autenticación
1. Usuario ingresa email y contraseña
2. Supabase valida las credenciales
3. Se obtiene la sesión y el token
4. Se cargan las aplicaciones permitidas
5. Al hacer clic en una app, se abre con los datos de sesión

## Personalización

### Cambiar Colores de una Aplicación
```sql
UPDATE applications
SET color = '#NEW_COLOR'
WHERE name = 'Nombre de la App';
```

### Cambiar Icono de una Aplicación
```sql
UPDATE applications
SET icon = 'NewIconName'
WHERE name = 'Nombre de la App';
```

### Desactivar una Aplicación
```sql
UPDATE applications
SET is_active = false
WHERE name = 'Nombre de la App';
```

## Estructura del Proyecto

```
src/
├── components/
│   ├── LoginPage.tsx      # Página de inicio de sesión
│   └── Dashboard.tsx      # Dashboard principal con grid de apps
├── contexts/
│   └── AuthContext.tsx    # Contexto de autenticación
├── lib/
│   ├── supabase.ts        # Cliente de Supabase
│   └── database.types.ts  # Tipos de TypeScript
├── App.tsx                # Componente principal
└── main.tsx               # Punto de entrada
```

## Soporte

Para agregar más funcionalidades o resolver problemas, consulta:
- Documentación de Supabase: https://supabase.com/docs
- Documentación de React: https://react.dev
- Lucide Icons: https://lucide.dev
