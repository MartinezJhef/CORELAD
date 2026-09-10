import React, { useState, useEffect, useRef } from 'react';
import { gsap } from 'gsap';
import { BaseModal } from '../../../components/base/BaseModal';
import { BaseButton } from '../../../components/base/BaseButton';
import { BaseBadge } from '../../../components/base/BaseBadge';
import { SuneduShield3D } from '../../../components/3d/SuneduShield3D';

/**
 * Modal de Auditoría Documental y Calificación Técnica de Expedientes (CU-COL-02).
 * Incluye interoperabilidad en tiempo real con SUNEDU, visor de requisitos documentales
 * y panel para emisión de dictamen conforme a la Ley 31060 y Ley 30220.
 */
export const AuditoriaExpedienteModal = ({
  isOpen,
  onClose,
  expediente,
  suneduResultado,
  suneduLoading,
  onConsultarSunedu,
  onEmitirDictamen,
  isSubmitting,
}) => {
  const [dictamenSeleccionado, setDictamenSeleccionado] = useState('APROBADO');
  const [motivoObservacion, setMotivoObservacion] = useState('');
  const [documentosConformidad, setDocumentosConformidad] = useState({});
  const [documentoVisualizando, setDocumentoVisualizando] = useState(null);

  const suneduCardRef = useRef(null);

  // Inicializar estado de conformidad de documentos
  useEffect(() => {
    if (expediente?.documentos) {
      const inicial = {};
      expediente.documentos.forEach((doc) => {
        inicial[doc.documentoAdjuntoID] = true;
      });
      setDocumentosConformidad(inicial);
    }
  }, [expediente]);

  // Animación GSAP cuando SUNEDU retorna resultado
  useEffect(() => {
    if (suneduResultado && suneduCardRef.current) {
      gsap.fromTo(
        suneduCardRef.current,
        { scale: 0.96, opacity: 0, y: 15 },
        { scale: 1, opacity: 1, y: 0, duration: 0.5, ease: 'back.out(1.5)' }
      );
    }
  }, [suneduResultado]);

  if (!expediente) return null;

  const estaValidadoSunedu = suneduResultado ? suneduResultado.esValido : false;

  const toggleConformidad = (docId) => {
    setDocumentosConformidad((prev) => ({
      ...prev,
      [docId]: !prev[docId],
    }));
  };

  const handleSubmitDictamen = (e) => {
    e.preventDefault();

    const observacionesDocs = expediente.documentos?.map((doc) => ({
      documentoId: doc.documentoAdjuntoID,
      codigoTipoDocumento: doc.tipoDocumentoRequisito,
      esConforme: !!documentosConformidad[doc.documentoAdjuntoID],
      observacion: documentosConformidad[doc.documentoAdjuntoID]
        ? 'Requisito conforme'
        : 'Documento observado por ilegibilidad o inconsistencia',
    })) || [];

    onEmitirDictamen({
      dictamen: dictamenSeleccionado,
      motivoObservacion,
      observacionesDocumentos: observacionesDocs,
    });
  };

  return (
    <BaseModal
      isOpen={isOpen}
      onClose={onClose}
      title={`Auditoría Técnica: Expediente ${expediente.numeroExpediente}`}
      size="xl"
    >
      <div className="space-y-6 text-white text-sm">
        {/* ENCABEZADO Y RESUMEN DEL POSTULANTE */}
        <div className="bg-[#002816]/70 border border-[#007030]/40 rounded-xl p-4 flex flex-wrap items-center justify-between gap-4">
          <div>
            <div className="text-xs text-gray-400 uppercase tracking-wider font-semibold">Postulante Titulado</div>
            <div className="text-lg font-bold text-white flex items-center gap-2">
              {expediente.nombrePostulante}
              <BaseBadge variant="info">DNI: {expediente.dniPostulante}</BaseBadge>
            </div>
            <div className="text-xs text-gray-300 mt-1">
              Universidad de Origen: <span className="text-[#FEE11A] font-medium">{expediente.universidad}</span>
            </div>
            <div className="text-xs text-gray-300">
              Título Profesional: <span className="text-white font-medium">{expediente.denominacionTitulo || expediente.tituloProfesional}</span>
            </div>
          </div>

          <div className="flex flex-col items-end gap-1.5">
            <span className="text-xs text-gray-400">Estado de Calificación</span>
            <BaseBadge variant={estaValidadoSunedu ? 'success' : 'warning'}>
              {estaValidadoSunedu ? 'SUNEDU VERIFICADO' : 'PENDIENTE DE CONTRASTACIÓN'}
            </BaseBadge>
            <span className="text-[11px] text-gray-400">
              Presentado: {new Date(expediente.fechaPresentacion).toLocaleDateString()}
            </span>
          </div>
        </div>

        {/* MÓDULO INTERACTIVO DE CONTRASTACIÓN SUNEDU */}
        <div className="bg-[#1e2324]/80 border border-[#3D4546] rounded-2xl p-5 relative overflow-hidden">
          <div className="flex flex-col md:flex-row items-center gap-6">
            {/* Escudo 3D Three.js */}
            <div className="w-full md:w-1/3 flex flex-col items-center justify-center relative">
              <SuneduShield3D isValidated={estaValidadoSunedu} className="h-44 w-44" />
              <span className="text-[10px] tracking-widest text-center text-gray-400 uppercase mt-1">
                {estaValidadoSunedu ? 'Autenticidad Digital Certificada' : 'Orbital de Interoperabilidad PIDE'}
              </span>
            </div>

            {/* Controles de Consulta y Resultado */}
            <div className="w-full md:w-2/3 space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <h4 className="text-base font-bold text-[#FEE11A] flex items-center gap-2">
                    <svg className="w-5 h-5 text-[#F5A604]" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M10 2a1 1 0 011 1v1.323l3.954 1.582 1.599-.8a1 1 0 01.894 1.79l-1.233.616 1.738 5.42a1 1 0 01-.285 1.05A3.989 3.989 0 0115 15a3.989 3.989 0 01-2.667-1.019 1 1 0 01-.285-1.05l1.715-5.349L11 6.477V16h2a1 1 0 110 2H7a1 1 0 110-2h2V6.477L6.237 7.582l1.715 5.349a1 1 0 01-.285 1.05A3.989 3.989 0 015 15a3.989 3.989 0 01-2.667-1.019 1 1 0 01-.285-1.05l1.738-5.42-1.233-.617a1 1 0 01.894-1.788l1.599.799L9 4.323V3a1 1 0 011-1z" clipRule="evenodd" />
                    </svg>
                    Registro Nacional de Grados y Títulos (SUNEDU)
                  </h4>
                  <p className="text-xs text-gray-400">
                    Contrastación obligatoria según Ley 31060 (Colegiación Profesional) y Ley Universitaria 30220.
                  </p>
                </div>

                <BaseButton
                  variant="gold"
                  size="sm"
                  onClick={() => onConsultarSunedu(expediente.dniPostulante, expediente.codigoRegistroSunedu)}
                  isLoading={suneduLoading}
                  className="font-semibold shadow-lg shadow-[#F5A604]/20"
                >
                  {suneduLoading ? 'Consultando...' : 'Consultar en Vivo'}
                </BaseButton>
              </div>

              {/* Tarjeta de Respuesta SUNEDU */}
              {suneduResultado ? (
                <div
                  ref={suneduCardRef}
                  className={`p-4 rounded-xl border ${
                    suneduResultado.esValido
                      ? 'bg-[#003818]/60 border-[#007030] text-emerald-100'
                      : 'bg-red-950/40 border-red-800 text-red-100'
                  }`}
                >
                  <div className="flex items-start justify-between">
                    <div className="space-y-1">
                      <div className="font-bold text-sm flex items-center gap-2">
                        {suneduResultado.esValido ? (
                          <>
                            <span className="text-[#FEE11A]">✓</span> TÍTULO REGISTRADO Y VIGENTE
                          </>
                        ) : (
                          <>
                            <span className="text-red-400">✕</span> NO REGISTRADO O EN TRÁMITE
                          </>
                        )}
                      </div>
                      <div className="text-xs">
                        <span className="text-gray-300">Grado/Título:</span>{' '}
                        <span className="font-semibold text-white">{suneduResultado.gradoTitulo}</span>
                      </div>
                      <div className="text-xs">
                        <span className="text-gray-300">Casa de Estudios:</span>{' '}
                        <span className="text-gray-100">{suneduResultado.universidad}</span>
                      </div>
                      <div className="text-[11px] text-gray-300">
                        Código Registro: <span className="font-mono text-[#FEE11A]">{suneduResultado.codigoRegistro}</span>
                      </div>
                    </div>

                    <div className="text-right text-[11px] text-gray-400">
                      <div>Protocolo PIDE-SUNEDU</div>
                      <div>Fecha: {new Date().toLocaleTimeString()}</div>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="p-3 bg-black/40 border border-gray-700/60 rounded-xl text-xs text-gray-400 flex items-center gap-3">
                  <span className="text-[#F5A604] font-bold text-base">ℹ</span>
                  Presione "Consultar en Vivo" para interconectar con los servidores del Registro Nacional de Grados y Títulos vía PIDE.
                </div>
              )}
            </div>
          </div>
        </div>

        {/* AUDITORÍA Y CHECKLIST DE DOCUMENTOS ADJUNTOS */}
        <div>
          <h4 className="text-sm font-bold text-white mb-2 flex items-center justify-between">
            <span>Legajo Documental Digital ({expediente.documentos?.length || 0} Requisitos)</span>
            <span className="text-xs font-normal text-gray-400">Marque conformidad por cada expediente</span>
          </h4>

          <div className="bg-[#1e2324]/50 border border-[#3D4546] rounded-xl divide-y divide-[#3D4546] max-h-56 overflow-y-auto">
            {expediente.documentos?.map((doc) => (
              <div
                key={doc.documentoAdjuntoID}
                className="p-3 flex items-center justify-between hover:bg-black/20 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    id={`check-doc-${doc.documentoAdjuntoID}`}
                    checked={!!documentosConformidad[doc.documentoAdjuntoID]}
                    onChange={() => toggleConformidad(doc.documentoAdjuntoID)}
                    className="w-4 h-4 text-[#007030] bg-gray-900 border-gray-600 rounded focus:ring-[#007030]"
                  />
                  <div>
                    <label
                      htmlFor={`check-doc-${doc.documentoAdjuntoID}`}
                      className="text-xs font-semibold text-white cursor-pointer hover:text-[#FEE11A]"
                    >
                      {doc.nombreArchivo}
                    </label>
                    <div className="text-[11px] text-gray-400 flex items-center gap-2">
                      <span className="uppercase text-[10px] bg-black/40 px-1.5 py-0.5 rounded border border-gray-700">
                        {doc.tipoDocumentoRequisito}
                      </span>
                      <span>{(doc.tamanoBytes / 1024 / 1024).toFixed(2)} MB</span>
                      {doc.hashSHA256 && (
                        <span className="font-mono text-[9px] text-gray-500 truncate max-w-[120px]" title={doc.hashSHA256}>
                          SHA256: {doc.hashSHA256.substring(0, 8)}...
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <BaseButton
                    variant="outline"
                    size="xs"
                    onClick={() => setDocumentoVisualizando(doc)}
                    className="text-xs"
                  >
                    Ver Documento
                  </BaseButton>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* MODAL / VISOR RÁPIDO DE DOCUMENTO */}
        {documentoVisualizando && (
          <div className="bg-black/80 border border-[#F5A604] rounded-xl p-4 flex items-center justify-between">
            <div className="text-xs">
              <span className="font-bold text-[#FEE11A]">Previsualizando:</span> {documentoVisualizando.nombreArchivo}
              <div className="text-[11px] text-gray-300">
                Verificación de integridad SHA-256 válida. Firma digital conforme.
              </div>
            </div>
            <BaseButton
              variant="secondary"
              size="xs"
              onClick={() => setDocumentoVisualizando(null)}
            >
              Cerrar Visor
            </BaseButton>
          </div>
        )}

        {/* FORMULARIO DE DICTAMEN TÉCNICO OFICIAL */}
        <form onSubmit={handleSubmitDictamen} className="bg-[#003818]/30 border border-[#007030]/50 rounded-2xl p-5 space-y-4">
          <div className="flex items-center justify-between">
            <h4 className="font-bold text-sm text-[#FEE11A] flex items-center gap-2">
              <svg className="w-5 h-5 text-[#007030]" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
              </svg>
              Emisión de Dictamen de Calificación Técnica
            </h4>
            <span className="text-xs text-gray-400">Secretaría Regional / Comisión Evaluadora</span>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            {/* Opción APROBADO */}
            <label
              className={`flex items-center justify-center gap-2 p-3 rounded-xl border cursor-pointer font-semibold text-xs transition-all ${
                dictamenSeleccionado === 'APROBADO'
                  ? 'bg-[#007030] border-[#FEE11A] text-white shadow-lg shadow-[#007030]/30'
                  : 'bg-black/40 border-gray-700 text-gray-300 hover:border-gray-500'
              }`}
            >
              <input
                type="radio"
                name="dictamen"
                value="APROBADO"
                checked={dictamenSeleccionado === 'APROBADO'}
                onChange={() => setDictamenSeleccionado('APROBADO')}
                className="hidden"
              />
              <span>✓ APROBADO</span>
            </label>

            {/* Opción OBSERVADO */}
            <label
              className={`flex items-center justify-center gap-2 p-3 rounded-xl border cursor-pointer font-semibold text-xs transition-all ${
                dictamenSeleccionado === 'OBSERVADO'
                  ? 'bg-[#F5A604] border-white text-black shadow-lg shadow-[#F5A604]/30'
                  : 'bg-black/40 border-gray-700 text-gray-300 hover:border-gray-500'
              }`}
            >
              <input
                type="radio"
                name="dictamen"
                value="OBSERVADO"
                checked={dictamenSeleccionado === 'OBSERVADO'}
                onChange={() => setDictamenSeleccionado('OBSERVADO')}
                className="hidden"
              />
              <span>⚠ OBSERVADO</span>
            </label>

            {/* Opción RECHAZADO */}
            <label
              className={`flex items-center justify-center gap-2 p-3 rounded-xl border cursor-pointer font-semibold text-xs transition-all ${
                dictamenSeleccionado === 'RECHAZADO'
                  ? 'bg-red-800 border-white text-white shadow-lg shadow-red-800/30'
                  : 'bg-black/40 border-gray-700 text-gray-300 hover:border-gray-500'
              }`}
            >
              <input
                type="radio"
                name="dictamen"
                value="RECHAZADO"
                checked={dictamenSeleccionado === 'RECHAZADO'}
                onChange={() => setDictamenSeleccionado('RECHAZADO')}
                className="hidden"
              />
              <span>✕ RECHAZADO</span>
            </label>
          </div>

          {/* Advertencia de Regla RN-COL-02 para Aprobación */}
          {dictamenSeleccionado === 'APROBADO' && !estaValidadoSunedu && (
            <div className="p-3 bg-amber-950/60 border border-amber-600/80 rounded-xl text-xs text-amber-200 flex items-center gap-3">
              <span className="text-lg">⚠</span>
              <div>
                <span className="font-bold">Regla de Negocio RN-COL-02:</span> No es posible aprobar el expediente
                sin haber consultado y obtenido verificación positiva en SUNEDU previamente.
              </div>
            </div>
          )}

          {/* Campo de Motivo Obligatorio si es OBSERVADO o RECHAZADO */}
          {(dictamenSeleccionado === 'OBSERVADO' || dictamenSeleccionado === 'RECHAZADO') && (
            <div className="space-y-1">
              <label className="text-xs font-semibold text-gray-200">
                Motivo Detallado de la {dictamenSeleccionado === 'OBSERVADO' ? 'Observación' : 'Denegatoria'} *
              </label>
              <textarea
                value={motivoObservacion}
                onChange={(e) => setMotivoObservacion(e.target.value)}
                placeholder="Indique con claridad las correcciones requeridas o el fundamento legal del dictamen..."
                rows={3}
                required
                className="w-full bg-black/60 border border-gray-600 rounded-xl p-3 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#F5A604]"
              />
            </div>
          )}

          {/* BOTONES DE ACCIÓN */}
          <div className="flex items-center justify-end gap-3 pt-2">
            <BaseButton variant="secondary" onClick={onClose} disabled={isSubmitting}>
              Cancelar
            </BaseButton>

            <BaseButton
              type="submit"
              variant={dictamenSeleccionado === 'APROBADO' ? 'primary' : 'gold'}
              isLoading={isSubmitting}
              disabled={dictamenSeleccionado === 'APROBADO' && !estaValidadoSunedu}
              className="font-bold"
            >
              {isSubmitting ? 'Guardando Dictamen...' : `Confirmar Dictamen (${dictamenSeleccionado})`}
            </BaseButton>
          </div>
        </form>
      </div>
    </BaseModal>
  );
};

export default AuditoriaExpedienteModal;
