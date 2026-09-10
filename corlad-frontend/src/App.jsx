import React, { useState } from 'react';
import { NotificationProvider } from './hooks/useNotification';
import { BasePageLayout } from './components/base/BasePageLayout';
import { PreinscripcionPage } from './features/cli/pages/PreinscripcionPage';
import { CalificacionPage } from './features/cli/pages/CalificacionPage';
import { MatriculacionPage } from './features/cli/pages/MatriculacionPage';
import { SeguimientoExpedienteModal } from './features/cli/components/SeguimientoExpedienteModal';

function App() {
  const [currentView, setCurrentView] = useState('MATRIC'); // Default al nuevo CU-COL-03
  const [trackingModalOpen, setTrackingModalOpen] = useState(false);

  return (
    <NotificationProvider>
      <BasePageLayout
        activeModule="CLI"
        currentView={currentView}
        onViewChange={(view) => setCurrentView(view)}
        onTrackingClick={() => setTrackingModalOpen(true)}
      >
        {currentView === 'PREINSC' && <PreinscripcionPage />}
        {currentView === 'CALIF' && <CalificacionPage />}
        {currentView === 'MATRIC' && <MatriculacionPage />}

        <SeguimientoExpedienteModal
          isOpen={trackingModalOpen}
          onClose={() => setTrackingModalOpen(false)}
        />
      </BasePageLayout>
    </NotificationProvider>
  );
}

export default App;
