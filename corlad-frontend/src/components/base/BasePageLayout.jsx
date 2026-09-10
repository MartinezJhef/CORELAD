import React, { useState } from 'react';
import { BaseNotification } from './BaseNotification';
import { Menu, X, Shield, FileText, Search, UserCheck, Award, Phone, Mail, MapPin } from 'lucide-react';
import { BaseButton } from './BaseButton';

export const BasePageLayout = ({ children, activeModule = 'CLI', currentView = 'CALIF', onViewChange, onTrackingClick }) => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <BaseNotification />

      {/* Barra Superior Institucional */}
      <div
        style={{
          background: 'var(--color-verde-bosque)',
          color: 'rgba(255, 255, 255, 0.85)',
          fontSize: '0.78rem',
          padding: '0.4rem 1.5rem',
          borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
        }}
      >
        <div
          className="container"
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: '0.5rem',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
              <MapPin size={13} color="var(--color-amarillo-zapallo)" /> Av. Giráldez N° 230 - Huancayo, Junín
            </span>
            <span style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
              <Phone size={13} color="var(--color-amarillo-zapallo)" /> (064) 234567 / 964 123 456
            </span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
              <Mail size={13} color="var(--color-amarillo-zapallo)" /> informes@corladjunin.org.pe
            </span>
            <span style={{ color: 'var(--color-amarillo-electrico)', fontWeight: 600 }}>
              Mesa de Partes Digital 2026
            </span>
          </div>
        </div>
      </div>

      {/* Cabecera Principal */}
      <header
        style={{
          background: 'var(--color-blanco-puro)',
          borderBottom: '3px solid var(--color-amarillo-zapallo)',
          boxShadow: 'var(--shadow-md)',
          position: 'sticky',
          top: 0,
          zIndex: 8000,
        }}
      >
        <div
          className="container"
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            paddingTop: '0.85rem',
            paddingBottom: '0.85rem',
          }}
        >
          {/* Logotipo Institucional */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.85rem' }}>
            <div
              style={{
                width: '46px',
                height: '46px',
                borderRadius: 'var(--radius-md)',
                background: 'linear-gradient(135deg, var(--color-verde-uo), var(--color-verde-bosque))',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'var(--color-blanco-puro)',
                boxShadow: 'var(--shadow-sm)',
                border: '1.5px solid var(--color-amarillo-zapallo)',
              }}
            >
              <Shield size={26} color="var(--color-amarillo-electrico)" />
            </div>
            <div>
              <div style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--color-verde-bosque)', letterSpacing: '0.02em', lineHeight: 1.1 }}>
                CORLAD <span style={{ color: 'var(--color-amarillo-zapallo)' }}>JUNÍN</span>
              </div>
              <div style={{ fontSize: '0.72rem', color: 'var(--color-gris-carbon)', fontWeight: 600, textTransform: 'uppercase' }}>
                Colegio Regional de Licenciados en Administración
              </div>
            </div>
          </div>

          {/* Navegación Desktop */}
          <nav
            style={{
              display: 'none',
              alignItems: 'center',
              gap: '1.25rem',
            }}
            className="desktop-nav"
          >
            <button
              type="button"
              onClick={() => onViewChange && onViewChange('PREINSC')}
              style={{
                fontWeight: currentView === 'PREINSC' ? 700 : 500,
                fontSize: '0.88rem',
                color: currentView === 'PREINSC' ? 'var(--color-verde-uo)' : 'var(--color-gris-carbon)',
                borderBottom: currentView === 'PREINSC' ? '2.5px solid var(--color-verde-uo)' : '2.5px solid transparent',
                padding: '0.4rem 0.2rem',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
              }}
            >
              1. Pre-inscripción (Postulante)
            </button>
            <button
              type="button"
              onClick={() => onViewChange && onViewChange('CALIF')}
              style={{
                fontWeight: currentView === 'CALIF' ? 700 : 500,
                fontSize: '0.88rem',
                color: currentView === 'CALIF' ? 'var(--color-verde-uo)' : 'var(--color-gris-carbon)',
                borderBottom: currentView === 'CALIF' ? '2.5px solid var(--color-verde-uo)' : '2.5px solid transparent',
                padding: '0.4rem 0.2rem',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
              }}
            >
              2. Calificación & SUNEDU (Secretaría)
            </button>
          </nav>

          {/* Botones de Acción */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <BaseButton
              variant="outline"
              size="sm"
              icon={Search}
              onClick={onTrackingClick}
            >
              Consultar Expediente
            </BaseButton>

            {/* Toggle Menú Móvil */}
            <button
              type="button"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="mobile-menu-btn"
              style={{
                display: 'none',
                background: 'transparent',
                border: 'none',
                cursor: 'pointer',
                padding: '0.4rem',
                color: 'var(--color-verde-bosque)',
              }}
              aria-label="Abrir menú"
            >
              {mobileMenuOpen ? <X size={26} /> : <Menu size={26} />}
            </button>
          </div>
        </div>

        {/* Drawer Móvil */}
        {mobileMenuOpen && (
          <div
            style={{
              padding: '1rem 1.5rem',
              background: '#FFFFFF',
              borderTop: '1px solid var(--border-light)',
              display: 'flex',
              flexDirection: 'column',
              gap: '0.85rem',
            }}
          >
            <button
              type="button"
              onClick={() => {
                if (onViewChange) onViewChange('PREINSC');
                setMobileMenuOpen(false);
              }}
              style={{
                textAlign: 'left',
                fontWeight: currentView === 'PREINSC' ? 700 : 500,
                color: currentView === 'PREINSC' ? 'var(--color-verde-uo)' : 'var(--color-gris-carbon)',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                padding: '0.4rem 0',
              }}
            >
              1. Pre-inscripción (Postulante)
            </button>
            <button
              type="button"
              onClick={() => {
                if (onViewChange) onViewChange('CALIF');
                setMobileMenuOpen(false);
              }}
              style={{
                textAlign: 'left',
                fontWeight: currentView === 'CALIF' ? 700 : 500,
                color: currentView === 'CALIF' ? 'var(--color-verde-uo)' : 'var(--color-gris-carbon)',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                padding: '0.4rem 0',
              }}
            >
              2. Calificación & SUNEDU (Secretaría)
            </button>
          </div>
        )}
      </header>

      {/* Contenido Principal */}
      <main style={{ flex: 1, padding: '2rem 0 3rem 0' }}>
        <div className="container">
          {children}
        </div>
      </main>

      {/* Pie de Página Institucional (Negro Puro & Verde Bosque) */}
      <footer
        style={{
          background: 'var(--color-negro-puro)',
          color: '#E5E7EB',
          paddingTop: '3rem',
          paddingBottom: '1.5rem',
          borderTop: '4px solid var(--color-verde-uo)',
        }}
      >
        <div className="container">
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
              gap: '2rem',
              marginBottom: '2.5rem',
            }}
          >
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.85rem' }}>
                <Shield size={22} color="var(--color-amarillo-zapallo)" />
                <span style={{ fontSize: '1.1rem', fontWeight: 700, color: 'var(--color-blanco-puro)' }}>
                  CORLAD JUNÍN
                </span>
              </div>
              <p style={{ fontSize: '0.85rem', color: '#9CA3AF', lineHeight: 1.6 }}>
                Institución deontológica representativa de los Licenciados en Administración de la Región Junín, constituida por Ley para la defensa y ejercicio profesional ético y competente.
              </p>
            </div>

            <div>
              <h4 style={{ fontSize: '0.95rem', fontWeight: 700, color: 'var(--color-blanco-puro)', marginBottom: '0.85rem' }}>
                Módulos del Sistema
              </h4>
              <ul style={{ listStyle: 'none', padding: 0, margin: 0, fontSize: '0.85rem', display: 'flex', flexDirection: 'column', gap: '0.4rem', color: '#9CA3AF' }}>
                <li>Mesa de Partes Digital (CLI)</li>
                <li>Caja y Pagos en Línea (CAJ)</li>
                <li>Verificación de Habilidad con QR (CLI)</li>
                <li>Telemetría de Tiempos con Machine Learning (MLA)</li>
              </ul>
            </div>

            <div>
              <h4 style={{ fontSize: '0.95rem', fontWeight: 700, color: 'var(--color-blanco-puro)', marginBottom: '0.85rem' }}>
                Horario de Atención
              </h4>
              <p style={{ fontSize: '0.85rem', color: '#9CA3AF', margin: 0 }}>
                Lunes a Viernes: 8:30 a.m. - 1:00 p.m. y 2:30 p.m. - 6:00 p.m.<br />
                Sábados: 9:00 a.m. - 1:00 p.m.<br />
                Sede Central: Huancayo, Junín - Perú
              </p>
            </div>
          </div>

          <div
            style={{
              borderTop: '1px solid rgba(255, 255, 255, 0.1)',
              paddingTop: '1.25rem',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              flexWrap: 'wrap',
              gap: '0.75rem',
              fontSize: '0.8rem',
              color: '#6B7280',
            }}
          >
            <span>
              © 2026 CORLAD Junín - Todos los derechos reservados. Sistema Integral N-Tier.
            </span>
            <span style={{ color: 'var(--color-amarillo-zapallo)' }}>
              Resolución y Seguridad Criptográfica SHA-256
            </span>
          </div>
        </div>
      </footer>

      {/* CSS Responsivo para Nav y Mobile */}
      <style>{`
        @media (min-width: 768px) {
          .desktop-nav {
            display: flex !important;
          }
          .mobile-menu-btn {
            display: none !important;
          }
        }
        @media (max-width: 767px) {
          .mobile-menu-btn {
            display: block !important;
          }
        }
      `}</style>
    </div>
  );
};
