import React, { useState, useEffect } from 'react';
import { BaseModal } from '../../../components/base/BaseModal';
import { BaseButton } from '../../../components/base/BaseButton';
import { BaseInput } from '../../../components/base/BaseInput';
import { BaseSelect } from '../../../components/base/BaseSelect';
import { BaseDatePicker } from '../../../components/base/BaseDatePicker';
import { Shield, Award, Calendar, FileText, CheckCircle2, UserCheck, AlertCircle } from 'lucide-react';

/**
 * Modal para la Asignación de Matrícula Regional y Formalización de Colegiatura (CU-COL-03).
 */
export const AsignarMatriculaModal = ({
  isOpen,
  onClose,
  expediente,
  siguienteMatriculaSugerida,
  onConfirmar,
  submitting = false,
}) => {
  const [formData, setFormData] = useState({
    matriculaRegional: '',
    matriculaNacional: '',
    numeroResolucionIncorporacion: '',
    fechaJuramentacion: new Date().toISOString().split('T')[0],
    condicionColegiado: 'ORDINARIO',
    observaciones: '',
  });

  const [errores, setErrores] = useState({});

  useEffect(() => {
    if (isOpen && expediente) {
      setFormData({
        matriculaRegional: siguienteMatriculaSugerida || 'CORLAD-JUN-00128',
        matriculaNacional: `CLAD-${Math.floor(20000 + Math.random() * 15000)}`,
        numeroResolucionIncorporacion: `RES-DEC-${Math.floor(30 + Math.random() * 40).toString().padStart(3, '0')}-2026-CORLAD-JUN`,
        fechaJuramentacion: new Date().toISOString().split('T')[0],
        condicionColegiado: 'ORDINARIO',
        observaciones: 'Incorporación protocolar ratificada por el Consejo Directivo Regional.',
      });
      setErrores({});
    }
  }, [isOpen, expediente, siguienteMatriculaSugerida]);

  if (!expediente) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errores[name]) {
      setErrores((prev) => ({ ...prev, [name]: null }));
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const nuevosErrores = {};

    if (!formData.matriculaRegional.trim()) {
      nuevosErrores.matriculaRegional = 'El número de matrícula regional es obligatorio.';
    }
    if (!formData.numeroResolucionIncorporacion.trim()) {
      nuevosErrores.numeroResolucionIncorporacion = 'El número de resolución decanal es mandatorio.';
    }
    if (!formData.fechaJuramentacion) {
      nuevosErrores.fechaJuramentacion = 'La fecha de juramentación protocolar es requerida.';
    }

    if (Object.keys(nuevosErrores).length > 0) {
      setErrores(nuevosErrores);
      return;
    }

    onConfirmar(formData);
  };

  return (
    <BaseModal
      isOpen={isOpen}
      onClose={onClose}
      title="Formalización de Matrícula Regional y Emisión de Carnet"
      maxWidth="680px"
    >
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
        {/* Tarjeta de Resumen del Postulante Aprobado */}
        <div
          style={{
            background: 'linear-gradient(135deg, rgba(0, 112, 48, 0.08), rgba(245, 166, 4, 0.06))',
            border: '1.5px solid rgba(0, 112, 48, 0.25)',
            borderRadius: 'var(--radius-md)',
            padding: '1rem 1.25rem',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.6rem' }}>
            <span style={{ fontSize: '0.78rem', fontWeight: 700, color: 'var(--color-verde-bosque)', display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
              <UserCheck size={16} color="var(--color-verde-uo)" /> EXPEDIENTE APROBADO: {expediente.numeroExpediente}
            </span>
            <span
              style={{
                fontSize: '0.7rem',
                fontWeight: 800,
                color: '#FFFFFF',
                background: 'var(--color-verde-uo)',
                padding: '0.2rem 0.6rem',
                borderRadius: 'var(--radius-full)',
              }}
            >
              SUNEDU VERIFICADO
            </span>
          </div>

          <div style={{ fontSize: '1.05rem', fontWeight: 800, color: 'var(--color-gris-carbon)', marginBottom: '0.25rem' }}>
            {expediente.nombreCompleto}
          </div>

          <div style={{ fontSize: '0.85rem', color: 'var(--color-verde-uo)', fontWeight: 600, marginBottom: '0.5rem' }}>
            {expediente.tituloProfesional}
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '0.5rem', fontSize: '0.8rem' }}>
            <div>
              <span style={{ color: 'var(--color-gris-carbon)', opacity: 0.75 }}>DNI Postulante: </span>
              <strong>{expediente.dniPostulante}</strong>
            </div>
            <div>
              <span style={{ color: 'var(--color-gris-carbon)', opacity: 0.75 }}>Registro SUNEDU: </span>
              <strong>{expediente.codigoRegistroSunedu || 'SUN-2026-04289'}</strong>
            </div>
            <div style={{ gridColumn: '1 / -1' }}>
              <span style={{ color: 'var(--color-gris-carbon)', opacity: 0.75 }}>Universidad: </span>
              <strong>{expediente.universidad}</strong>
            </div>
          </div>
        </div>

        {/* Campos de Asignación de Matrícula */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1rem' }}>
          <BaseInput
            label="Número de Matrícula Regional *"
            name="matriculaRegional"
            value={formData.matriculaRegional}
            onChange={handleChange}
            error={errores.matriculaRegional}
            helperText="Formato sugerido inalterable: CORLAD-JUN-XXXXX"
            required
          />

          <BaseInput
            label="Número de Matrícula Nacional CLAD"
            name="matriculaNacional"
            value={formData.matriculaNacional}
            onChange={handleChange}
            error={errores.matriculaNacional}
            helperText="Código de registro remitido por Lima (opcional)"
          />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1rem' }}>
          <BaseInput
            label="Resolución Decanal de Incorporación *"
            name="numeroResolucionIncorporacion"
            value={formData.numeroResolucionIncorporacion}
            onChange={handleChange}
            error={errores.numeroResolucionIncorporacion}
            placeholder="ej. RES-DEC-045-2026-CORLAD-JUN"
            required
          />

          <BaseDatePicker
            label="Fecha Oficial de Juramentación *"
            name="fechaJuramentacion"
            value={formData.fechaJuramentacion}
            onChange={handleChange}
            error={errores.fechaJuramentacion}
            required
          />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1rem' }}>
          <BaseSelect
            label="Condición del Colegiado *"
            name="condicionColegiado"
            value={formData.condicionColegiado}
            onChange={handleChange}
            options={[
              { value: 'ORDINARIO', label: 'Miembro Ordinario' },
              { value: 'VITALICIO', label: 'Miembro Vitalicio' },
              { value: 'HONORARIO', label: 'Miembro Honorario' },
            ]}
          />

          <BaseInput
            label="Observaciones Institucionales"
            name="observaciones"
            value={formData.observaciones}
            onChange={handleChange}
            placeholder="Anotaciones para el libro de actas..."
          />
        </div>

        <div
          style={{
            background: 'rgba(245, 166, 4, 0.1)',
            borderLeft: '4px solid var(--color-amarillo-zapallo)',
            padding: '0.75rem 1rem',
            borderRadius: '4px',
            fontSize: '0.8rem',
            color: 'var(--color-gris-carbon)',
            display: 'flex',
            alignItems: 'flex-start',
            gap: '0.6rem',
          }}
        >
          <AlertCircle size={18} color="var(--color-amarillo-zapallo)" style={{ flexShrink: 0, marginTop: '2px' }} />
          <div>
            <strong>Advertencia Normativa:</strong> La asignación de la matrícula regional otorga fe pública y habilita el ejercicio legal de la profesión en la Región Junín conforme a la Ley N° 31060.
          </div>
        </div>

        {/* Botones del Modal */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem', marginTop: '0.5rem' }}>
          <BaseButton
            type="button"
            variant="ghost"
            onClick={onClose}
            disabled={submitting}
          >
            Cancelar
          </BaseButton>

          <BaseButton
            type="submit"
            variant="gold"
            icon={Award}
            isLoading={submitting}
          >
            Formalizar y Emitir Carnet
          </BaseButton>
        </div>
      </form>
    </BaseModal>
  );
};

export default AsignarMatriculaModal;
