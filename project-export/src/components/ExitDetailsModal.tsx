import React from 'react';
import { X, DollarSign, Skull, Shield } from 'lucide-react';
import { SalidaDetalle, causaSalidaLabels } from '../lib/supabase';

interface ExitDetailsModalProps {
  isOpen: boolean;
  onClose: () => void;
  exitDetails: SalidaDetalle[];
  socio: string;
  fecha: string;
  totalExits: number;
}

const ExitDetailsModal: React.FC<ExitDetailsModalProps> = ({
  isOpen,
  onClose,
  exitDetails,
  socio,
  fecha,
  totalExits
}) => {
  if (!isOpen) return null;

  const getIconForCause = (causa: string) => {
    switch (causa) {
      case 'ventas':
        return <DollarSign className="w-5 h-5 text-green-600" />;
      case 'muerte':
        return <Skull className="w-5 h-5 text-red-600" />;
      case 'robo':
        return <Shield className="w-5 h-5 text-orange-600" />;
      default:
        return null;
    }
  };

  const getColorForCause = (causa: string) => {
    switch (causa) {
      case 'ventas':
        return 'bg-green-50 border-green-200 text-green-800';
      case 'muerte':
        return 'bg-red-50 border-red-200 text-red-800';
      case 'robo':
        return 'bg-orange-50 border-orange-200 text-orange-800';
      default:
        return 'bg-gray-50 border-gray-200 text-gray-800';
    }
  };

  // Group by cause and sum quantities
  const groupedDetails = exitDetails.reduce((acc, detail) => {
    if (!acc[detail.causa]) {
      acc[detail.causa] = 0;
    }
    acc[detail.causa] += detail.cantidad;
    return acc;
  }, {} as Record<string, number>);

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-md w-full">
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">
              Detalle de Salidas
            </h3>
            <p className="text-sm text-gray-600 mt-1">
              {socio} - {new Date(fecha + 'T00:00:00').toLocaleDateString('es-CO')}
            </p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6">
          <div className="mb-4">
            <div className="text-center">
              <span className="text-2xl font-bold text-gray-900">{totalExits}</span>
              <p className="text-sm text-gray-600">Total de salidas</p>
            </div>
          </div>

          {exitDetails.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-gray-500">No hay detalles de salidas registrados</p>
            </div>
          ) : (
            <div className="space-y-3">
              {Object.entries(groupedDetails).map(([causa, cantidad]) => (
                <div
                  key={causa}
                  className={`p-4 rounded-lg border-2 ${getColorForCause(causa)}`}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      {getIconForCause(causa)}
                      <span className="ml-2 font-medium">
                        {causaSalidaLabels[causa as keyof typeof causaSalidaLabels] || causa}
                      </span>
                    </div>
                    <span className="text-lg font-bold">
                      {cantidad}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="mt-6 pt-4 border-t border-gray-200">
            <button
              onClick={onClose}
              className="w-full px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ExitDetailsModal;