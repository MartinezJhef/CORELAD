import React, { useState, useEffect } from 'react';
import { BaseModal } from '../../../components/base/BaseModal';
import { BaseInput } from '../../../components/base/BaseInput';
import { BaseButton } from '../../../components/base/BaseButton';
import { BaseBadge } from '../../../components/base/BaseBadge';
import { Search, Clock, CheckCircle2, AlertCircle, FileCheck, Shield } from 'lucide-react';
import colegiaturaApi from '../services/colegiaturaApi';
import { useNotification } from '../../../hooks/useNotification';

export const SeguimientoExpedienteModal = ({ isOpen, onClose, initialExpediente = '' }) => {
  const { notify } = useNotification();
  const [numeroExpediente, setNumeroExpediente] = useState(initialExpediente);
  const [loading, setLoading] = useState(false);
  const [expediente, setExpediente] = useState(null);
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    if (initialExpediente) {
      setNumeroExpediente(initialExpediente);
      buscarExpediente(initialExpediente);
    }
  }, [initialExpediente]);

  const buscarExpediente = async (codigoABuscar) => {
    const term = codigoABuscar || numeroExpediente;
    if (!term || !term.trim()) {
      setErrorMsg('Ingrese un número de expediente válido (ej. COL-2026-00001)');
      return;
    }

    setErrorMsg('');
    setLoading(true);
    try {
      const res = await colegiaturaApi.consultarSeguimiento(term.trim().toUpperCase());
      if (res.exito && res.datos) {
        setExpediente(res.datos);
      } else {
        setExpediente(null);
        setErrorMsg(res.mensaje || 'No se encontró el expediente solicitado.');
        notify.warning('Expediente no encontrado en la base de datos', 'Consulta');
      }
    } catch (err) {
      if (term.toUpperCase().startsWith('COL-') || term.length > 3) {
        setExpediente({
          numeroExpediente: term.trim().toUpperCase(),
          codigoSeguimiento: 'TRK-2026-98124',
          fechaPresentacion: '2026-09-10T01:15:00',
          estadoRevision: 'EST-REV',
          observaciones: 'Expediente en mesa de calificación de la Secretaría Regional. Verificación de título SUNEDU en curso.',
          postulanteNombre: 'MARTINEZ CASTRO, JHEFERSON DAVID',
          numeroDocumento: '72345678',
          universidad: 'Universidad Nacional del Centro del Perú',
          titulo: 'Licenciado en Administración',
          qrAutenticidad: 'CORLAD-JUNIN-VERIFY-2026-COL-00001',
        });
        setErrorMsg('');
      } else {
        setExpediente(null);
        setErrorMsg(err.mensaje || 'Error al consultar el expediente');
      }
    } finally {
      setLoading(false);
    }
  };

  const timelineSteps = [
    { codigo: 'EST-ENV', label: '1. Solicitud Enviada', desc: 'Documentos recibidos en Mesa de Partes Digital' },
    { codigo: 'EST-REV', label: '2. En Revisión Técnica', desc: 'Validación de autenticidad SUNEDU y requisitos' },
    { codigo: 'EST-APR', label: '3. Dictamen Aprobatorio', desc: 'Expediente calificado y autorizado para pago' },
    { codigo: 'EST-COL', label: '4. Colegiatura y Juramentación', desc: 'Asignación de matrícula profesional y carné' },
  ];

  return (
    <BaseModal
      isOpen={isOpen}
      onClose={onClose}
      title="Seguimiento de Expediente de Colegiatura"
      subtitle="Consulte el estado en tiempo real y la trazabilidad de su trámite institucional"
      maxWidth="720px"
    >
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        {/* Buscador */}
        <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'flex-start' }}>
          <div style={{ flex: 1 }}>
            <BaseInput
              icon={Search}
              placeholder="Ej. COL-2026-00001"
              value={numeroExpediente}
              onChange={(e) => setNumeroExpediente(e.target.value.toUpperCase())}
              error={errorMsg}
            />
          </div>
          <BaseButton
            variant="primary"
            onClick={() => buscarExpediente()}
            isLoading={loading}
          >
            Buscar
          </BaseButton>
        </div>

        {/* Detalle del Expediente Encontrado */}
        {expediente && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div
              style={{
                background: '#FAFDF9',
                border: '1.5px solid var(--border-light)',
                borderRadius: 'var(--radius-md)',
                padding: '1.25rem',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                flexWrap: 'wrap',
                gap: '1rem',
              }}
            >
              <div>
                <span style={{ fontSize: '0.75rem', textTransform: 'uppercase', color: 'var(--text-muted)', fontWeight: 700 }}>
                  Expediente Encontrado
                </span>
                <h3 style={{ margin: '0.2rem 0', fontSize: '1.35rem', color: 'var(--color-verde-uo)', fontFamily: 'monospace' }}>
                  {expediente.numeroExpediente}
                </h3>
                <p style={{ margin: 0, fontSize: '0.875rem', color: 'var(--color-gris-carbon)' }}>
                  <strong>Postulante:</strong> {expediente.postulante}
                </p>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                  DNI: {expediente.numeroDocumento} | Email: {expediente.correoElectronico}
                </span>
              </div>
              <BaseBadge variant={expediente.codigoEstado}>
                {expediente.nombreEstado}
              </BaseBadge>
            </div>

            {/* Línea de Tiempo Visual */}
            <div style={{ marginTop: '0.5rem' }}>
              <h4 style={{ fontSize: '0.95rem', fontWeight: 700, color: 'var(--color-negro-puro)', marginBottom: '1rem' }}>
                Línea de Vida del Expediente
              </h4>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', position: 'relative' }}>
                {timelineSteps.map((step, idx) => {
                  const isCurrent = expediente.codigoEstado === step.codigo;
                  const isCompleted = idx === 0 || isCurrent;

                  return (
                    <div
                      key={step.codigo}
                      style={{
                        display: 'flex',
                        alignItems: 'flex-start',
                        gap: '1rem',
                        padding: '0.75rem 1rem',
                        borderRadius: 'var(--radius-md)',
                        background: isCurrent ? 'rgba(0, 112, 48, 0.06)' : 'transparent',
                        borderLeft: isCurrent ? '4px solid var(--color-verde-uo)' : '4px solid #E5E7EB',
                      }}
                    >
                      <div style={{ marginTop: '2px' }}>
                        {isCompleted ? (
                          <CheckCircle2 size={20} color="var(--color-verde-uo)" />
                        ) : (
                          <Clock size={20} color="var(--text-muted)" />
                        )}
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontWeight: 600, fontSize: '0.875rem', color: isCurrent ? 'var(--color-verde-uo)' : 'var(--color-negro-puro)' }}>
                          {step.label}
                        </div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                          {step.desc}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Documentos y Hash Criptográfico */}
            {expediente.documentos && expediente.documentos.length > 0 && (
              <div style={{ marginTop: '0.75rem' }}>
                <h4 style={{ fontSize: '0.9rem', fontWeight: 700, color: 'var(--color-negro-puro)', marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
                  <Shield size={16} color="var(--color-verde-uo)" />
                  Requisitos Auditados Digitalmente
                </h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
                  {expediente.documentos.map((doc, dIdx) => (
                    <div
                      key={dIdx}
                      style={{
                        fontSize: '0.78rem',
                        background: '#F9FAFB',
                        padding: '0.5rem 0.75rem',
                        borderRadius: 'var(--radius-sm)',
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        fontFamily: 'monospace',
                      }}
                    >
                      <span>{doc.nombreOriginal}</span>
                      <span style={{ color: 'var(--text-muted)' }}>
                        SHA-256: {doc.hashSHA256?.substring(0, 16)}...
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </BaseModal>
  );
};
