require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const administrationsRoutes = require('./routes/administrations');
const rendezvousRoutes = require('./routes/rendezvous');

const app = express();

app.use(cors());
app.use(express.json());

// Route de vérification rapide
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRoutes);
app.use('/api/administrations', administrationsRoutes);
app.use('/api/rendezvous', rendezvousRoutes);

// Gestion des routes inconnues
app.use((req, res) => {
  res.status(404).json({ erreur: 'Route introuvable' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Serveur backend démarré sur http://localhost:${PORT}`);
});
