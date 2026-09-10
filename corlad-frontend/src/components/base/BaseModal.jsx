import React, { useEffect, useRef } from 'react';
import { X } from 'lucide-react';
import { animarAparicionModal } from '../../animations/gsapHelpers';

export const BaseModal = ({
  isOpen,
  onClose,
  title,
  subtitle,
  children,
  maxWidth = '600px',
  footer,
  showCloseButton = true,
}) => {
  const overlayRef = useRef(null);
  const contentRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      animarAparicionModal(overlayRef.current, contentRef.current);

      const handleKeyDown = (e) => {
        if (e.key === 'Escape') onClose();
      };
      window.addEventListener('keydown', handleKeyDown);
      return () => {
        document.body.style.overflow = '';
        window.removeEventListener('keydown', handleKeyDown);
      };
    } else {
      document.body.style.overflow = '';
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      ref={overlayRef}
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0, 30, 18, 0.65)',
        backdropFilter: 'blur(8px)',
        WebkitBackdropFilter: 'blur(8px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 9000,
        padding: '1rem',
      }}
      onClick={(e) => {
        if (e.target === overlayRef.current) onClose();
      }}
    >
      <div
        ref={contentRef}
        role="dialog"
        aria-modal="true"
        style={{
          width: '100%',
          maxWidth: maxWidth,
          background: 'var(--color-blanco-puro)',
          borderRadius: 'var(--radius-lg)',
          boxShadow: 'var(--shadow-xl)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '90vh',
          border: '1px solid var(--border-light)',
        }}
      >
        {/* Encabezado */}
        <div
          style={{
            padding: '1.25rem 1.5rem',
            borderBottom: '1px solid var(--border-light)',
            display: 'flex',
            alignItems: 'flex-start',
            justifyContent: 'space-between',
            background: '#FAFDF9',
          }}
        >
          <div>
            {title && (
              <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: 700, color: 'var(--color-negro-puro)' }}>
                {title}
              </h3>
            )}
            {subtitle && (
              <p style={{ margin: '0.25rem 0 0 0', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                {subtitle}
              </p>
            )}
          </div>
          {showCloseButton && (
            <button
              type="button"
              onClick={onClose}
              aria-label="Cerrar modal"
              style={{
                background: 'transparent',
                border: 'none',
                cursor: 'pointer',
                color: 'var(--text-muted)',
                padding: '4px',
                borderRadius: 'var(--radius-sm)',
                display: 'flex',
              }}
            >
              <X size={20} />
            </button>
          )}
        </div>

        {/* Cuerpo */}
        <div style={{ padding: '1.5rem', overflowY: 'auto', flex: 1 }}>
          {children}
        </div>

        {/* Pie */}
        {footer && (
          <div
            style={{
              padding: '1rem 1.5rem',
              borderTop: '1px solid var(--border-light)',
              background: '#F8FAF8',
              display: 'flex',
              justifyContent: 'flex-end',
              gap: '0.75rem',
            }}
          >
            {footer}
          </div>
        )}
      </div>
    </div>
  );
};
