import React, { useState } from 'react';
import { BasePageHeader } from '../../../components/base/BasePageHeader';
import { BaseDataTable } from '../../../components/base/BaseDataTable';
import { BaseButton } from '../../../components/base/BaseButton';
import { BaseMetricCard } from '../../../components/base/BaseMetricCard';
import { BaseModal } from '../../../components/base/BaseModal';
import { CarnetEmblema3D } from '../../../components/3d/CarnetEmblema3D';
import { CarnetDigitalCard } from '../components/CarnetDigitalCard';
import { AsignarMatriculaModal } from '../components/AsignarMatriculaModal';
import { useMatriculacion } from '../hooks/useMatriculacion';
import {
  Award,
  UserCheck,
  Shield,
  FileText,
  Search,
  CheckCircle2,
  Calendar,
  Sparkles,
  QrCode,
  GraduationCap,
} from 'lucide-react';

/**
 * Vista Principal de Formalización de Matrícula Regional y Emisión de Carnet (CU-COL-03).
 * Módulo CLI: Colegiatura, Padrón y Habilitación Profesional.
 * Acceso Restringido: Decano Regional (ROL-DEC) y Secretaria Regional (ROL-SEC).
 */
export const MatriculacionPage = () => {
  const {
    expedientes,
    siguienteMatricula,
    selectedExpediente,
    carnetActual,
    isModalMatriculaOpen,
    isModalCarnetOpen,
    loading,
    submitting,
    abrirModalMatricula,
    cerrarModalMatricula,
    procesarAsignacion,
    verCarnetExpediente,
    cerrarModalCarnet,
  } = useMatriculacion('ROL-DEC');

  const [searchTerm, setSearchTerm] = useState('');

  // Filtrado de expedientes aprobados
  const expedientesFiltrados = expedientes.filter((item) => {
    const termino = searchTerm.toLowerCase();
    return (
      (item.numeroExpediente && item.numeroExpediente.toLowerCase().includes(termino)) ||
      (item.nombreCompleto && item.nombreCompleto.toLowerCase().includes(termino)) ||
      (item.dniPostulante && item.dniPostulante.includes(termino)) ||
      (item.universidad && item.universidad.toLowerCase().includes(termino))
    );
  });

  // Configuración de Columnas para la BaseDataTable
  const columnas = [
    {
      header: 'Expediente',
      key: 'numeroExpediente',
      render: (row) => (
        <div>
          <div style={{ fontWeight: 700, color: 'var(--color-verde-bosque)' }}>
            {row.numeroExpediente}
          </div>
          <div style={{ fontSize: '0.74rem', color: 'var(--color-gris-carbon)', opacity: 0.8 }}>
            Aprobado: {row.fechaAprobacion ? new Date(row.fechaAprobacion).toLocaleDateString('es-PE') : 'Reciente'}
          </div>
        </div>
      ),
    },
    {
      header: 'Postulante Aprobado',
      key: 'nombreCompleto',
      render: (row) => (
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
          <div
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '50%',
              background: 'linear-gradient(135deg, var(--color-verde-uo), var(--color-verde-bosque))',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 800,
              fontSize: '0.85rem',
              flexShrink: 0,
            }}
          >
            {row.nombreCompleto ? row.nombreCompleto.charAt(0) : 'P'}
          </div>
          <div>
            <div style={{ fontWeight: 700, color: 'var(--color-gris-carbon)', fontSize: '0.88rem' }}>
              {row.nombreCompleto}
            </div>
            <div style={{ fontSize: '0.74rem', color: 'var(--color-gris-carbon)', opacity: 0.8 }}>
              DNI: <strong>{row.dniPostulante}</strong> • Tel: {row.telefono || '964 123 456'}
            </div>
          </div>
        </div>
      ),
    },
    {
      header: 'Grado Académico & SUNEDU',
      key: 'tituloProfesional',
      render: (row) => (
        <div>
          <div style={{ fontWeight: 600, fontSize: '0.84rem', color: 'var(--color-gris-carbon)' }}>
            {row.tituloProfesional || 'LICENCIADO EN ADMINISTRACIÓN'}
          </div>
          <div style={{ fontSize: '0.74rem', color: 'var(--color-verde-uo)', fontWeight: 500 }}>
            {row.universidad}
          </div>
          <div style={{ marginTop: '0.2rem' }}>
            <span
              style={{
                fontSize: '0.66rem',
                fontWeight: 800,
                background: 'rgba(0, 112, 48, 0.12)',
                color: 'var(--color-verde-uo)',
                padding: '0.15rem 0.45rem',
                borderRadius: '4px',
                border: '1px solid rgba(0, 112, 48, 0.3)',
              }}
            >
              ✓ SUNEDU: {row.codigoRegistroSunedu || 'VERIFICADO'}
            </span>
          </div>
        </div>
      ),
    },
    {
      header: 'Acción de Decanatura',
      key: 'acciones',
      align: 'right',
      render: (row) => (
        <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'flex-end' }}>
          <BaseButton
            variant="gold"
            size="sm"
            icon={Award}
            onClick={() => abrirModalMatricula(row)}
          >
            Asignar Matrícula
          </BaseButton>
        </div>
      ),
    },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.75rem' }}>
      {/* Encabezado Estándar de la Página */}
      <BasePageHeader
        title="Formalización de Matrícula Regional y Emisión de Carnet"
        subtitle="Módulo CLI: Alta definitiva en el Padrón Regional, expedición de credencial oficial con QR y firma digital"
        badge="CU-COL-03"
        badgeColor="var(--color-amarillo-zapallo)"
        breadcrumbs={[
          { label: 'Inicio', href: '/' },
          { label: 'Colegiatura (CLI)', href: '/cli' },
          { label: 'Asignación de Matrícula' },
        ]}
      />

      {/* Panel Superior: KPIs de Desempeño y Medallón 3D */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: '1.25rem',
          alignItems: 'stretch',
        }}
      >
        {/* KPI 1: Expedientes Aprobados Listos */}
        <BaseMetricCard
          title="Expedientes Listos para Matrícula"
          value={expedientes.length}
          subtitle="Dictaminados conformes con verificación SUNEDU"
          icon={UserCheck}
          trend="+100%"
          trendLabel="Aprobados en Consejo"
          color="var(--color-verde-uo)"
        />

        {/* KPI 2: Siguiente Correlativo Calculado */}
        <BaseMetricCard
          title="Próxima Matrícula Regional"
          value={siguienteMatricula}
          subtitle="Correlativo único e inalterable CORLAD Junín"
          icon={Award}
          trend="Secuencial"
          trendLabel="Serie Oficial 2026"
          color="var(--color-amarillo-zapallo)"
        />

        {/* Tarjeta Visual: Medallón 3D de Colegiatura Oficial */}
        <div
          style={{
            background: 'linear-gradient(135deg, var(--color-verde-bosque), #003018)',
            borderRadius: 'var(--radius-lg)',
            padding: '1.25rem',
            color: '#FFFFFF',
            boxShadow: 'var(--shadow-md)',
            border: '2px solid var(--color-amarillo-zapallo)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            position: 'relative',
            overflow: 'hidden',
          }}
        >
          <div style={{ flex: 1, zIndex: 2, maxWidth: '65%' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', marginBottom: '0.3rem' }}>
              <Sparkles size={16} color="var(--color-amarillo-electrico)" />
              <span style={{ fontSize: '0.72rem', fontWeight: 800, color: 'var(--color-amarillo-electrico)', letterSpacing: '0.05em' }}>
                CREDENCIAL DIGITAL SEGURA
              </span>
            </div>
            <div style={{ fontSize: '1.05rem', fontWeight: 800, lineHeight: 1.2, marginBottom: '0.4rem' }}>
              Padrón de Colegiados 2026
            </div>
            <div style={{ fontSize: '0.75rem', opacity: 0.85, lineHeight: 1.3 }}>
              Sello holográfico 3D y código QR con verificación en tiempo real (Ley 31060).
            </div>
          </div>

          <div style={{ width: '130px', height: '130px', zIndex: 1 }}>
            <CarnetEmblema3D matricula={siguienteMatricula} />
          </div>
        </div>
      </div>

      {/* Barra de Filtro y Búsqueda Reactiva */}
      <div
        style={{
          background: 'var(--color-blanco-puro)',
          borderRadius: 'var(--radius-lg)',
          padding: '1.25rem 1.5rem',
          boxShadow: 'var(--shadow-sm)',
          border: '1px solid rgba(0,0,0,0.06)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '1rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', flex: 1, minWidth: '260px' }}>
          <div
            style={{
              position: 'relative',
              display: 'flex',
              alignItems: 'center',
              width: '100%',
              maxWidth: '420px',
            }}
          >
            <Search
              size={18}
              color="var(--color-gris-carbon)"
              style={{ position: 'absolute', left: '1rem', pointerEvents: 'none', opacity: 0.6 }}
            />
            <input
              type="text"
              placeholder="Buscar por DNI, postulante, N° expediente o universidad..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                width: '100%',
                padding: '0.65rem 1rem 0.65rem 2.6rem',
                borderRadius: 'var(--radius-md)',
                border: '1.5px solid #D1D5DB',
                fontSize: '0.88rem',
                outline: 'none',
              }}
            />
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.82rem', color: 'var(--color-gris-carbon)' }}>
          <Shield size={16} color="var(--color-verde-uo)" />
          <span>Firma Digital Centralizada: <strong>Activa (X.509)</strong></span>
        </div>
      </div>

      {/* Tabla de Expedientes Aprobados con BaseDataTable */}
      <div
        style={{
          background: 'var(--color-blanco-puro)',
          borderRadius: 'var(--radius-lg)',
          padding: '1.5rem',
          boxShadow: 'var(--shadow-md)',
          border: '1px solid rgba(0,0,0,0.06)',
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.25rem' }}>
          <div>
            <h2 style={{ fontSize: '1.15rem', fontWeight: 800, color: 'var(--color-verde-bosque)' }}>
              Bandeja de Aprobados Listos para Matrícula
            </h2>
            <p style={{ fontSize: '0.8rem', color: 'var(--color-gris-carbon)', opacity: 0.8 }}>
              Expedientes con verificación positiva en SUNEDU y dictamen de aprobación formal
            </p>
          </div>

          <div
            style={{
              background: 'rgba(0, 112, 48, 0.08)',
              color: 'var(--color-verde-uo)',
              padding: '0.35rem 0.75rem',
              borderRadius: 'var(--radius-full)',
              fontSize: '0.78rem',
              fontWeight: 700,
            }}
          >
            {expedientesFiltrados.length} expedientes por formalizar
          </div>
        </div>

        <BaseDataTable
          columns={columnas}
          data={expedientesFiltrados}
          loading={loading}
          emptyMessage="No se encontraron expedientes aprobados pendientes de matrícula regional."
        />
      </div>

      {/* Modal de Asignación de Matrícula */}
      <AsignarMatriculaModal
        isOpen={isModalMatriculaOpen}
        onClose={cerrarModalMatricula}
        expediente={selectedExpediente}
        siguienteMatriculaSugerida={siguienteMatricula}
        onConfirmar={procesarAsignacion}
        submitting={submitting}
      />

      {/* Modal de Visualización de Carnet Digital Interactivo */}
      <BaseModal
        isOpen={isModalCarnetOpen}
        onClose={cerrarModalCarnet}
        title="Carnet Oficial del Colegiado • CORLAD Junín"
        maxWidth="540px"
      >
        <CarnetDigitalCard carnet={carnetActual} onClose={cerrarModalCarnet} />
      </BaseModal>
    </div>
  );
};

export default MatriculacionPage;
