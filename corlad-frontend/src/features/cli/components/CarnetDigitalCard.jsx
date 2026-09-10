import React, { useState, useRef, useEffect } from 'react';
import { Shield, Award, QrCode, CheckCircle2, Copy, Download, Printer, RotateCw, Sparkles, Lock } from 'lucide-react';
import { BaseButton } from '../../../components/base/BaseButton';
import { BaseBadge } from '../../../components/base/BaseBadge';
import { useNotification } from '../../../hooks/useNotification';
import gsap from 'gsap';

/**
 * Componente Credencial Oficial / Carnet Digital Interactivo del CORLAD Junín.
 * Renderiza el carnet con formato físico estándar ID-1, efecto de giro 3D (Flip Card),
 * código QR institucional de validación, sello de fe pública y hash SHA-256 inmutable.
 */
export const CarnetDigitalCard = ({ carnet, onClose }) => {
  const [isFlipped, setIsFlipped] = useState(false);
  const cardRef = useRef(null);
  const notification = useNotification();

  useEffect(() => {
    if (cardRef.current) {
      gsap.fromTo(
        cardRef.current,
        { scale: 0.88, opacity: 0, y: 30 },
        { scale: 1, opacity: 1, y: 0, duration: 0.6, ease: 'back.out(1.4)' }
      );
    }
  }, []);

  if (!carnet) return null;

  const copiarHash = () => {
    if (carnet.hashSeguridad) {
      navigator.clipboard.writeText(carnet.hashSeguridad);
      notification.success('Hash Copiado', 'El código hash SHA-256 fue copiado al portapapeles.');
    }
  };

  const handleImprimir = () => {
    window.print();
  };

  const handleDescargar = () => {
    notification.success(
      'Generando Documento PDF',
      `Descargando Carnet Oficial Digital para ${carnet.nombreCompleto} (${carnet.matriculaRegional})...`
    );
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1.5rem', width: '100%' }}>
      {/* Selector de Cara de Carnet */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', justifyContent: 'center' }}>
        <button
          type="button"
          onClick={() => setIsFlipped(false)}
          style={{
            padding: '0.4rem 1rem',
            borderRadius: 'var(--radius-full)',
            fontSize: '0.82rem',
            fontWeight: !isFlipped ? 700 : 500,
            background: !isFlipped ? 'var(--color-verde-uo)' : 'rgba(0,0,0,0.05)',
            color: !isFlipped ? '#FFFFFF' : 'var(--color-gris-carbon)',
            border: 'none',
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
        >
          Anverso (Frontal)
        </button>
        <button
          type="button"
          onClick={() => setIsFlipped(true)}
          style={{
            padding: '0.4rem 1rem',
            borderRadius: 'var(--radius-full)',
            fontSize: '0.82rem',
            fontWeight: isFlipped ? 700 : 500,
            background: isFlipped ? 'var(--color-verde-uo)' : 'rgba(0,0,0,0.05)',
            color: isFlipped ? '#FFFFFF' : 'var(--color-gris-carbon)',
            border: 'none',
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
        >
          Reverso (QR & Firmas)
        </button>
      </div>

      {/* Contenedor del Carnet con efecto de perspectiva 3D */}
      <div
        ref={cardRef}
        style={{
          perspective: '1000px',
          width: '100%',
          maxWidth: '460px',
          height: '285px',
        }}
      >
        <div
          style={{
            position: 'relative',
            width: '100%',
            height: '100%',
            transformStyle: 'preserve-3d',
            transition: 'transform 0.7s cubic-bezier(0.4, 0.2, 0.2, 1)',
            transform: isFlipped ? 'rotateY(180deg)' : 'rotateY(0deg)',
          }}
        >
          {/* ============================================================ */}
          {/* CARA ANVERSO (Frente de la Credencial) */}
          {/* ============================================================ */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              backfaceVisibility: 'hidden',
              borderRadius: '16px',
              overflow: 'hidden',
              background: 'linear-gradient(135deg, #004D30 0%, #007030 45%, #003622 100%)',
              color: '#FFFFFF',
              boxShadow: '0 20px 35px -10px rgba(0, 77, 48, 0.4), 0 0 0 1.5px rgba(245, 166, 4, 0.6)',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              padding: '1.2rem',
              userSelect: 'none',
            }}
          >
            {/* Patrón de seguridad de fondo */}
            <div
              style={{
                position: 'absolute',
                inset: 0,
                backgroundImage: 'radial-gradient(circle at 85% 15%, rgba(245, 166, 4, 0.18) 0%, transparent 55%), radial-gradient(circle at 15% 85%, rgba(254, 225, 26, 0.12) 0%, transparent 50%)',
                pointerEvents: 'none',
              }}
            />

            {/* Cabecera del Carnet */}
            <div style={{ position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.2)', paddingBottom: '0.6rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
                <div
                  style={{
                    width: '36px',
                    height: '36px',
                    borderRadius: '8px',
                    background: 'linear-gradient(135deg, var(--color-amarillo-zapallo), var(--color-amarillo-electrico))',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: '#000000',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.25)',
                  }}
                >
                  <Shield size={22} color="#004D30" />
                </div>
                <div>
                  <div style={{ fontSize: '0.74rem', fontWeight: 800, letterSpacing: '0.04em', color: '#FFFFFF', lineHeight: 1.1 }}>
                    COLEGIO REGIONAL DE LICENCIADOS EN ADMINISTRACIÓN
                  </div>
                  <div style={{ fontSize: '0.68rem', fontWeight: 700, color: 'var(--color-amarillo-electrico)', letterSpacing: '0.05em' }}>
                    CORLAD JUNÍN • SEDE HUANCAYO
                  </div>
                </div>
              </div>
              <div
                style={{
                  background: 'rgba(0,0,0,0.3)',
                  border: '1px solid var(--color-amarillo-zapallo)',
                  borderRadius: '4px',
                  padding: '0.15rem 0.45rem',
                  fontSize: '0.62rem',
                  fontWeight: 700,
                  color: 'var(--color-amarillo-zapallo)',
                  letterSpacing: '0.05em',
                }}
              >
                CARNET OFICIAL
              </div>
            </div>

            {/* Cuerpo del Carnet: Foto y Datos del Colegiado */}
            <div style={{ position: 'relative', display: 'flex', gap: '1rem', alignItems: 'center', margin: '0.4rem 0' }}>
              {/* Marco Fotográfico Oficial */}
              <div
                style={{
                  width: '84px',
                  height: '106px',
                  borderRadius: '8px',
                  background: 'linear-gradient(180deg, #FFFFFF, #E5E7EB)',
                  border: '2px solid var(--color-amarillo-zapallo)',
                  boxShadow: '0 4px 10px rgba(0,0,0,0.3)',
                  overflow: 'hidden',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                  position: 'relative',
                }}
              >
                <img
                  src={carnet.fotoUrl || '/assets/postulante_foto_default.png'}
                  alt={carnet.nombreCompleto}
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  onError={(e) => {
                    e.target.onerror = null;
                    e.target.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(carnet.nombreCompleto) + '&background=007030&color=fff&size=200';
                  }}
                />
                <div
                  style={{
                    position: 'absolute',
                    bottom: 0,
                    left: 0,
                    right: 0,
                    background: 'rgba(0, 77, 48, 0.85)',
                    fontSize: '0.52rem',
                    textAlign: 'center',
                    color: '#FFF',
                    padding: '1px 0',
                    fontWeight: 700,
                  }}
                >
                  TITULADO
                </div>
              </div>

              {/* Datos Personales y Académicos */}
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: '0.92rem', fontWeight: 800, color: '#FFFFFF', lineHeight: 1.2, textTransform: 'uppercase', marginBottom: '0.2rem' }}>
                  {carnet.nombreCompleto}
                </div>
                <div style={{ fontSize: '0.7rem', color: 'var(--color-amarillo-electrico)', fontWeight: 600, textTransform: 'uppercase', marginBottom: '0.25rem' }}>
                  {carnet.tituloProfesional || 'LICENCIADO EN ADMINISTRACIÓN'}
                </div>
                <div style={{ fontSize: '0.64rem', color: 'rgba(255,255,255,0.8)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', marginBottom: '0.35rem' }}>
                  {carnet.universidad}
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '0.3rem', fontSize: '0.64rem' }}>
                  <div>
                    <span style={{ color: 'rgba(255,255,255,0.6)', display: 'block', fontSize: '0.56rem' }}>DNI / IDENTIDAD</span>
                    <strong style={{ letterSpacing: '0.04em' }}>{carnet.dni}</strong>
                  </div>
                  <div>
                    <span style={{ color: 'rgba(255,255,255,0.6)', display: 'block', fontSize: '0.56rem' }}>INCORPORACIÓN</span>
                    <strong>{carnet.fechaIncorporacion ? new Date(carnet.fechaIncorporacion).toLocaleDateString('es-PE') : '15/09/2026'}</strong>
                  </div>
                </div>
              </div>
            </div>

            {/* Pie del Anverso: Barra Dorada de Matrícula */}
            <div
              style={{
                position: 'relative',
                background: 'linear-gradient(90deg, rgba(245, 166, 4, 0.95), rgba(254, 225, 26, 0.95))',
                borderRadius: '6px',
                padding: '0.35rem 0.65rem',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                color: '#000000',
              }}
            >
              <div>
                <span style={{ fontSize: '0.54rem', fontWeight: 700, textTransform: 'uppercase', color: '#003622', display: 'block', lineHeight: 1 }}>
                  MATRÍCULA REGIONAL JUNÍN
                </span>
                <span style={{ fontSize: '0.92rem', fontWeight: 900, letterSpacing: '0.05em', color: '#004D30' }}>
                  {carnet.matriculaRegional}
                </span>
              </div>

              {carnet.matriculaNacional && (
                <div style={{ textAlign: 'right' }}>
                  <span style={{ fontSize: '0.54rem', fontWeight: 700, textTransform: 'uppercase', color: '#003622', display: 'block', lineHeight: 1 }}>
                    REGISTRO NACIONAL CLAD
                  </span>
                  <span style={{ fontSize: '0.78rem', fontWeight: 800, color: '#004D30' }}>
                    {carnet.matriculaNacional}
                  </span>
                </div>
              )}

              <div
                style={{
                  background: 'var(--color-verde-bosque)',
                  color: '#FFFFFF',
                  padding: '0.2rem 0.5rem',
                  borderRadius: '4px',
                  fontSize: '0.62rem',
                  fontWeight: 800,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.25rem',
                }}
              >
                <Sparkles size={11} color="var(--color-amarillo-electrico)" />
                {carnet.estadoHabilidad || 'HÁBIL'}
              </div>
            </div>
          </div>

          {/* ============================================================ */}
          {/* CARA REVERSO (Atrás de la Credencial: QR y Firmas) */}
          {/* ============================================================ */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              backfaceVisibility: 'hidden',
              transform: 'rotateY(180deg)',
              borderRadius: '16px',
              overflow: 'hidden',
              background: 'linear-gradient(135deg, #111827 0%, #1F2937 60%, #004D30 100%)',
              color: '#FFFFFF',
              boxShadow: '0 20px 35px -10px rgba(0, 0, 0, 0.5), 0 0 0 1.5px rgba(245, 166, 4, 0.6)',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              padding: '1.2rem',
              userSelect: 'none',
            }}
          >
            {/* Cabecera del Reverso */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.15)', paddingBottom: '0.4rem' }}>
              <span style={{ fontSize: '0.64rem', fontWeight: 700, color: 'var(--color-amarillo-electrico)', letterSpacing: '0.04em' }}>
                VALIDACIÓN DE HABILIDAD Y EJERCICIO PROFESIONAL
              </span>
              <span style={{ fontSize: '0.58rem', color: 'rgba(255,255,255,0.6)' }}>
                LEY N° 31060 • D.L. 22087
              </span>
            </div>

            {/* Contenido Central: QR y Firmas Digitales */}
            <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
              {/* Código QR de Validación Dinámica */}
              <div
                style={{
                  background: '#FFFFFF',
                  padding: '6px',
                  borderRadius: '8px',
                  boxShadow: '0 4px 10px rgba(0,0,0,0.4)',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  flexShrink: 0,
                }}
              >
                <img
                  src={`https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=${encodeURIComponent(carnet.codigoQRUrl || 'https://validador.corladjunin.org.pe')}`}
                  alt="QR Validación"
                  style={{ width: '84px', height: '84px', display: 'block' }}
                />
                <span style={{ fontSize: '0.5rem', fontWeight: 800, color: '#004D30', marginTop: '3px' }}>
                  ESCANEAR CON QR
                </span>
              </div>

              {/* Sellos de Firma Digital Decanato y Secretaría */}
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                <div style={{ fontSize: '0.62rem', color: 'rgba(255,255,255,0.85)', lineHeight: 1.3 }}>
                  <div><strong>Resolución:</strong> {carnet.numeroResolucion}</div>
                  <div><strong>Vigencia:</strong> Hasta {carnet.fechaCaducidad ? new Date(carnet.fechaCaducidad).toLocaleDateString('es-PE') : '31/12/2031'}</div>
                </div>

                {/* Firmas representativas */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '0.5rem', marginTop: '0.2rem' }}>
                  <div style={{ borderTop: '1px dashed rgba(255,255,255,0.3)', paddingTop: '0.2rem', textAlign: 'center' }}>
                    <div style={{ fontSize: '0.52rem', fontWeight: 700, color: 'var(--color-amarillo-zapallo)' }}>
                      Lic. Adm. Decano Regional
                    </div>
                    <div style={{ fontSize: '0.48rem', color: 'rgba(255,255,255,0.6)' }}>Firma Digital Certificada</div>
                  </div>
                  <div style={{ borderTop: '1px dashed rgba(255,255,255,0.3)', paddingTop: '0.2rem', textAlign: 'center' }}>
                    <div style={{ fontSize: '0.52rem', fontWeight: 700, color: 'var(--color-amarillo-zapallo)' }}>
                      Lic. Adm. Secretaria Regional
                    </div>
                    <div style={{ fontSize: '0.48rem', color: 'rgba(255,255,255,0.6)' }}>Firma Digital Certificada</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Hash Criptográfico SHA-256 */}
            <div
              style={{
                background: 'rgba(0,0,0,0.4)',
                border: '1px solid rgba(255,255,255,0.15)',
                borderRadius: '6px',
                padding: '0.35rem 0.5rem',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <div style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', marginRight: '0.5rem' }}>
                <span style={{ fontSize: '0.52rem', color: 'rgba(255,255,255,0.5)', display: 'block', lineHeight: 1 }}>
                  HASH CRIPTOGRÁFICO DE AUTENTICIDAD (SHA-256)
                </span>
                <span style={{ fontSize: '0.58rem', fontFamily: 'monospace', color: 'var(--color-amarillo-electrico)' }}>
                  {carnet.hashSeguridad}
                </span>
              </div>
              <button
                type="button"
                onClick={copiarHash}
                title="Copiar Hash"
                style={{
                  background: 'none',
                  border: 'none',
                  color: '#FFFFFF',
                  cursor: 'pointer',
                  padding: '2px',
                  display: 'flex',
                }}
              >
                <Copy size={13} />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Botones de Acción de la Credencial */}
      <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap', justifyContent: 'center' }}>
        <BaseButton
          variant="outline"
          size="sm"
          icon={RotateCw}
          onClick={() => setIsFlipped(!isFlipped)}
        >
          {isFlipped ? 'Ver Anverso' : 'Ver Reverso (QR)'}
        </BaseButton>

        <BaseButton
          variant="primary"
          size="sm"
          icon={Download}
          onClick={handleDescargar}
        >
          Descargar PDF Digital
        </BaseButton>

        <BaseButton
          variant="secondary"
          size="sm"
          icon={Printer}
          onClick={handleImprimir}
        >
          Imprimir Credencial
        </BaseButton>
      </div>
    </div>
  );
};

export default CarnetDigitalCard;
