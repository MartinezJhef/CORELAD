import React, { useRef, useEffect } from 'react';
import { BaseCard } from '../../../components/base/BaseCard';
import { BaseBadge } from '../../../components/base/BaseBadge';
import { BaseButton } from '../../../components/base/BaseButton';
import { CheckCircle, ShieldCheck, FileText, QrCode, Download, RotateCcw } from 'lucide-react';
import gsap from 'gsap';

export const PreinscripcionExitoCard = ({ expediente, onReiniciar, onVerSeguimiento }) => {
  const cardRef = useRef(null);

  useEffect(() => {
    if (cardRef.current) {
      gsap.fromTo(
        cardRef.current,
        { scale: 0.9, opacity: 0, y: 25 },
        { scale: 1, opacity: 1, y: 0, duration: 0.5, ease: 'back.out(1.6)' }
      );
    }
  }, []);

  return (
    <div ref={cardRef} style={{ maxWidth: '780px', margin: '0 auto', width: '100%' }}>
      <BaseCard
        style={{
          border: '2px solid var(--color-verde-uo)',
          boxShadow: 'var(--shadow-xl)',
        }}
      >
        {/* Cabecera de Éxito */}
        <div
          style={{
            textAlign: 'center',
            padding: '1.5rem 1rem 1rem 1rem',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '0.75rem',
          }}
        >
          <div
            style={{
              width: '68px',
              height: '68px',
              borderRadius: 'var(--radius-full)',
              background: 'linear-gradient(135deg, var(--color-verde-uo), var(--color-verde-bosque))',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FFFFFF',
              boxShadow: '0 8px 16px rgba(0, 112, 48, 0.25)',
              border: '3px solid var(--color-amarillo-zapallo)',
            }}
          >
            <CheckCircle size={38} color="var(--color-amarillo-electrico)" />
          </div>

          <h2 style={{ fontSize: '1.65rem', fontWeight: 800, color: 'var(--color-verde-bosque)', margin: 0 }}>
            ¡Pre-inscripción Registrada Exitosamente!
          </h2>
          <p style={{ fontSize: '0.9375rem', color: 'var(--color-gris-carbon)', maxWidth: '580px', margin: 0 }}>
            Su solicitud y requisitos han sido digitalizados e ingresados a la Mesa de Partes Digital del CORLAD Junín con número de expediente oficial:
          </p>

          {/* Badge Destacado con Número de Expediente */}
          <div
            style={{
              marginTop: '0.5rem',
              padding: '0.85rem 2rem',
              background: 'rgba(0, 112, 48, 0.08)',
              border: '2px dashed var(--color-verde-uo)',
              borderRadius: 'var(--radius-lg)',
              display: 'flex',
              alignItems: 'center',
              gap: '1rem',
            }}
          >
            <div>
              <span style={{ fontSize: '0.75rem', textTransform: 'uppercase', letterSpacing: '0.08em', color: 'var(--text-muted)', fontWeight: 700 }}>
                Número de Expediente Institucional
              </span>
              <div
                style={{
                  fontSize: '1.75rem',
                  fontWeight: 800,
                  fontFamily: 'monospace',
                  color: 'var(--color-verde-uo)',
                  letterSpacing: '0.05em',
                }}
              >
                {expediente.numeroExpediente}
              </div>
            </div>
            <BaseBadge variant={expediente.codigoEstado || 'EST-ENV'}>
              {expediente.nombreEstado || 'Enviado'}
            </BaseBadge>
          </div>
        </div>

        {/* Resumen de Datos */}
        <div
          style={{
            marginTop: '1.5rem',
            background: '#FAFDF9',
            borderRadius: 'var(--radius-md)',
            padding: '1.25rem',
            border: '1px solid var(--border-light)',
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
            gap: '1rem',
            fontSize: '0.875rem',
          }}
        >
          <div>
            <strong style={{ color: 'var(--color-negro-puro)', display: 'block', fontSize: '0.75rem', textTransform: 'uppercase' }}>Postulante:</strong>
            <span style={{ color: 'var(--color-gris-carbon)' }}>{expediente.postulante}</span>
          </div>
          <div>
            <strong style={{ color: 'var(--color-negro-puro)', display: 'block', fontSize: '0.75rem', textTransform: 'uppercase' }}>N° Documento (DNI):</strong>
            <span style={{ color: 'var(--color-gris-carbon)' }}>{expediente.numeroDocumento}</span>
          </div>
          <div>
            <strong style={{ color: 'var(--color-negro-puro)', display: 'block', fontSize: '0.75rem', textTransform: 'uppercase' }}>Correo de Contacto:</strong>
            <span style={{ color: 'var(--color-gris-carbon)' }}>{expediente.correoElectronico}</span>
          </div>
          <div>
            <strong style={{ color: 'var(--color-negro-puro)', display: 'block', fontSize: '0.75rem', textTransform: 'uppercase' }}>Documentos Auditados:</strong>
            <span style={{ color: 'var(--color-verde-uo)', fontWeight: 600 }}>{expediente.totalDocumentosAdjuntos} requisitos adjuntados</span>
          </div>
        </div>

        {/* Certificación de Integridad Criptográfica */}
        <div
          style={{
            marginTop: '1.25rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.75rem',
            padding: '0.85rem 1rem',
            background: 'rgba(245, 166, 4, 0.08)',
            borderRadius: 'var(--radius-md)',
            borderLeft: '4px solid var(--color-amarillo-zapallo)',
            fontSize: '0.8125rem',
            color: 'var(--color-gris-carbon)',
          }}
        >
          <ShieldCheck size={24} color="var(--color-verde-uo)" style={{ flexShrink: 0 }} />
          <div>
            <strong>Garantía de Integridad:</strong> Cada archivo adjunto ha sido verificado criptográficamente mediante <strong>Hash SHA-256</strong>, garantizando inalterabilidad conforme al Estándar Nacional de Trámite Documentario.
          </div>
        </div>

        {/* Acciones */}
        <div
          style={{
            marginTop: '2rem',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            gap: '1rem',
            flexWrap: 'wrap',
          }}
        >
          <BaseButton
            variant="outline"
            icon={QrCode}
            onClick={() => onVerSeguimiento(expediente.numeroExpediente)}
          >
            Consultar Línea de Tiempo
          </BaseButton>

          <BaseButton
            variant="ghost"
            icon={RotateCcw}
            onClick={onReiniciar}
          >
            Nueva Pre-inscripción
          </BaseButton>
        </div>
      </BaseCard>
    </div>
  );
};
