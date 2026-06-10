import { useState } from 'react';
import axios from 'axios';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');

  const fetchUsers = async () => {
    try {
      const response = await axios.get('https://api.naya.app/api/v1/users');
      setUsers(response.data);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const filteredUsers = users.filter(user => 
    user.username.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="users-page">
      <header className="header">
        <h1>User Management</h1>
      </header>

      <main style={{ padding: '2rem' }}>
        <input
          type="text"
          placeholder="Search users..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          style={{
            width: '100%',
            padding: '0.8rem',
            borderRadius: '8px',
            border: 'none',
            marginBottom: '1rem',
          }}
        />

        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ textAlign: 'left' }}>
              <th>ID</th>
              <th>Username</th>
              <th>Voice Preference</th>
              <th>Last Active</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.map((user) => (
              <tr key={user.id} style={{ borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
                <td>{user.id}</td>
                <td>{user.username}</td>
                <td>{user.voice_preference}</td>
                <td>{new Date(user.last_active).toLocaleDateString()}</td>
              </tr>
            ))}
          </tbody>
        </table>

        <button className="btn-primary" onClick={fetchUsers}>
          Refresh Users
        </button>
      </main>
    </div>
  );
};

export default Users;
