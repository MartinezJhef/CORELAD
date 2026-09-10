import React, { useState } from 'react';
import { NotificationProvider } from './hooks/useNotification';
import { BasePageLayout } from './components/base/BasePageLayout';
import { PreinscripcionPage } from './features/cli/pages/PreinscripcionPage';
import { SeguimientoExpedienteModal } from './features/cli/components/SeguimientoExpedienteModal';

function App() {
  const [trackingModalOpen, setTrackingModalOpen] = useState(false);

  return (
    <NotificationProvider>
      <BasePageLayout activeModule="CLI" onTrackingClick={() => setTrackingModalOpen(true)}>
        <PreinscripcionPage />
        <SeguimientoExpedienteModal
          isOpen={trackingModalOpen}
          onClose={() => setTrackingModalOpen(false)}
        />
      </BasePageLayout>
    </NotificationProvider>
  );
}

export default App;
