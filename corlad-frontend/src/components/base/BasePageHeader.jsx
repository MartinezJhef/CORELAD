import React from 'react';
import { ChevronRight } from 'lucide-react';

export const BasePageHeader = ({
  title,
  subtitle,
  breadcrumbs = [],
  moduleBadge = '',
  actions,
}) => {
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: '0.75rem',
        marginBottom: '1.75rem',
      }}
    >
      {/* Breadcrumbs */}
      {breadcrumbs && breadcrumbs.length > 0 && (
        <nav aria-label="Breadcrumb" style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.8125rem' }}>
          {breadcrumbs.map((bc, idx) => (
            <React.Fragment key={idx}>
              {idx > 0 && <ChevronRight size={14} color="var(--text-muted)" />}
              {bc.href ? (
                <a href={bc.href} style={{ color: 'var(--color-verde-uo)', fontWeight: 500 }}>
                  {bc.label}
                </a>
              ) : (
                <span style={{ color: 'var(--text-muted)', fontWeight: 500 }}>
                  {bc.label}
                </span>
              )}
            </React.Fragment>
          ))}
        </nav>
      )}

      {/* Título y Acciones */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'flex-start',
          gap: '1rem',
          flexWrap: 'wrap',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 800, color: 'var(--color-negro-puro)' }}>
              {title}
            </h1>
            {moduleBadge && (
              <span
                style={{
                  background: 'rgba(0, 112, 48, 0.1)',
                  color: 'var(--color-verde-uo)',
                  fontSize: '0.75rem',
                  fontWeight: 700,
                  padding: '0.2rem 0.6rem',
                  borderRadius: 'var(--radius-sm)',
                  letterSpacing: '0.05em',
                }}
              >
                {moduleBadge}
              </span>
            )}
          </div>
          {subtitle && (
            <p style={{ margin: '0.35rem 0 0 0', fontSize: '0.9375rem', color: 'var(--color-gris-carbon)' }}>
              {subtitle}
            </p>
          )}
        </div>

        {actions && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            {actions}
          </div>
        )}
      </div>
    </div>
  );
};
