import React from 'react';
import { royalPurpleTheme } from '../styles/royalPurpleTheme';

interface ResolutionActionProps {
  userId: string;
  actions: Array<{
    code: string;
    label: string;
    description: string;
  }>;
  onResolve: (action: string) => Promise<void>;
}

export const ResolutionActions: React.FC<ResolutionActionProps> = ({
  userId,
  actions,
  onResolve
}) => {
  return (
    <div className="resolution-actions">
      <h3>원격 해결 조치</h3>
      
      <div className="actions-grid">
        {actions.map((action) => (
          <button
            key={action.code}
            onClick={() => onResolve(action.code)}
            disabled={false}
            style={{
              backgroundColor: royalPurpleTheme.colors.card,
              color: royalPurpleTheme.colors.fontColor,
              border: `1px solid ${royalPurpleTheme.colors.primaryAccent}`,
              padding: '0.75rem 1rem',
              borderRadius: royalPurpleTheme.borderRadius.md,
              cursor: 'pointer'
            }}
          >
            <span className="action-icon">⚡</span>
            <div className="action-label">{action.label}</div>
            <div className="action-desc" style={{ fontSize: '0.75rem', color: royalPurpleTheme.colors.textMuted }}>
              {action.description}
            </div>
          </button>
        ))}
      </div>
    </div>
  );
};
