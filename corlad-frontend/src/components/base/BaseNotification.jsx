import React, { useEffect, useRef } from 'react';
import { useNotification } from '../../hooks/useNotification';
import { CheckCircle2, AlertTriangle, XCircle, Info, X } from 'lucide-react';
import gsap from 'gsap';

export const BaseNotification = () => {
  const { notifications, removeNotification } = useNotification();

  return (
    <div style={{
      position: 'fixed',
      top: '1.5rem',
      right: '1.5rem',
      zIndex: 9999,
      display: 'flex',
      flexDirection: 'column',
      gap: '0.75rem',
      maxWidth: '420px',
      width: 'calc(100% - 3rem)',
      pointerEvents: 'none',
    }}>
      {notifications.map((item) => (
        <NotificationItem key={item.id} item={item} onDismiss={() => removeNotification(item.id)} />
      ))}
    </div>
  );
};

const NotificationItem = ({ item, onDismiss }) => {
  const itemRef = useRef(null);

  useEffect(() => {
    if (itemRef.current) {
      gsap.fromTo(
        itemRef.current,
        { opacity: 0, x: 50, scale: 0.95 },
        { opacity: 1, x: 0, scale: 1, duration: 0.35, ease: 'back.out(1.5)' }
      );
    }
  }, []);

  const config = {
    success: {
      border: 'var(--color-verde-uo)',
      icon: <CheckCircle2 size={22} color="var(--color-verde-uo)" />,
      bg: '#F0FDF4',
    },
    error: {
      border: 'var(--color-peligro)',
      icon: <XCircle size={22} color="var(--color-peligro)" />,
      bg: '#FEF2F2',
    },
    warning: {
      border: 'var(--color-amarillo-zapallo)',
      icon: <AlertTriangle size={22} color="var(--color-amarillo-zapallo)" />,
      bg: '#FFFBEB',
    },
    info: {
      border: 'var(--color-info)',
      icon: <Info size={22} color="var(--color-info)" />,
      bg: '#F0F9FF',
    },
  }[item.tipo] || {
    border: 'var(--color-verde-uo)',
    icon: <Info size={22} color="var(--color-verde-uo)" />,
    bg: '#FFFFFF',
  };

  return (
    <div
      ref={itemRef}
      style={{
        pointerEvents: 'auto',
        background: config.bg,
        borderLeft: `5px solid ${config.border}`,
        borderTop: '1px solid rgba(0,0,0,0.06)',
        borderRight: '1px solid rgba(0,0,0,0.06)',
        borderBottom: '1px solid rgba(0,0,0,0.06)',
        borderRadius: 'var(--radius-md)',
        padding: '1rem',
        boxShadow: 'var(--shadow-lg)',
        display: 'flex',
        alignItems: 'flex-start',
        gap: '0.85rem',
        position: 'relative',
      }}
    >
      <div style={{ flexShrink: 0, marginTop: '2px' }}>{config.icon}</div>
      <div style={{ flex: 1 }}>
        {item.titulo && (
          <h4 style={{ margin: '0 0 0.25rem 0', fontSize: '0.95rem', fontWeight: 600, color: 'var(--color-negro-puro)' }}>
            {item.titulo}
          </h4>
        )}
        <p style={{ margin: 0, fontSize: '0.875rem', color: 'var(--color-gris-carbon)', wordBreak: 'break-word' }}>
          {item.mensaje}
        </p>
      </div>
      <button
        type="button"
        onClick={onDismiss}
        aria-label="Cerrar notificación"
        style={{
          background: 'transparent',
          border: 'none',
          cursor: 'pointer',
          padding: '2px',
          color: 'var(--text-muted)',
          display: 'flex',
        }}
      >
        <X size={16} />
      </button>
    </div>
  );
};
