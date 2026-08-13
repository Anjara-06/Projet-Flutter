const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

const router = express.Router();

// POST /api/auth/register — Inscription
router.post('/register', async (req, res) => {
  const { nom, prenom, email, mot_de_passe, telephone } = req.body;

  if (!nom || !prenom || !email || !mot_de_passe) {
    return res.status(400).json({ erreur: 'Champs requis manquants' });
  }

  try {
    const existant = await pool.query(
      'SELECT id FROM utilisateurs WHERE email = $1',
      [email]
    );
    if (existant.rows.length > 0) {
      return res.status(409).json({ erreur: 'Cet email est déjà utilisé' });
    }

    const hash = await bcrypt.hash(mot_de_passe, 10);

    const resultat = await pool.query(
      `INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, telephone)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, nom, prenom, email, telephone`,
      [nom, prenom, email, hash, telephone || null]
    );

    const utilisateur = resultat.rows[0];
    const token = jwt.sign(
      { utilisateurId: utilisateur.id },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(201).json({ utilisateur, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur lors de l\'inscription' });
  }
});

// POST /api/auth/login — Connexion
router.post('/login', async (req, res) => {
  const { email, mot_de_passe } = req.body;

  if (!email || !mot_de_passe) {
    return res.status(400).json({ erreur: 'Email et mot de passe requis' });
  }

  try {
    const resultat = await pool.query(
      'SELECT * FROM utilisateurs WHERE email = $1',
      [email]
    );

    if (resultat.rows.length === 0) {
      return res.status(401).json({ erreur: 'Identifiants incorrects' });
    }

    const utilisateur = resultat.rows[0];
    const motDePasseValide = await bcrypt.compare(
      mot_de_passe,
      utilisateur.mot_de_passe
    );

    if (!motDePasseValide) {
      return res.status(401).json({ erreur: 'Identifiants incorrects' });
    }

    const token = jwt.sign(
      { utilisateurId: utilisateur.id },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      utilisateur: {
        id: utilisateur.id,
        nom: utilisateur.nom,
        prenom: utilisateur.prenom,
        email: utilisateur.email,
        telephone: utilisateur.telephone,
      },
      token,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur lors de la connexion' });
  }
});

module.exports = router;
