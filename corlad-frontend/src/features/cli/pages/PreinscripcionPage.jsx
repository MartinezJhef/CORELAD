import React, { useState } from 'react';
import { BasePageHeader } from '../../../components/base/BasePageHeader';
import { BaseMetricCard } from '../../../components/base/BaseMetricCard';
import { Crest3D } from '../../../components/3d/Crest3D';
import { PreinscripcionForm } from '../components/PreinscripcionForm';
import { PreinscripcionExitoCard } from '../components/PreinscripcionExitoCard';
import { SeguimientoExpedienteModal } from '../components/SeguimientoExpedienteModal';
import { usePreinscripcion } from '../hooks/usePreinscripcion';
import { ShieldCheck, Clock, FileCheck2, Search, Award } from 'lucide-react';
import { BaseButton } from '../../../components/base/BaseButton';

export const PreinscripcionPage = () => {
  const {
    formData,
    documentos,
    errors,
    backendErrors,
    isSubmitting,
    expedienteCreado,
    handleInputChange,
    handleDocumentSelect,
    handleDocumentRemove,
    enviarPreinscripcion,
    reiniciarTramite,
  } = usePreinscripcion();

  const [modalSeguimientoOpen, setModalSeguimientoOpen] = useState(false);
  const [expedienteConsulta, setExpedienteConsulta] = useState('');

  const handleVerSeguimiento = (codigo) => {
    setExpedienteConsulta(codigo);
    setModalSeguimientoOpen(true);
  };

  return (
    <div>
      {/* Encabezado de Página */}
      <BasePageHeader
        title="Pre-inscripción Digital de Colegiatura"
        subtitle="Mesa de Partes Virtual del Colegio Regional de Licenciados en Administración de Junín"
        moduleBadge="MÓDULO CLI"
        breadcrumbs={[
          { label: 'Inicio', href: '/' },
          { label: 'Colegiatura y Trámites', href: '#colegiatura' },
          { label: 'Pre-inscripción Digital' },
        ]}
        actions={
          <BaseButton
            variant="outline"
            icon={Search}
            onClick={() => {
              setExpedienteConsulta('');
              setModalSeguimientoOpen(true);
            }}
          >
            Consultar Trámite
          </BaseButton>
        }
      />

      {/* Hero Section con Visualización 3D y KPIs */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
          gap: '1.5rem',
          alignItems: 'center',
          marginBottom: '2rem',
          background: 'linear-gradient(135deg, rgba(0, 112, 48, 0.08), rgba(245, 166, 4, 0.04))',
          borderRadius: 'var(--radius-lg)',
          border: '1px solid var(--border-light)',
          padding: '1.5rem',
        }}
      >
        <div>
          <span
            style={{
              fontSize: '0.8rem',
              fontWeight: 700,
              color: 'var(--color-verde-uo)',
              textTransform: 'uppercase',
              letterSpacing: '0.08em',
              display: 'flex',
              alignItems: 'center',
              gap: '0.35rem',
            }}
          >
            <Award size={16} color="var(--color-amarillo-zapallo)" />
            Incorporación Profesional 2026
          </span>
          <h2 style={{ fontSize: '1.85rem', fontWeight: 800, color: 'var(--color-negro-puro)', margin: '0.4rem 0 0.75rem 0' }}>
            Únase a la Orden Deontológica del CORLAD Junín
          </h2>
          <p style={{ fontSize: '0.95rem', color: 'var(--color-gris-carbon)', lineHeight: 1.6, margin: 0 }}>
            El proceso de pre-inscripción le permite cargar sus requisitos oficiales de manera 100% digital, garantizando la validación formal ante la SUNEDU y la emisión de su carné y matrícula colegiada.
          </p>
        </div>

        {/* Emblema 3D Interactivo Three.js */}
        <div
          style={{
            height: '240px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Crest3D />
        </div>
      </div>

      {/* Tarjetas de Métricas / KPIs */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
          gap: '1.25rem',
          marginBottom: '2.5rem',
        }}
      >
        <BaseMetricCard
          title="Trámite 100% Digital"
          value="Cero Papel"
          subtitle="Sin necesidad de acudir a ventanilla física"
          icon={FileCheck2}
        />
        <BaseMetricCard
          title="Garantía Legal"
          value="SHA-256"
          subtitle="Hash criptográfico inalterable en cada documento"
          icon={ShieldCheck}
          color="var(--color-verde-bosque)"
        />
        <BaseMetricCard
          title="Tiempo de Calificación"
          value="48 Horas"
          subtitle="SLA estándar de revisión en Mesa de Partes"
          icon={Clock}
          color="var(--color-amarillo-zapallo)"
        />
      </div>

      {/* Formulario de Pre-inscripción o Vista de Éxito */}
      <section id="preinscripcion">
        {expedienteCreado ? (
          <PreinscripcionExitoCard
            expediente={expedienteCreado}
            onReiniciar={reiniciarTramite}
            onVerSeguimiento={handleVerSeguimiento}
          />
        ) : (
          <PreinscripcionForm
            formData={formData}
            documentos={documentos}
            errors={errors}
            backendErrors={backendErrors}
            isSubmitting={isSubmitting}
            handleInputChange={handleInputChange}
            handleDocumentSelect={handleDocumentSelect}
            handleDocumentRemove={handleDocumentRemove}
            onSubmit={enviarPreinscripcion}
          />
        )}
      </section>

      {/* Modal de Seguimiento */}
      <SeguimientoExpedienteModal
        isOpen={modalSeguimientoOpen}
        onClose={() => setModalSeguimientoOpen(false)}
        initialExpediente={expedienteConsulta}
      />
    </div>
  );
};
