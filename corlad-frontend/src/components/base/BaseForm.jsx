import React, { useRef, useEffect } from 'react';
import { animarShakeError } from '../../animations/gsapHelpers';
import { AlertCircle } from 'lucide-react';

export const BaseForm = ({
  children,
  onSubmit,
  isSubmitting = false,
  backendErrors = [],
  className = '',
  style = {},
  ...props
}) => {
  const formRef = useRef(null);

  useEffect(() => {
    if (backendErrors && backendErrors.length > 0) {
      animarShakeError(formRef.current);
    }
  }, [backendErrors]);

  return (
    <form
      ref={formRef}
      onSubmit={onSubmit}
      noValidate
      className={className}
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: '1.25rem',
        width: '100%',
        ...style,
      }}
      {...props}
    >
      {backendErrors && backendErrors.length > 0 && (
        <div
          style={{
            background: '#FEF2F2',
            border: '1px solid #F87171',
            borderRadius: 'var(--radius-md)',
            padding: '1rem',
            display: 'flex',
            gap: '0.75rem',
            alignItems: 'flex-start',
          }}
        >
          <AlertCircle size={20} color="var(--color-peligro)" style={{ flexShrink: 0, marginTop: '2px' }} />
          <div>
            <h4 style={{ margin: '0 0 0.25rem 0', fontSize: '0.875rem', fontWeight: 600, color: 'var(--color-peligro)' }}>
              Se encontraron observaciones en la solicitud:
            </h4>
            <ul style={{ margin: 0, paddingLeft: '1.25rem', fontSize: '0.8125rem', color: '#991B1B' }}>
              {backendErrors.map((err, idx) => (
                <li key={idx}>
                  {err.campo ? <strong>{err.campo}: </strong> : null}
                  {err.mensaje}
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}

      {children}
    </form>
  );
};
