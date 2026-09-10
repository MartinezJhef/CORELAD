import React from 'react';

export const BaseCard = ({
  children,
  title,
  subtitle,
  icon: Icon,
  actions,
  headerBorder = true,
  footer,
  style = {},
  className = '',
  ...props
}) => {
  return (
    <div
      className={`glass-card ${className}`}
      style={{
        overflow: 'hidden',
        display: 'flex',
        flexDirection: 'column',
        ...style,
      }}
      {...props}
    >
      {(title || Icon || actions) && (
        <div
          style={{
            padding: '1.25rem 1.5rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderBottom: headerBorder ? '1px solid var(--border-light)' : 'none',
            background: 'rgba(255, 255, 255, 0.5)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            {Icon && (
              <div
                style={{
                  width: '38px',
                  height: '38px',
                  borderRadius: 'var(--radius-md)',
                  background: 'rgba(0, 112, 48, 0.08)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: 'var(--color-verde-uo)',
                }}
              >
                <Icon size={20} />
              </div>
            )}
            <div>
              {title && (
                <h3 style={{ margin: 0, fontSize: '1.125rem', fontWeight: 700, color: 'var(--color-negro-puro)' }}>
                  {title}
                </h3>
              )}
              {subtitle && (
                <p style={{ margin: '0.2rem 0 0 0', fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
                  {subtitle}
                </p>
              )}
            </div>
          </div>
          {actions && <div>{actions}</div>}
        </div>
      )}

      <div style={{ padding: '1.5rem', flex: 1 }}>
        {children}
      </div>

      {footer && (
        <div
          style={{
            padding: '1rem 1.5rem',
            borderTop: '1px solid var(--border-light)',
            background: 'rgba(248, 250, 248, 0.7)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'flex-end',
            gap: '0.75rem',
          }}
        >
          {footer}
        </div>
      )}
    </div>
  );
};
