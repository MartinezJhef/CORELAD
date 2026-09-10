import React from 'react';
import { BaseModal } from './BaseModal';
import { BaseButton } from './BaseButton';
import { AlertTriangle } from 'lucide-react';

export const BaseConfirmDialog = ({
  isOpen,
  onClose,
  onConfirm,
  title = '¿Está seguro de continuar?',
  message = 'Esta acción no se puede deshacer.',
  confirmText = 'Confirmar',
  cancelText = 'Cancelar',
  variant = 'primary',
  isLoading = false,
}) => {
  return (
    <BaseModal
      isOpen={isOpen}
      onClose={onClose}
      title={title}
      maxWidth="480px"
      footer={
        <>
          <BaseButton variant="ghost" onClick={onClose} disabled={isLoading}>
            {cancelText}
          </BaseButton>
          <BaseButton
            variant={variant}
            onClick={onConfirm}
            isLoading={isLoading}
          >
            {confirmText}
          </BaseButton>
        </>
      }
    >
      <div style={{ display: 'flex', gap: '1rem', alignItems: 'flex-start' }}>
        <div
          style={{
            width: '42px',
            height: '42px',
            borderRadius: 'var(--radius-full)',
            background: 'rgba(245, 166, 4, 0.15)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--color-amarillo-zapallo)',
            flexShrink: 0,
          }}
        >
          <AlertTriangle size={22} />
        </div>
        <div>
          <p style={{ margin: 0, fontSize: '0.9375rem', color: 'var(--color-gris-carbon)' }}>
            {message}
          </p>
        </div>
      </div>
    </BaseModal>
  );
};
