import axios from 'axios';

const API_BASE = '/api';

export const adminApi = {
  // Get dashboard metrics
  async getMetrics(): Promise<any> {
    const response = await axios.get(`${API_BASE}/admin/metrics`);
    return response.data;
  },

  // Resolve user error remotely
  async resolveUser(userId: string, action: string): Promise<void> {
    await axios.post(
      `${API_BASE}/admin/users/resolve`,
      { userId, resolution_action: action }
    );
  },

  // Get cohort status
  async getCohortStatus(): Promise<any> {
    const response = await axios.get(`${API_BASE}/admin/cohorts/status`);
    return response.data;
  },

  // Get specific user metrics
  async getUserMetrics(userId: string): Promise<any> {
    const response = await axios.get(
      `${API_BASE}/admin/cohorts/metrics`,
      { params: { user_id: userId } }
    );
    return response.data;
  },

  // Get telemetry logs
  async getTelemetryLogs(userId?: string, limit?: number): Promise<any> {
    const url = new URL(`${API_BASE}/wearable/log`);
    if (userId) url.searchParams.append('user_id', userId);
    if (limit) url.searchParams.append('limit', limit.toString());
    
    const response = await axios.get(url.toString());
    return response.data;
  }
};
