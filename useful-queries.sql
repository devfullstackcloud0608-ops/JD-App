-- Useful SQL Queries for Managing the Enterprise Portal

-- ============================================
-- USER MANAGEMENT
-- ============================================

-- View all users in the system
SELECT id, email, created_at, last_sign_in_at
FROM auth.users
ORDER BY created_at DESC;

-- View user permissions with application details
SELECT
  u.email,
  a.name as application_name,
  a.description,
  up.created_at as access_granted_at
FROM user_permissions up
JOIN auth.users u ON u.id = up.user_id
JOIN applications a ON a.id = up.application_id
ORDER BY u.email, a.name;

-- ============================================
-- APPLICATION MANAGEMENT
-- ============================================

-- View all applications
SELECT * FROM applications ORDER BY name;

-- View active applications only
SELECT * FROM applications WHERE is_active = true ORDER BY name;

-- Count users per application
SELECT
  a.name,
  a.description,
  COUNT(up.user_id) as user_count
FROM applications a
LEFT JOIN user_permissions up ON a.id = up.application_id
GROUP BY a.id, a.name, a.description
ORDER BY user_count DESC, a.name;

-- ============================================
-- GRANT/REVOKE PERMISSIONS
-- ============================================

-- Grant access to a specific application for a user
INSERT INTO user_permissions (user_id, application_id)
VALUES (
  'user-id-here'::uuid,
  (SELECT id FROM applications WHERE name = 'CRM')
);

-- Grant access to ALL applications for a user
INSERT INTO user_permissions (user_id, application_id)
SELECT 'user-id-here'::uuid, id
FROM applications
WHERE is_active = true;

-- Revoke access to a specific application
DELETE FROM user_permissions
WHERE user_id = 'user-id-here'::uuid
AND application_id = (SELECT id FROM applications WHERE name = 'CRM');

-- Revoke ALL access for a user
DELETE FROM user_permissions
WHERE user_id = 'user-id-here'::uuid;

-- ============================================
-- BULK OPERATIONS
-- ============================================

-- Grant multiple users access to a specific application
INSERT INTO user_permissions (user_id, application_id)
SELECT
  u.id,
  (SELECT id FROM applications WHERE name = 'CRM')
FROM auth.users u
WHERE u.email IN ('user1@company.com', 'user2@company.com', 'user3@company.com');

-- Copy permissions from one user to another
INSERT INTO user_permissions (user_id, application_id)
SELECT
  'new-user-id'::uuid,
  application_id
FROM user_permissions
WHERE user_id = 'template-user-id'::uuid;

-- ============================================
-- APPLICATION ADMINISTRATION
-- ============================================

-- Add a new application
INSERT INTO applications (name, description, icon, url, color)
VALUES (
  'Nueva App',
  'Descripción de la aplicación',
  'IconName',
  'https://app.ejemplo.com',
  '#3B82F6'
);

-- Update application details
UPDATE applications
SET
  name = 'Nuevo Nombre',
  description = 'Nueva descripción',
  icon = 'NewIcon',
  color = '#10B981'
WHERE name = 'App Antigua';

-- Deactivate an application (users won't see it)
UPDATE applications
SET is_active = false
WHERE name = 'App Name';

-- Reactivate an application
UPDATE applications
SET is_active = true
WHERE name = 'App Name';

-- Delete an application (and all permissions)
DELETE FROM applications WHERE name = 'App Name';

-- ============================================
-- REPORTS AND ANALYTICS
-- ============================================

-- Applications with no users
SELECT a.name, a.description
FROM applications a
LEFT JOIN user_permissions up ON a.id = up.application_id
WHERE up.id IS NULL
AND a.is_active = true;

-- Users with no application access
SELECT u.email, u.created_at
FROM auth.users u
LEFT JOIN user_permissions up ON u.id = up.user_id
WHERE up.id IS NULL;

-- Most used applications (by user count)
SELECT
  a.name,
  COUNT(up.user_id) as user_count,
  a.color,
  a.icon
FROM applications a
LEFT JOIN user_permissions up ON a.id = up.application_id
WHERE a.is_active = true
GROUP BY a.id
ORDER BY user_count DESC;

-- Users with access to specific application
SELECT
  u.email,
  u.created_at,
  up.created_at as access_granted
FROM user_permissions up
JOIN auth.users u ON u.id = up.user_id
WHERE up.application_id = (SELECT id FROM applications WHERE name = 'CRM')
ORDER BY u.email;

-- ============================================
-- MAINTENANCE
-- ============================================

-- Clean up orphaned permissions (if a user is deleted from auth.users)
-- This should be automatic due to CASCADE, but just in case:
DELETE FROM user_permissions
WHERE user_id NOT IN (SELECT id FROM auth.users);

-- Update all application timestamps
UPDATE applications
SET updated_at = now()
WHERE id IS NOT NULL;

-- Reset all application colors to blue
UPDATE applications
SET color = '#3B82F6';

-- ============================================
-- TESTING QUERIES
-- ============================================

-- Check RLS is working (run this as a specific user)
SET request.jwt.claims.sub = 'user-id-here';
SELECT * FROM applications;
SELECT * FROM user_permissions;

-- Verify data integrity
SELECT
  'Applications' as table_name,
  COUNT(*) as total_rows
FROM applications
UNION ALL
SELECT
  'User Permissions',
  COUNT(*)
FROM user_permissions
UNION ALL
SELECT
  'Users',
  COUNT(*)
FROM auth.users;
