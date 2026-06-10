import { useState } from 'react';
import axios from 'axios';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeDevices: 0,
    todayQuizzes: 0,
  });

  const fetchDashboardData = async () => {
    try {
      const response = await axios.get('https://api.naya.app/api/v1/stats');
      setStats(response.data);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    }
  };

  return (
    <div className="dashboard">
      <header className="header">
        <h1>Naya Admin Dashboard</h1>
        <p>Welcome to the admin panel</p>
      </header>

      <main style={{ padding: '2rem' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1.5rem' }}>
          <div className="card" style={{ padding: '1.5rem' }}>
            <h3>Total Users</h3>
            <p style={{ fontSize: '2rem', fontWeight: 'bold' }}>{stats.totalUsers}</p>
          </div>

          <div className="card" style={{ padding: '1.5rem' }}>
            <h3>Active Devices</h3>
            <p style={{ fontSize: '2rem', fontWeight: 'bold' }}>{stats.activeDevices}</p>
          </div>

          <div className="card" style={{ padding: '1.5rem' }}>
            <h3>Today's Quizzes</h3>
            <p style={{ fontSize: '2rem', fontWeight: 'bold' }}>{stats.todayQuizzes}</p>
          </div>
        </div>

        <button className="btn-primary" onClick={fetchDashboardData}>
          Refresh Data
        </button>
      </main>
    </div>
  );
};

export default Dashboard;
