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
    success: (msg, title = 'Éxito') => addNotification('success', msg, title),
    error: (msg, title = 'Error') => addNotification('error', msg, title),
    warning: (msg, title = 'Advertencia') => addNotification('warning', msg, title),
    info: (msg, title = 'Información') => addNotification('info', msg, title),
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
  return context;
};
