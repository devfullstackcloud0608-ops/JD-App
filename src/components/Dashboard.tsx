import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { LogOut, Grid3x3, Loader2 } from 'lucide-react';
import * as Icons from 'lucide-react';
import type { Database } from '../lib/database.types';

type Application = Database['public']['Tables']['applications']['Row'];

export function Dashboard() {
  const { user, session, signOut } = useAuth();
  const [applications, setApplications] = useState<Application[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadApplications();
  }, []);

  const loadApplications = async () => {
    try {
      const { data, error } = await supabase
        .from('applications')
        .select('*')
        .eq('is_active', true)
        .order('name');

      if (error) throw error;

      setApplications(data || []);
    } catch (err) {
      setError('Error al cargar las aplicaciones');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleAppClick = (app: Application) => {
    const urlWithAuth = new URL(app.url);

    if (session) {
      urlWithAuth.searchParams.set('access_token', session.access_token);
      urlWithAuth.searchParams.set('user_email', user?.email || '');
      urlWithAuth.searchParams.set('user_id', user?.id || '');
    }

    window.open(urlWithAuth.toString(), '_blank');
  };

  const getIcon = (iconName: string) => {
    const Icon = (Icons as any)[iconName] || Icons.Box;
    return Icon;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      <nav className="bg-white border-b border-gray-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center">
                <Grid3x3 className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Portal Empresarial</h1>
                <p className="text-xs text-gray-500">Tus aplicaciones</p>
              </div>
            </div>

            <div className="flex items-center space-x-4">
              <div className="text-right hidden sm:block">
                <p className="text-sm font-medium text-gray-900">{user?.email}</p>
                <p className="text-xs text-gray-500">Usuario autenticado</p>
              </div>
              <button
                onClick={signOut}
                className="flex items-center space-x-2 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors duration-200"
              >
                <LogOut className="w-4 h-4" />
                <span className="hidden sm:inline">Cerrar sesión</span>
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Mis Aplicaciones</h2>
          <p className="text-gray-600">Selecciona una aplicación para acceder</p>
        </div>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <Loader2 className="w-12 h-12 text-blue-500 animate-spin mx-auto mb-4" />
              <p className="text-gray-600">Cargando aplicaciones...</p>
            </div>
          </div>
        ) : error ? (
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <p className="text-red-800">{error}</p>
          </div>
        ) : applications.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-12 text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Grid3x3 className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">No hay aplicaciones disponibles</h3>
            <p className="text-gray-600">No tienes acceso a ninguna aplicación en este momento.</p>
            <p className="text-sm text-gray-500 mt-2">Contacta con tu administrador para obtener permisos.</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4 sm:gap-6">
            {applications.map((app) => {
              const Icon = getIcon(app.icon);
              return (
                <button
                  key={app.id}
                  onClick={() => handleAppClick(app)}
                  className="group relative bg-white rounded-2xl p-6 shadow-sm border border-gray-200 hover:shadow-xl hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                  style={{
                    '--app-color': app.color,
                  } as React.CSSProperties}
                >
                  <div className="aspect-square flex flex-col items-center justify-center space-y-3">
                    <div
                      className="w-14 h-14 sm:w-16 sm:h-16 rounded-2xl flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300"
                      style={{ backgroundColor: app.color }}
                    >
                      <Icon className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                    </div>
                    <div className="text-center w-full">
                      <h3 className="font-semibold text-gray-900 text-sm sm:text-base line-clamp-2 mb-1">
                        {app.name}
                      </h3>
                      {app.description && (
                        <p className="text-xs text-gray-500 line-clamp-2">
                          {app.description}
                        </p>
                      )}
                    </div>
                  </div>

                  <div className="absolute inset-0 rounded-2xl bg-gradient-to-t from-black/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"></div>
                </button>
              );
            })}
          </div>
        )}
      </main>

      <footer className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 mt-12">
        <div className="border-t border-gray-200 pt-6 text-center">
          <p className="text-sm text-gray-500">
            Portal Empresarial v1.0 - Sistema de gestión centralizado de aplicaciones
          </p>
        </div>
      </footer>
    </div>
  );
}
