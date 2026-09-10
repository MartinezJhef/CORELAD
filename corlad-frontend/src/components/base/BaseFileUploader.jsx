import React, { useRef, useState } from 'react';
import { UploadCloud, FileCheck, X, AlertCircle } from 'lucide-react';

export const BaseFileUploader = ({
  label,
  id,
  required = false,
  error = '',
  accept = '.pdf,.jpg,.jpeg,.png',
  maxSizeMB = 5,
  helperText = 'Formatos permitidos: PDF, JPG o PNG (Máx. 5MB)',
  onFileSelect,
  onFileRemove,
  selectedFile = null,
  disabled = false,
  style = {},
}) => {
  const fileInputRef = useRef(null);
  const [isDragging, setIsDragging] = useState(false);
  const [localError, setLocalError] = useState('');

  const processFile = (file) => {
    setLocalError('');
    if (!file) return;

    // Validar tamaño
    const maxBytes = maxSizeMB * 1024 * 1024;
    if (file.size > maxBytes) {
      const err = `El archivo supera el límite permitido de ${maxSizeMB} MB`;
      setLocalError(err);
      return;
    }

    // Validar extensión
    const ext = '.' + file.name.split('.').pop().toLowerCase();
    const allowed = accept.split(',').map((a) => a.trim().toLowerCase());
    if (!allowed.includes(ext)) {
      const err = `Extensión no permitida (${ext}). Permitidos: ${accept}`;
      setLocalError(err);
      return;
    }

    // Convertir a base64
    const reader = new FileReader();
    reader.onload = () => {
      const base64Data = reader.result.split(',')[1];
      if (onFileSelect) {
        onFileSelect({
          file,
          nombreOriginal: file.name,
          extension: ext,
          tamanoBytes: file.size,
          archivoBase64: base64Data,
        });
      }
    };
    reader.readAsDataURL(file);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    if (disabled) return;
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      processFile(e.dataTransfer.files[0]);
    }
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    if (!disabled) setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const formatFileSize = (bytes) => {
    if (!bytes) return '0 KB';
    const kb = bytes / 1024;
    if (kb < 1024) return `${kb.toFixed(1)} KB`;
    return `${(kb / 1024).toFixed(2)} MB`;
  };

  const activeError = error || localError;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem', width: '100%', ...style }}>
      {label && (
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <label
            style={{
              fontSize: '0.875rem',
              fontWeight: 600,
              color: activeError ? 'var(--color-peligro)' : 'var(--color-negro-puro)',
              display: 'flex',
              alignItems: 'center',
              gap: '0.25rem',
            }}
          >
            {label}
            {required && <span style={{ color: 'var(--color-peligro)', fontWeight: 'bold' }}>*</span>}
          </label>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Máx. {maxSizeMB}MB</span>
        </div>
      )}

      {selectedFile ? (
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '0.75rem 1rem',
            background: '#F0FDF4',
            border: '1.5px solid var(--color-verde-uo)',
            borderRadius: 'var(--radius-md)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', overflow: 'hidden' }}>
            <FileCheck size={24} color="var(--color-verde-uo)" style={{ flexShrink: 0 }} />
            <div style={{ overflow: 'hidden' }}>
              <p style={{ margin: 0, fontSize: '0.875rem', fontWeight: 600, color: 'var(--color-negro-puro)', textOverflow: 'ellipsis', whiteSpace: 'nowrap', overflow: 'hidden' }}>
                {selectedFile.nombreOriginal}
              </p>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                {formatFileSize(selectedFile.tamanoBytes)}
              </span>
            </div>
          </div>
          {!disabled && (
            <button
              type="button"
              onClick={() => {
                setLocalError('');
                if (onFileRemove) onFileRemove();
              }}
              style={{
                background: 'transparent',
                border: 'none',
                cursor: 'pointer',
                color: 'var(--color-peligro)',
                padding: '4px',
                display: 'flex',
              }}
              title="Quitar archivo"
            >
              <X size={18} />
            </button>
          )}
        </div>
      ) : (
        <div
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onClick={() => !disabled && fileInputRef.current?.click()}
          style={{
            border: `2px dashed ${activeError ? 'var(--color-peligro)' : isDragging ? 'var(--color-amarillo-zapallo)' : 'rgba(0, 112, 48, 0.25)'}`,
            background: isDragging ? 'rgba(245, 166, 4, 0.05)' : '#FAFCFA',
            borderRadius: 'var(--radius-md)',
            padding: '1.25rem 1rem',
            textAlign: 'center',
            cursor: disabled ? 'not-allowed' : 'pointer',
            transition: 'all var(--transition-fast)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '0.4rem',
          }}
        >
          <input
            ref={fileInputRef}
            id={id}
            type="file"
            accept={accept}
            disabled={disabled}
            onChange={(e) => {
              if (e.target.files && e.target.files[0]) {
                processFile(e.target.files[0]);
              }
            }}
            style={{ display: 'none' }}
          />

          <UploadCloud size={28} color={activeError ? 'var(--color-peligro)' : 'var(--color-verde-uo)'} />
          <div style={{ fontSize: '0.875rem', color: 'var(--color-gris-carbon)' }}>
            <span style={{ fontWeight: 600, color: 'var(--color-verde-uo)' }}>Haga clic para examinar</span> o arrastre el archivo aquí
          </div>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{helperText}</span>
        </div>
      )}

      {activeError && (
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem', color: 'var(--color-peligro)', fontSize: '0.8rem' }}>
          <AlertCircle size={14} />
          <span>{activeError}</span>
        </div>
      )}
    </div>
  );
};
