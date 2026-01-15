-- Sample data for testing the Enterprise Portal Application
-- Run these queries in your Supabase SQL Editor to populate test data

-- First, you need to create a test user through the Supabase Auth interface or signup page
-- Then, replace 'YOUR_USER_ID' below with the actual user ID from auth.users table

-- To get your user ID, run this query after creating a user:
-- SELECT id, email FROM auth.users;

-- Insert sample applications
INSERT INTO applications (name, description, icon, url, color) VALUES
('CRM', 'Sistema de gestión de clientes', 'Users', 'https://crm.ejemplo.com', '#3B82F6'),
('ERP', 'Planificación de recursos empresariales', 'Package', 'https://erp.ejemplo.com', '#10B981'),
('Recursos Humanos', 'Gestión de personal y nóminas', 'UserCheck', 'https://rrhh.ejemplo.com', '#F59E0B'),
('Contabilidad', 'Sistema contable y financiero', 'Calculator', 'https://contabilidad.ejemplo.com', '#8B5CF6'),
('Almacén', 'Control de inventario', 'Warehouse', 'https://almacen.ejemplo.com', '#EF4444'),
('Ventas', 'Gestión de ventas y pedidos', 'ShoppingCart', 'https://ventas.ejemplo.com', '#06B6D4'),
('Marketing', 'Campañas y análisis', 'Megaphone', 'https://marketing.ejemplo.com', '#EC4899'),
('Soporte', 'Sistema de tickets', 'HeadphonesIcon', 'https://soporte.ejemplo.com', '#14B8A6'),
('Proyectos', 'Gestión de proyectos', 'FolderKanban', 'https://proyectos.ejemplo.com', '#F97316'),
('Documentos', 'Gestión documental', 'FileText', 'https://documentos.ejemplo.com', '#6366F1'),
('BI Dashboard', 'Business Intelligence', 'BarChart3', 'https://bi.ejemplo.com', '#0EA5E9'),
('Email', 'Correo corporativo', 'Mail', 'https://email.ejemplo.com', '#84CC16');

-- Grant permissions to a user
-- IMPORTANT: Replace 'YOUR_USER_ID' with the actual user ID from auth.users
-- Example: '123e4567-e89b-12d3-a456-426614174000'

INSERT INTO user_permissions (user_id, application_id)
SELECT
  'bce37aa9-4597-497a-ad4b-73855d58bb2f'::uuid, -- Replace with actual user ID
  id
FROM applications
WHERE name IN ('CRM', 'ERP', 'Recursos Humanos', 'Ventas', 'Soporte', 'Documentos');

-- To grant access to ALL applications for a user:
-- INSERT INTO user_permissions (user_id, application_id)
-- SELECT 'YOUR_USER_ID'::uuid, id FROM applications;

-- Verify the data was inserted correctly:
-- SELECT * FROM applications;
-- SELECT * FROM user_permissions;
