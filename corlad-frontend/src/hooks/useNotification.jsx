import React, { createContext, useContext, useState, useCallback } from 'react';

const NotificationContext = createContext(null);

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);

  const removeNotification = useCallback((id) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
  }, []);

  const addNotification = useCallback((tipo, mensaje, titulo = '', duracion = 5000) => {
    const id = Date.now() + Math.random().toString(36).substring(2, 9);
    const newNotif = { id, tipo, mensaje, titulo, duracion };
    setNotifications((prev) => [...prev, newNotif]);

    if (duracion > 0) {
      setTimeout(() => {
        removeNotification(id);
      }, duracion);
    }
  }, [removeNotification]);

  const notify = {
    success: (a, b) => {
      const title = b ? a : 'Éxito';
      const msg = b ? b : a;
      addNotification('success', msg, title);
    },
    error: (a, b) => {
      const title = b ? a : 'Error';
      const msg = b ? b : a;
      addNotification('error', msg, title);
    },
    warning: (a, b) => {
      const title = b ? a : 'Advertencia';
      const msg = b ? b : a;
      addNotification('warning', msg, title);
    },
    info: (a, b) => {
      const title = b ? a : 'Información';
      const msg = b ? b : a;
      addNotification('info', msg, title);
    },
  };

  return (
    <NotificationContext.Provider value={{ notifications, removeNotification, notify }}>
      {children}
    </NotificationContext.Provider>
  );
};

export const useNotification = () => {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotification debe ser usado dentro de un NotificationProvider');
  }
  return {
    ...context,
    ...context.notify,
    notify: context.notify,
  };
};

export default useNotification;
