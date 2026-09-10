import React from 'react';
import { FileText, ShieldCheck, Clock, CheckCircle } from 'lucide-react';
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
      accessor: 'numeroExpediente',
      header: 'N.° Expediente',
      render: (row) => (
        <span className="font-mono font-bold text-[#FEE11A] bg-black/40 px-2.5 py-1 rounded-md border border-[#F5A604]/40">
          {row.numeroExpediente}
        </span>
      ),
    },
    {
      accessor: 'nombrePostulante',
      header: 'Postulante Titulado',
      render: (row) => (
        <div>
          <div className="font-semibold text-white">{row.nombrePostulante}</div>
          <div className="text-xs text-gray-400">DNI: {row.dniPostulante}</div>
        </div>
      ),
    },
    {
      accessor: 'universidad',
      header: 'Universidad de Origen',
      render: (row) => <span className="text-xs text-gray-200">{row.universidad}</span>,
    },
    {
      accessor: 'tituloProfesional',
      header: 'Grado / Título',
      render: (row) => <span className="text-xs font-medium text-emerald-400">{row.tituloProfesional}</span>,
    },
    {
      accessor: 'fechaPresentacion',
      header: 'Presentación',
      render: (row) => (
        <span className="text-xs text-gray-400">
          {new Date(row.fechaPresentacion).toLocaleDateString()}
        </span>
      ),
    },
    {
      accessor: 'totalDocumentos',
      header: 'Legajo',
      render: (row) => (
        <span className="text-xs bg-gray-800 text-gray-300 px-2 py-0.5 rounded border border-gray-700">
          {row.totalDocumentos} docs
        </span>
      ),
    },
    {
      accessor: 'validadoSunedu',
      header: 'SUNEDU',
      render: (row) => (
        <BaseBadge variant={row.validadoSunedu ? 'success' : 'warning'}>
          {row.validadoSunedu ? 'VALIDADO' : 'PENDIENTE'}
        </BaseBadge>
      ),
    },
    {
      accessor: 'estadoRevision',
      header: 'Estado',
      render: (row) => (
        <BaseBadge variant="info">
          {row.estadoRevision || 'EN REVISIÓN'}
        </BaseBadge>
      ),
    },
    {
      accessor: 'acciones',
      header: 'Acciones',
      render: (row) => (
        <BaseButton
          variant="primary"
          size="sm"
          onClick={() => abrirAuditoria(row.expedienteId)}
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
          icon={FileText}
          color="var(--color-amarillo-zapallo)"
        />

        <BaseMetricCard
          title="Tasa Verificación SUNEDU"
          value="94.8%"
          trend="+4.2%"
          trendLabel="contrastación digital PIDE"
          icon={ShieldCheck}
          color="var(--color-verde-uo)"
        />

        <BaseMetricCard
          title="SLA de Respuesta"
          value="18.5 hrs"
          trend="-35%"
          trendLabel="tiempo de calificación óptimo"
          icon={Clock}
          color="var(--color-amarillo-zapallo)"
        />

        <BaseMetricCard
          title="Conformidad Documentaria"
          value="98.2%"
          trend="Excelente"
          trendLabel="integridad con hash SHA-256"
          icon={CheckCircle}
          color="var(--color-verde-uo)"
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
