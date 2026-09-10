import React from 'react';
import { BasePageHeader } from '../../../components/base/BasePageHeader';
import { BaseMetricCard } from '../../../components/base/BaseMetricCard';
import { BaseDataTable } from '../../../components/base/BaseDataTable';
import { BaseButton } from '../../../components/base/BaseButton';
import { BaseBadge } from '../../../components/base/BaseBadge';
import { useCalificacion } from '../hooks/useCalificacion';
import { AuditoriaExpedienteModal } from '../components/AuditoriaExpedienteModal';

/**
 * Página Principal para la Calificación de Expedientes y Validación SUNEDU (CU-COL-02).
 * Proporciona el entorno de trabajo para la Secretaría Regional y Comisión Evaluadora.
 */
export const CalificacionPage = () => {
  const {
    expedientes,
    loading,
    selectedExpediente,
    modalAuditoriaOpen,
    suneduLoading,
    suneduResultado,
    dictamenSubmitting,
    cargarBandeja,
    abrirAuditoria,
    cerrarAuditoria,
    consultarSunedu,
    emitirDictamen,
  } = useCalificacion('ROL-SEC');

  // Definición de columnas para BaseDataTable
  const columnas = [
    {
      key: 'numeroExpediente',
      label: 'N.° Expediente',
      render: (valor) => (
        <span className="font-mono font-bold text-[#FEE11A] bg-black/40 px-2.5 py-1 rounded-md border border-[#F5A604]/40">
          {valor}
        </span>
      ),
    },
    {
      key: 'nombrePostulante',
      label: 'Postulante Titulado',
      render: (valor, fila) => (
        <div>
          <div className="font-semibold text-white">{valor}</div>
          <div className="text-xs text-gray-400">DNI: {fila.dniPostulante}</div>
        </div>
      ),
    },
    {
      key: 'universidad',
      label: 'Universidad de Origen',
      render: (valor) => <span className="text-xs text-gray-200">{valor}</span>,
    },
    {
      key: 'tituloProfesional',
      label: 'Grado / Título',
      render: (valor) => <span className="text-xs font-medium text-emerald-400">{valor}</span>,
    },
    {
      key: 'fechaPresentacion',
      label: 'Presentación',
      render: (valor) => (
        <span className="text-xs text-gray-400">
          {new Date(valor).toLocaleDateString()}
        </span>
      ),
    },
    {
      key: 'totalDocumentos',
      label: 'Legajo',
      render: (valor) => (
        <span className="text-xs bg-gray-800 text-gray-300 px-2 py-0.5 rounded border border-gray-700">
          {valor} docs
        </span>
      ),
    },
    {
      key: 'validadoSunedu',
      label: 'SUNEDU',
      render: (valor) => (
        <BaseBadge variant={valor ? 'success' : 'warning'}>
          {valor ? 'VALIDADO' : 'PENDIENTE'}
        </BaseBadge>
      ),
    },
    {
      key: 'estadoRevision',
      label: 'Estado',
      render: (valor) => (
        <BaseBadge variant="info">
          {valor || 'EN REVISIÓN'}
        </BaseBadge>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (_, fila) => (
        <BaseButton
          variant="primary"
          size="sm"
          onClick={() => abrirAuditoria(fila.expedienteId)}
          className="shadow-md shadow-[#007030]/20 text-xs font-semibold"
        >
          Auditar & Calificar
        </BaseButton>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Encabezado Institucional */}
      <BasePageHeader
        title="Bandeja de Calificación Técnica y Verificación SUNEDU"
        subtitle="Módulo CLI: Colegiatura, Padrón y Habilitación - Secretaría Regional"
        breadcrumbs={[
          { label: 'Inicio', href: '/' },
          { label: 'Módulo CLI', href: '#' },
          { label: 'Calificación de Expedientes' },
        ]}
        actions={
          <BaseButton
            variant="secondary"
            size="sm"
            onClick={cargarBandeja}
            isLoading={loading}
          >
            Actualizar Bandeja
          </BaseButton>
        }
      />

      {/* Tarjetas de Métricas Institucionales (KPIs / Cuadro de Mando) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <BaseMetricCard
          title="Expedientes por Calificar"
          value={expedientes.length}
          trend="+12%"
          trendLabel="vs semana anterior"
          variant="default"
          icon={
            <svg className="w-6 h-6 text-[#FEE11A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          }
        />

        <BaseMetricCard
          title="Tasa Verificación SUNEDU"
          value="94.8%"
          trend="+4.2%"
          trendLabel="contrastación digital PIDE"
          variant="success"
          icon={
            <svg className="w-6 h-6 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
          }
        />

        <BaseMetricCard
          title="SLA de Respuesta"
          value="18.5 hrs"
          trend="-35%"
          trendLabel="tiempo de calificación óptimo"
          variant="warning"
          icon={
            <svg className="w-6 h-6 text-[#F5A604]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          }
        />

        <BaseMetricCard
          title="Conformidad Documentaria"
          value="98.2%"
          trend="Excelente"
          trendLabel="integridad con hash SHA-256"
          variant="info"
          icon={
            <svg className="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
            </svg>
          }
        />
      </div>

      {/* Tabla de Expedientes Reactiva con BaseDataTable */}
      <div className="bg-[#1e2324]/80 border border-[#3D4546] rounded-2xl p-5 shadow-2xl backdrop-blur-md">
        <div className="mb-4 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
          <div>
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-[#007030]"></span>
              Expedientes Pendientes de Revisión Técnica
            </h3>
            <p className="text-xs text-gray-400">
              Seleccione un expediente para aperturar el legajo probatorio y contrastar en tiempo real con SUNEDU.
            </p>
          </div>

          <div className="text-xs text-gray-400">
            Total en cola: <span className="font-bold text-[#FEE11A]">{expedientes.length} postulantes</span>
          </div>
        </div>

        <BaseDataTable
          columns={columnas}
          data={expedientes}
          loading={loading}
          searchPlaceholder="Buscar por N.° Expediente, DNI, postulante o universidad..."
          emptyMessage="No hay expedientes pendientes de calificación en este momento."
        />
      </div>

      {/* Modal de Auditoría Documental y Dictamen */}
      <AuditoriaExpedienteModal
        isOpen={modalAuditoriaOpen}
        onClose={cerrarAuditoria}
        expediente={selectedExpediente}
        suneduResultado={suneduResultado}
        suneduLoading={suneduLoading}
        onConsultarSunedu={consultarSunedu}
        onEmitirDictamen={emitirDictamen}
        isSubmitting={dictamenSubmitting}
      />
    </div>
  );
};

export default CalificacionPage;
