import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const Analytics = () => {
  const data = [
    { name: 'Mon', quizzes: 45, retention: 78 },
    { name: 'Tue', quizzes: 52, retention: 82 },
    { name: 'Wed', quizzes: 38, retention: 75 },
    { name: 'Thu', quizzes: 61, retention: 85 },
    { name: 'Fri', quizzes: 49, retention: 80 },
    { name: 'Sat', quizzes: 35, retention: 72 },
    { name: 'Sun', quizzes: 42, retention: 76 },
  ];

  return (
    <div className="analytics-page">
      <header className="header">
        <h1>Analytics Dashboard</h1>
      </header>

      <main style={{ padding: '2rem' }}>
        <div className="chart-container" style={{ height: '300px', marginBottom: '2rem' }}>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'rgba(26, 15, 51, 0.9)',
                  border: 'none',
                  color: '#fff'
                }} 
              />
              <Line type="monotone" dataKey="quizzes" stroke="#8B5CF6" />
              <Line type="monotone" dataKey="retention" stroke="#EC4899" />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <h2 style={{ marginBottom: '1rem' }}>Weekly Performance</h2>
        
        <div className="card" style={{ padding: '1.5rem', marginBottom: '1rem' }}>
          <h3>Average Quiz Completion Rate</h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: '#8B5CF6' }}>78%</p>
        </div>

        <div className="card" style={{ padding: '1.5rem' }}>
          <h3>User Retention Rate</h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: '#EC4899' }}>76%</p>
        </div>
      </main>
    </div>
  );
};

export default Analytics;
