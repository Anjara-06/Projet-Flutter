const express = require('express');
const pool = require('../config/db');

const router = express.Router();

// GET /api/administrations — liste de toutes les administrations
router.get('/', async (req, res) => {
  try {
    const resultat = await pool.query(
      'SELECT * FROM administrations ORDER BY nom ASC'
    );
    res.json(resultat.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
});

// GET /api/administrations/:id/services — services d'une administration
router.get('/:id/services', async (req, res) => {
  const { id } = req.params;
  try {
    const resultat = await pool.query(
      'SELECT * FROM services WHERE administration_id = $1 ORDER BY nom ASC',
      [id]
    );
    res.json(resultat.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
});

// GET /api/administrations/services/:serviceId/creneaux — créneaux d'un service
// Paramètre optionnel : ?date=2026-08-20 pour filtrer sur un jour précis
router.get('/services/:serviceId/creneaux', async (req, res) => {
  const { serviceId } = req.params;
  const { date } = req.query;

  try {
    let requete = 'SELECT * FROM creneaux WHERE service_id = $1';
    const parametres = [serviceId];

    if (date) {
      requete += ' AND date = $2';
      parametres.push(date);
    } else {
      requete += ' AND date >= CURRENT_DATE';
    }

    requete += ' ORDER BY date ASC, heure_debut ASC';

    const resultat = await pool.query(requete, parametres);
    res.json(resultat.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
});

module.exports = router;
