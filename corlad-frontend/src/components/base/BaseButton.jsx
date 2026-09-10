import React, { useRef } from 'react';
import { animarPresionado } from '../../animations/gsapHelpers';

export const BaseButton = ({
  children,
  variant = 'primary',
  size = 'md',
  isLoading = false,
  disabled = false,
  icon: Icon,
  iconPosition = 'left',
  onClick,
  type = 'button',
  className = '',
  style = {},
  ...props
}) => {
  const btnRef = useRef(null);

  const handleClick = (e) => {
    if (disabled || isLoading) {
      e.preventDefault();
      return;
    }
    animarPresionado(btnRef.current);
    if (onClick) onClick(e);
  };

  const getVariantStyles = () => {
    switch (variant) {
      case 'primary':
        return {
          background: 'var(--color-verde-uo)',
          color: 'var(--color-blanco-puro)',
          border: '1px solid transparent',
        };
      case 'secondary':
        return {
          background: 'var(--color-verde-bosque)',
          color: 'var(--color-blanco-puro)',
          border: '1px solid transparent',
        };
      case 'gold':
      case 'warning':
        return {
          background: 'var(--color-amarillo-zapallo)',
          color: 'var(--color-negro-puro)',
          border: '1px solid transparent',
        };
      case 'outline':
        return {
          background: 'transparent',
          color: 'var(--color-verde-uo)',
          border: '2px solid var(--color-verde-uo)',
        };
      case 'danger':
        return {
          background: 'var(--color-peligro)',
          color: 'var(--color-blanco-puro)',
          border: '1px solid transparent',
        };
      case 'ghost':
        return {
          background: 'transparent',
          color: 'var(--color-gris-carbon)',
          border: '1px solid transparent',
        };
      default:
        return {
          background: 'var(--color-verde-uo)',
          color: 'var(--color-blanco-puro)',
          border: '1px solid transparent',
        };
    }
  };

  const getSizeStyles = () => {
    switch (size) {
      case 'sm':
        return { padding: '0.4rem 0.85rem', fontSize: '0.8125rem', gap: '0.35rem' };
      case 'lg':
        return { padding: '0.85rem 1.75rem', fontSize: '1.05rem', gap: '0.6rem' };
      case 'md':
      default:
        return { padding: '0.625rem 1.25rem', fontSize: '0.9375rem', gap: '0.5rem' };
    }
  };

  return (
    <button
      ref={btnRef}
      type={type}
      onClick={handleClick}
      disabled={disabled || isLoading}
      className={`focus-ring ${className}`}
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontWeight: 600,
        borderRadius: 'var(--radius-md)',
        cursor: disabled || isLoading ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.6 : 1,
        transition: 'background var(--transition-normal), border var(--transition-normal), box-shadow var(--transition-normal), transform 0.1s ease',
        boxShadow: variant === 'ghost' ? 'none' : 'var(--shadow-sm)',
        ...getVariantStyles(),
        ...getSizeStyles(),
        ...style,
      }}
      {...props}
    >
      {isLoading ? (
        <>
          <svg
            style={{
              animation: 'spin 1s linear infinite',
              width: size === 'sm' ? '14px' : '18px',
              height: size === 'sm' ? '14px' : '18px',
            }}
            viewBox="0 0 24 24"
            fill="none"
          >
            <circle
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
              style={{ opacity: 0.25 }}
            />
            <path
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            />
          </svg>
          <span>Cargando...</span>
          <style>{`
            @keyframes spin {
              from { transform: rotate(0deg); }
              to { transform: rotate(360deg); }
            }
          `}</style>
        </>
      ) : (
        <>
          {Icon && iconPosition === 'left' && <Icon size={size === 'sm' ? 16 : 18} />}
          <span>{children}</span>
          {Icon && iconPosition === 'right' && <Icon size={size === 'sm' ? 16 : 18} />}
        </>
      )}
    </button>
  );
};
