import React, { useState } from 'react';
import ReactDOM from 'react-dom/client';
import CohortHeatmapGrid from './components/CohortHeatmapGrid';
import ResolutionActions from './components/ResolutionActions';
import { adminApi } from './services/adminApi';
import { royalPurpleTheme } from './styles/royalPurpleTheme';

const App: React.FC = () => {
  const [selectedCohort, setSelectedCohort] = useState<string>('C01');
  const [users, setUsers] = useState<Array<{ id: string; name: string; status: string }>>([]);
  const [userDetails, setUserDetails] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  // Cohort selection panel
  const cohorts = [
    { id: 'C01', name: '실버 어르신군' },
    { id: 'C02', name: 'ADHD 아동' },
    { id: 'C03', name: '지하철 직장인' },
    { id: 'C04', name: 'CarPlay 운전자' },
    { id: 'C05', name: '소음 근로자' }
  ];

  const handleCohortSelect = async (cohortId: string) => {
    setLoading(true);
    try {
      const statusData = await adminApi.getCohortStatus();
      const cohort = statusData.cohorts.find(c => c.cluster_id === cohortId);
      
      if (cohort) {
        // Generate mock users for heatmap
        const newUsers: Array<{ id: string; name: string; status: string }> = [];
        for (let i = 0; i < cohort.total_count; i++) {
          const randomStatus = Math.random();
          let status: string;
          
          if (randomStatus < 0.85) status = 'normal';
          else if (randomStatus < 0.95) status = 'warning';
          else status = 'critical';
          
          newUsers.push({
            id: `u_${cohortId}_${i.toString().padStart(3, '0')}`,
            name: `User ${i + 1}`,
            status
          });
        }
        
        setUsers(newUsers);
        setUserDetails(null);
      }
    } catch (error) {
      console.error('Failed to load cohort:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleUserClick = async (userId: string) => {
    try {
      const metrics = await adminApi.getUserMetrics(userId);
      setUserDetails(metrics);
    } catch (error) {
      console.error('Failed to load user details:', error);
    }
  };

  const handleResolve = async (action: string) => {
    if (!userDetails?.user_id) return;
    
    try {
      await adminApi.resolveUser(userDetails.user_id, action);
      alert(`Remote resolution [${action}] executed successfully!`);
    } catch (error) {
      console.error('Resolution failed:', error);
      alert('Resolution failed. Please try again.');
    }
  };

  return (
    <div style={{ 
      backgroundColor: royalPurpleTheme.colors.background,
      color: royalPurpleTheme.colors.fontColor,
      fontFamily: royalPurpleTheme.fontFamily,
      minHeight: '100vh',
      padding: royalPurpleTheme.spacing.lg
    }}>
      <header style={{ marginBottom: royalPurpleTheme.spacing.xl }}>
        <h1 style={{ fontSize: '2rem', margin: 0 }}>🛡️ Naya Admin Dashboard</h1>
        <p style={{ color: royalPurpleTheme.colors.textMuted, marginTop: royalPurpleTheme.spacing.sm }}>
          Royal Purple Theme • Real-time Cohort Monitoring & Remote Resolution
        </p>
      </header>

      {/* Cohort Selection Panel */}
      <div style={{ 
        display: 'flex', 
        gap: royalPurpleTheme.spacing.md, 
        marginBottom: royalPurpleTheme.spacing.lg,
        flexWrap: 'wrap'
      }}>
        {cohorts.map(cohort => (
          <button
            key={cohort.id}
            onClick={() => handleCohortSelect(cohort.id)}
            style={{
              padding: `${royalPurpleTheme.spacing.md} ${royalPurpleTheme.spacing.lg}`,
              backgroundColor: selectedCohort === cohort.id 
                ? royalPurpleTheme.colors.primaryAccent 
                : royalPurpleTheme.colors.card,
              color: royalPurpleTheme.colors.fontColor,
              border: `1px solid ${selectedCohort === cohort.id ? royalPurpleTheme.colors.primaryAccent : 'transparent'}`,
              borderRadius: royalPurpleTheme.borderRadius.md,
              cursor: loading ? 'not-allowed' : 'pointer',
              opacity: loading ? 0.6 : 1
            }}
          >
            {cohort.name}
          </button>
        ))}
      </div>

      {/* Main Content Grid */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', 
        gap: royalPurpleTheme.spacing.lg
      }}>
        {/* Heatmap Map Panel */}
        <div style={{ 
          backgroundColor: royalPurpleTheme.colors.card,
          borderRadius: royalPurpleTheme.borderRadius.lg,
          padding: royalPurpleTheme.spacing.lg
        }}>
          <h2 style={{ marginBottom: royalPurpleTheme.spacing.md }}>🔥 Cohort Heatmap</h2>
          
          {loading ? (
            <p>Loading...</p>
          ) : users.length === 0 ? (
            <p>Select a cohort to view heatmap</p>
          ) : (
            <CohortHeatmapGrid users={users} />
          )}
        </div>

        {/* Detailed Diagnostics Panel */}
        <div style={{ 
          backgroundColor: royalPurpleTheme.colors.card,
          borderRadius: royalPurpleTheme.borderRadius.lg,
          padding: royalPurpleTheme.spacing.lg
        }}>
          <h2 style={{ marginBottom: royalPurpleTheme.spacing.md }}>📊 Detailed Diagnostics</h2>
          
          {userDetails ? (
            <>
              <div style={{ marginBottom: royalPurpleTheme.spacing.lg }}>
                <h3 style={{ fontSize: '1.25rem', marginBottom: royalPurpleTheme.spacing.sm }}>
                  User: {userDetails.user_id}
                </h3>
                
                {/* Biometric Telemetry */}
                <div style={{ 
                  backgroundColor: royalPurpleTheme.colors.background,
                  padding: royalPurpleTheme.spacing.md,
                  borderRadius: royalPurpleTheme.borderRadius.md,
                  marginBottom: royalPurpleTheme.spacing.sm
                }}>
                  <h4 style={{ margin: '0 0 royalPurpleTheme.spacing.xs 0' }}>📊 Biometric Telemetry</h4>
                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: royalPurpleTheme.spacing.sm }}>
                    <div>
                      <span style={{ color: royalPurpleTheme.colors.textMuted }}>BPM:</span>{' '}
                      {userDetails.biometric_telemetry?.current_bpm || '-'}
                    </div>
                    <div>
                      <span style={{ color: royalPurpleTheme.colors.textMuted }}>Stress (RMSSD):</span>{' '}
                      {userDetails.biometric_telemetry?.stress_index_rmssd || '-'}
                    </div>
                    <div>
                      <span style={{ color: royalPurpleTheme.colors.textMuted }}>Last Activity:</span>{' '}
                      {userDetails.biometric_telemetry?.last_activity || '-'}
                    </div>
                  </div>
                </div>

                {/* Content Metrics */}
                <div style={{ 
                  backgroundColor: royalPurpleTheme.colors.background,
                  padding: royalPurpleTheme.spacing.md,
                  borderRadius: royalPurpleTheme.borderRadius.md,
                  marginBottom: royalPurpleTheme.spacing.sm
                }}>
                  <h4 style={{ margin: '0 0 royalPurpleTheme.spacing.xs 0' }}>📚 Content Metrics</h4>
                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: royalPurpleTheme.spacing.sm }}>
                    <div>
                      <span style={{ color: royalPurpleTheme.colors.textMuted }}>Subject:</span>{' '}
                      {userDetails.content_metrics?.active_subject || '-'}
                    </div>
                    <div>
                      <span style={{ color: royalPurpleTheme.colors.textMuted }}>Retention Score:</span>{' '}
                      {userDetails.content_metrics?.retention_score || '-'}%
                    </div>
                    <div>
                      <span style={{ color: royalPurpleTheme.colors.textMuted }}>Focus Score:</span>{' '}
                      {userDetails.content_metrics?.focus_score || '-'}%
                    </div>
                    <div>
                      <span style={{ color: royalPurpleTheme.colors.textMuted }}>Fatigue Index:</span>{' '}
                      {userDetails.content_metrics?.fatigue_index || '-'}%
                    </div>
                  </div>
                </div>

                {/* Anomaly Logs */}
                {userDetails.anomaly_logs && userDetails.anomaly_logs.length > 0 && (
                  <div style={{ 
                    backgroundColor: royalPurpleTheme.colors.background,
                    padding: royalPurpleTheme.spacing.md,
                    borderRadius: royalPurpleTheme.borderRadius.md
                  }}>
                    <h4 style={{ margin: '0 0 royalPurpleTheme.spacing.xs 0' }}>⚠️ Recent Anomalies</h4>
                    {userDetails.anomaly_logs.map((log: any) => (
                      <div key={log.log_id} style={{ 
                        padding: royalPurpleTheme.spacing.sm,
                        marginBottom: royalPurpleTheme.spacing.xs,
                        backgroundColor: log.status === 'ACTIVE' ? royalPurpleTheme.colors.criticalAlert : royalPurpleTheme.colors.emerald,
                        borderRadius: royalPurpleTheme.borderRadius.sm
                      }}>
                        <div style={{ fontWeight: 'bold' }}>{log.error_code}</div>
                        <div style={{ fontSize: '0.875rem', color: royalPurpleTheme.colors.textMuted }}>
                          {log.error_message}
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                {/* Resolution Actions */}
                <ResolutionActions
                  userId={userDetails.user_id}
                  actions={[
                    { code: 'TOKEN_FLUSH', label: 'Token Flush', description: 'Invalidatize JWT token & re-authenticate' },
                    { code: 'LOW_POWER_SWITCH', label: 'Low-Power Switch', description: 'Force low-power mode recovery' },
                    { code: 'VOICE_REGENERATE', label: 'Voice Re-generate', description: 'Re-sync voice weights from ElevenLabs' },
                    { code: 'THRESHOLD_TUNER', label: 'Threshold Tuner', description: 'Adjust similarity threshold (0.85 → 0.70)' },
                    { code: 'VOICE_BYPASS', label: 'Voice Bypass', description: 'Switch to pro voice actor library' }
                  ]}
                  onResolve={handleResolve}
                />
              </div>
            </>
          ) : (
            <p style={{ color: royalPurpleTheme.colors.textMuted }}>
              Click on a heatmap dot to view user details and resolution options
            </p>
          )}
        </div>
      </div>

      {/* Footer */}
      <footer style={{ 
        marginTop: royalPurpleTheme.spacing.xl, 
        paddingTop: royalPurpleTheme.spacing.lg,
        borderTop: `1px solid ${royalPurpleTheme.colors.textMuted}`,
        textAlign: 'center',
        color: royalPurpleTheme.colors.textMuted
      }}>
        <p>Naya Admin Dashboard • Royal Purple Theme</p>
      </footer>
    </div>
  );
};

export default App;
