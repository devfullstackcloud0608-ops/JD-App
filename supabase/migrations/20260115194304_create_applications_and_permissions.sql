/*
  # Create Enterprise Application Portal Schema

  1. New Tables
    - `applications`
      - `id` (uuid, primary key) - Unique identifier for each application
      - `name` (text) - Application name
      - `description` (text) - Brief description of the application
      - `icon` (text) - Icon identifier from lucide-react
      - `url` (text) - URL to redirect when clicking the app
      - `color` (text) - Background color for the app card
      - `is_active` (boolean) - Whether the application is currently active
      - `created_at` (timestamptz) - Timestamp of creation
      - `updated_at` (timestamptz) - Timestamp of last update
    
    - `user_permissions`
      - `id` (uuid, primary key) - Unique identifier for the permission
      - `user_id` (uuid, foreign key) - Reference to auth.users
      - `application_id` (uuid, foreign key) - Reference to applications
      - `created_at` (timestamptz) - Timestamp when permission was granted
      - Unique constraint on (user_id, application_id)
  
  2. Security
    - Enable RLS on both tables
    - Users can only view applications they have permission to access
    - Only authenticated users can access their permitted applications
  
  3. Indexes
    - Index on user_id for faster permission lookups
    - Index on application_id for faster queries
*/

-- Create applications table
CREATE TABLE IF NOT EXISTS applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text DEFAULT '',
  icon text NOT NULL DEFAULT 'Box',
  url text NOT NULL,
  color text DEFAULT '#3B82F6',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create user_permissions table
CREATE TABLE IF NOT EXISTS user_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  application_id uuid NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, application_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_permissions_user_id ON user_permissions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_permissions_app_id ON user_permissions(application_id);

-- Enable Row Level Security
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_permissions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for applications table
CREATE POLICY "Users can view active applications they have permission to access"
  ON applications FOR SELECT
  TO authenticated
  USING (
    is_active = true AND
    EXISTS (
      SELECT 1 FROM user_permissions
      WHERE user_permissions.application_id = applications.id
      AND user_permissions.user_id = auth.uid()
    )
  );

-- RLS Policies for user_permissions table
CREATE POLICY "Users can view their own permissions"
  ON user_permissions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_applications_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
