import React, { forwardRef } from 'react';
import { BaseInput } from './BaseInput';
import { Calendar } from 'lucide-react';

export const BaseDatePicker = forwardRef(({
  label,
  id,
  name,
  value,
  onChange,
  required = false,
  error = '',
  helperText = '',
  min,
  max,
  disabled = false,
  className = '',
  style = {},
  ...props
}, ref) => {
  return (
    <BaseInput
      ref={ref}
      type="date"
      label={label}
      id={id}
      name={name}
      value={value}
      onChange={onChange}
      required={required}
      error={error}
      helperText={helperText}
      min={min}
      max={max}
      disabled={disabled}
      icon={Calendar}
      className={className}
      style={style}
      {...props}
    />
  );
});

BaseDatePicker.displayName = 'BaseDatePicker';
