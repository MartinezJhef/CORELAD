import React, { forwardRef } from 'react';

export const BaseInput = forwardRef(({
  label,
  id,
  name,
  type = 'text',
  value,
  onChange,
  placeholder = '',
  required = false,
  error = '',
  helperText = '',
  icon: Icon,
  disabled = false,
  className = '',
  style = {},
  maxLength,
  ...props
}, ref) => {
  const inputId = id || name || Math.random().toString(36).substring(2, 9);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.35rem', width: '100%', ...style }}>
      {label && (
        <label
          htmlFor={inputId}
          style={{
            fontSize: '0.875rem',
            fontWeight: 600,
            color: error ? 'var(--color-peligro)' : 'var(--color-negro-puro)',
            display: 'flex',
            alignItems: 'center',
            gap: '0.25rem',
          }}
        >
          {label}
          {required && <span style={{ color: 'var(--color-peligro)', fontWeight: 'bold' }}>*</span>}
        </label>
      )}

      <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
        {Icon && (
          <div
            style={{
              position: 'absolute',
              left: '0.85rem',
              color: error ? 'var(--color-peligro)' : 'var(--text-muted)',
              pointerEvents: 'none',
              display: 'flex',
            }}
          >
            <Icon size={18} />
          </div>
        )}

        <input
          ref={ref}
          id={inputId}
          name={name}
          type={type}
          value={value}
          onChange={onChange}
          placeholder={placeholder}
          disabled={disabled}
          maxLength={maxLength}
          required={required}
          className={`focus-ring ${className}`}
          style={{
            width: '100%',
            padding: Icon ? '0.625rem 0.85rem 0.625rem 2.5rem' : '0.625rem 0.85rem',
            fontSize: '0.9375rem',
            borderRadius: 'var(--radius-md)',
            border: `1.5px solid ${error ? 'var(--color-peligro)' : 'rgba(0, 77, 48, 0.2)'}`,
            background: disabled ? '#F3F4F6' : 'var(--color-blanco-puro)',
            color: 'var(--color-gris-carbon)',
            outline: 'none',
            transition: 'border-color var(--transition-fast), box-shadow var(--transition-fast)',
          }}
          {...props}
        />
      </div>

      {error ? (
        <span style={{ fontSize: '0.8rem', color: 'var(--color-peligro)', fontWeight: 500 }}>
          {error}
        </span>
      ) : helperText ? (
        <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
          {helperText}
        </span>
      ) : null}
    </div>
  );
});

BaseInput.displayName = 'BaseInput';
