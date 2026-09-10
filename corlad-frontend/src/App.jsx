import React, { useState } from 'react';
import { NotificationProvider } from './hooks/useNotification';
import { BasePageLayout } from './components/base/BasePageLayout';
import { PreinscripcionPage } from './features/cli/pages/PreinscripcionPage';
import { CalificacionPage } from './features/cli/pages/CalificacionPage';
import { SeguimientoExpedienteModal } from './features/cli/components/SeguimientoExpedienteModal';

function App() {
  const [currentView, setCurrentView] = useState('CALIF'); // Default a CU-COL-02
  const [trackingModalOpen, setTrackingModalOpen] = useState(false);

  return (
    <NotificationProvider>
      <BasePageLayout
        activeModule="CLI"
        currentView={currentView}
        onViewChange={(view) => setCurrentView(view)}
        onTrackingClick={() => setTrackingModalOpen(true)}
      >
        {currentView === 'PREINSC' ? (
          <PreinscripcionPage />
        ) : (
          <CalificacionPage />
        )}

        <SeguimientoExpedienteModal
          isOpen={trackingModalOpen}
          onClose={() => setTrackingModalOpen(false)}
        />
      </BasePageLayout>
    </NotificationProvider>
  );
}

export default App;
