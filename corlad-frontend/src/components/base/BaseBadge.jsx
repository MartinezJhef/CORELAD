import React from 'react';

export const BaseBadge = ({
  children,
  variant = 'default',
  size = 'md',
  style = {},
  className = '',
}) => {
  const getBadgeColors = () => {
    switch (variant) {
      case 'success':
      case 'habil':
      case 'EST-APR':
        return {
          background: 'var(--color-verde-uo)',
          color: 'var(--color-blanco-puro)',
        };
      case 'warning':
      case 'observado':
      case 'deuda':
      case 'EST-OBS':
        return {
          background: 'var(--color-amarillo-zapallo)',
          color: 'var(--color-negro-puro)',
        };
      case 'danger':
      case 'sancion':
      case 'EST-REC':
        return {
          background: 'var(--color-peligro)',
          color: 'var(--color-blanco-puro)',
        };
      case 'info':
      case 'enviado':
      case 'EST-ENV':
      case 'EST-REV':
        return {
          background: '#0369A1',
          color: 'var(--color-blanco-puro)',
        };
      default:
        return {
          background: '#E5E7EB',
          color: 'var(--color-gris-carbon)',
        };
    }
  };

  const colors = getBadgeColors();

  return (
    <span
      className={className}
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '0.35rem',
        fontWeight: 600,
        borderRadius: 'var(--radius-full)',
        textTransform: 'uppercase',
        letterSpacing: '0.04em',
        padding: size === 'sm' ? '0.2rem 0.6rem' : '0.35rem 0.85rem',
        fontSize: size === 'sm' ? '0.7rem' : '0.78rem',
        ...colors,
        ...style,
      }}
    >
      <span
        style={{
          width: '6px',
          height: '6px',
          borderRadius: '50%',
          background: colors.color === 'var(--color-negro-puro)' ? '#000000' : '#FFFFFF',
          opacity: 0.8,
        }}
      />
      {children}
    </span>
  );
};
