import React from 'react';
import { BaseCard } from './BaseCard';
import { TrendingUp, TrendingDown } from 'lucide-react';

export const BaseMetricCard = ({
  title,
  value,
  subtitle,
  trend,
  trendDirection = 'up',
  icon: Icon,
  color = 'var(--color-verde-uo)',
  style = {},
}) => {
  return (
    <BaseCard style={{ ...style }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
        <div>
          <span style={{ fontSize: '0.8125rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            {title}
          </span>
          <div style={{ fontSize: '1.875rem', fontWeight: 800, color: 'var(--color-negro-puro)', margin: '0.25rem 0', fontFamily: 'var(--font-heading)' }}>
            {value}
          </div>
          {subtitle && (
            <p style={{ margin: 0, fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
              {subtitle}
            </p>
          )}
        </div>

        {Icon && (
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: 'var(--radius-md)',
              background: `rgba(0, 112, 48, 0.08)`,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: color,
            }}
          >
            <Icon size={24} />
          </div>
        )}
      </div>

      {trend && (
        <div style={{ marginTop: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.35rem', fontSize: '0.8125rem' }}>
          {trendDirection === 'up' ? (
            <TrendingUp size={16} color="var(--color-verde-uo)" />
          ) : (
            <TrendingDown size={16} color="var(--color-peligro)" />
          )}
          <span style={{ fontWeight: 600, color: trendDirection === 'up' ? 'var(--color-verde-uo)' : 'var(--color-peligro)' }}>
            {trend}
          </span>
          <span style={{ color: 'var(--text-muted)' }}>vs. mes anterior</span>
        </div>
      )}
    </BaseCard>
  );
};
