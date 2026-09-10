import React, { useState, useMemo } from 'react';
import { Search, ChevronLeft, ChevronRight, Inbox } from 'lucide-react';
import { BaseInput } from './BaseInput';
import { BaseButton } from './BaseButton';

export const BaseDataTable = ({
  columns = [],
  data = [],
  loading = false,
  searchPlaceholder = 'Buscar en la tabla...',
  showSearch = true,
  itemsPerPage = 10,
  emptyMessage = 'No se encontraron registros',
  onRowClick,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);

  const filteredData = useMemo(() => {
    if (!searchTerm.trim()) return data;
    const term = searchTerm.toLowerCase();
    return data.filter((item) =>
      columns.some((col) => {
        const key = col.accessor || col.key;
        const val = key ? item[key] : '';
        return String(val).toLowerCase().includes(term);
      })
    );
  }, [data, searchTerm, columns]);

  const totalPages = Math.ceil(filteredData.length / itemsPerPage) || 1;
  const paginatedData = useMemo(() => {
    const start = (currentPage - 1) * itemsPerPage;
    return filteredData.slice(start, start + itemsPerPage);
  }, [filteredData, currentPage, itemsPerPage]);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', width: '100%' }}>
      {showSearch && (
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '1rem', flexWrap: 'wrap' }}>
          <div style={{ maxWidth: '360px', width: '100%' }}>
            <BaseInput
              icon={Search}
              placeholder={searchPlaceholder}
              value={searchTerm}
              onChange={(e) => {
                setSearchTerm(e.target.value);
                setCurrentPage(1);
              }}
            />
          </div>
          <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
            Mostrando {filteredData.length} registros
          </span>
        </div>
      )}

      {/* Contenedor de Tabla con Scroll Suave */}
      <div
        style={{
          background: 'var(--color-blanco-puro)',
          borderRadius: 'var(--radius-md)',
          border: '1px solid var(--border-light)',
          overflowX: 'auto',
          boxShadow: 'var(--shadow-sm)',
        }}
      >
        <table
          style={{
            width: '100%',
            borderCollapse: 'collapse',
            textAlign: 'left',
            fontSize: '0.875rem',
          }}
        >
          <thead>
            <tr style={{ background: 'rgba(0, 112, 48, 0.05)', borderBottom: '1.5px solid var(--border-light)' }}>
              {columns.map((col, idx) => (
                <th
                  key={idx}
                  style={{
                    padding: '0.85rem 1.25rem',
                    fontWeight: 700,
                    color: 'var(--color-verde-bosque)',
                    textTransform: 'uppercase',
                    fontSize: '0.75rem',
                    letterSpacing: '0.05em',
                  }}
                >
                  {col.header || col.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {loading ? (
              Array.from({ length: 5 }).map((_, rIdx) => (
                <tr key={rIdx} style={{ borderBottom: '1px solid rgba(0,0,0,0.05)' }}>
                  {columns.map((_, cIdx) => (
                    <td key={cIdx} style={{ padding: '1rem 1.25rem' }}>
                      <div
                        style={{
                          height: '16px',
                          background: 'linear-gradient(90deg, #F3F4F6 25%, #E5E7EB 50%, #F3F4F6 75%)',
                          backgroundSize: '200% 100%',
                          animation: 'shimmer 1.5s infinite',
                          borderRadius: 'var(--radius-sm)',
                          width: '80%',
                        }}
                      />
                    </td>
                  ))}
                </tr>
              ))
            ) : paginatedData.length === 0 ? (
              <tr>
                <td colSpan={columns.length} style={{ padding: '3rem 1rem', textAlign: 'center' }}>
                  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0.75rem' }}>
                    <div
                      style={{
                        width: '48px',
                        height: '48px',
                        borderRadius: '50%',
                        background: 'rgba(0, 112, 48, 0.06)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: 'var(--text-muted)',
                      }}
                    >
                      <Inbox size={24} />
                    </div>
                    <span style={{ fontSize: '0.9375rem', color: 'var(--text-muted)', fontWeight: 500 }}>
                      {emptyMessage}
                    </span>
                  </div>
                </td>
              </tr>
            ) : (
              paginatedData.map((row, rIdx) => (
                <tr
                  key={row.id ?? rIdx}
                  onClick={() => onRowClick && onRowClick(row)}
                  style={{
                    borderBottom: '1px solid rgba(0,0,0,0.04)',
                    cursor: onRowClick ? 'pointer' : 'default',
                    transition: 'background var(--transition-fast)',
                  }}
                  onMouseEnter={(e) => {
                    if (onRowClick) e.currentTarget.style.background = 'rgba(0, 112, 48, 0.03)';
                  }}
                  onMouseLeave={(e) => {
                    if (onRowClick) e.currentTarget.style.background = 'transparent';
                  }}
                >
                  {columns.map((col, cIdx) => {
                    const key = col.accessor || col.key;
                    return (
                      <td key={cIdx} style={{ padding: '0.9rem 1.25rem', color: 'var(--color-gris-carbon)' }}>
                        {col.render ? col.render(row) : (row[key] ?? '-')}
                      </td>
                    );
                  })}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Paginador */}
      {totalPages > 1 && (
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '0.5rem' }}>
          <span style={{ fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
            Página {currentPage} de {totalPages}
          </span>
          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <BaseButton
              variant="outline"
              size="sm"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              icon={ChevronLeft}
            >
              Anterior
            </BaseButton>
            <BaseButton
              variant="outline"
              size="sm"
              disabled={currentPage === totalPages}
              onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
              icon={ChevronRight}
              iconPosition="right"
            >
              Siguiente
            </BaseButton>
          </div>
        </div>
      )}

      <style>{`
        @keyframes shimmer {
          0% { background-position: -200% 0; }
          100% { background-position: 200% 0; }
        }
      `}</style>
    </div>
  );
};
