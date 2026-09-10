import { useState, useCallback } from 'react';

export const useConfirmDialog = () => {
  const [config, setConfig] = useState({
    isOpen: false,
    title: '',
    message: '',
    confirmText: 'Confirmar',
    cancelText: 'Cancelar',
    variant: 'primary',
    onConfirm: null,
  });

  const confirm = useCallback(({
    title,
    message,
    confirmText,
    cancelText,
    variant = 'primary',
  }) => {
    return new Promise((resolve) => {
      setConfig({
        isOpen: true,
        title,
        message,
        confirmText,
        cancelText,
        variant,
        onConfirm: () => {
          setConfig((prev) => ({ ...prev, isOpen: false }));
          resolve(true);
        },
        onClose: () => {
          setConfig((prev) => ({ ...prev, isOpen: false }));
          resolve(false);
        },
      });
    });
  }, []);

  const close = useCallback(() => {
    setConfig((prev) => ({ ...prev, isOpen: false }));
  }, []);

  return {
    confirmConfig: config,
    confirm,
    closeConfirm: close,
  };
};
