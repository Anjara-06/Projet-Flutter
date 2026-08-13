const { Pool } = require('pg');
require('dotenv').config();

// Pool de connexions réutilisables vers PostgreSQL.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

pool.on('error', (err) => {
  console.error('Erreur inattendue sur le pool PostgreSQL :', err);
});

module.exports = pool;
