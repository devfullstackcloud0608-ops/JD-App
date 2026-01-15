export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      applications: {
        Row: {
          id: string
          name: string
          description: string
          icon: string
          url: string
          color: string
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string
          icon?: string
          url: string
          color?: string
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string
          icon?: string
          url?: string
          color?: string
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      user_permissions: {
        Row: {
          id: string
          user_id: string
          application_id: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          application_id: string
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          application_id?: string
          created_at?: string
        }
      }
    }
  }
}
