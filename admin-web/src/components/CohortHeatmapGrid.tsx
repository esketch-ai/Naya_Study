import React from 'react';
import { royalPurpleTheme } from '../styles/royalPurpleTheme';

interface UserStatus {
  id: string;
  name: string;
  status: 'normal' | 'warning' | 'critical';
  error?: {
    code: string;
    message: string;
  };
}

export const CohortHeatmapGrid: React.FC<{ users: UserStatus[] }> = ({ users }) => {
  return (
    <div className="heatmap-grid">
      <div className="legend">
        <span style={{ color: royalPurpleTheme.colors.emerald }}>🟢 Normal</span>
        <span style={{ color: royalPurpleTheme.colors.amber }}>🟡 Warning</span>
        <span style={{ color: royalPurpleTheme.colors.crimson }}>🔴 Critical</span>
      </div>
      
      <div className="grid-container">
        {users.map((user) => (
          <div
            key={user.id}
            className={`heatmap-dot ${user.status}`}
            style={{ 
              backgroundColor: user.status === 'normal' ? royalPurpleTheme.colors.emerald :
                              user.status === 'warning' ? royalPurpleTheme.colors.amber :
                              royalPurpleTheme.colors.crimson
            }}
            title={`${user.name}: ${user.error?.message || 'No error'}`}
          />
        ))}
      </div>
    </div>
  );
};
