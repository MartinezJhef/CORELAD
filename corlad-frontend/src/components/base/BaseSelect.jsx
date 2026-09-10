import React, { forwardRef } from 'react';

export const BaseSelect = forwardRef(({
  label,
  id,
  name,
  value,
  onChange,
  options = [],
  placeholder = 'Seleccione una opción',
  required = false,
  error = '',
  helperText = '',
  disabled = false,
  className = '',
  style = {},
  ...props
}, ref) => {
  const selectId = id || name || Math.random().toString(36).substring(2, 9);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.35rem', width: '100%', ...style }}>
      {label && (
        <label
          htmlFor={selectId}
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

      <div style={{ position: 'relative' }}>
        <select
          ref={ref}
          id={selectId}
          name={name}
          value={value}
          onChange={onChange}
          disabled={disabled}
          required={required}
          className={`focus-ring ${className}`}
          style={{
            width: '100%',
            padding: '0.625rem 2.25rem 0.625rem 0.85rem',
            fontSize: '0.9375rem',
            borderRadius: 'var(--radius-md)',
            border: `1.5px solid ${error ? 'var(--color-peligro)' : 'rgba(0, 77, 48, 0.2)'}`,
            background: disabled ? '#F3F4F6' : 'var(--color-blanco-puro)',
            color: value ? 'var(--color-gris-carbon)' : 'var(--text-muted)',
            outline: 'none',
            appearance: 'none',
            cursor: disabled ? 'not-allowed' : 'pointer',
            transition: 'border-color var(--transition-fast)',
          }}
          {...props}
        >
          {placeholder && <option value="">{placeholder}</option>}
          {options.map((opt) => (
            <option key={opt.value ?? opt} value={opt.value ?? opt}>
              {opt.label ?? opt}
            </option>
          ))}
        </select>

        {/* Flecha select svg */}
        <div
          style={{
            position: 'absolute',
            right: '0.85rem',
            top: '50%',
            transform: 'translateY(-50%)',
            pointerEvents: 'none',
            color: 'var(--text-muted)',
            display: 'flex',
          }}
        >
          <svg width="14" height="14" viewBox="0 0 20 20" fill="currentColor">
            <path
              fillRule="evenodd"
              d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
              clipRule="evenodd"
            />
          </svg>
        </div>
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

BaseSelect.displayName = 'BaseSelect';
