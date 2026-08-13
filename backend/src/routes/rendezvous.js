const express = require('express');
const pool = require('../config/db');
const { authentifier } = require('../middleware/auth');

const router = express.Router();

function genererNumeroRdv() {
  const lettre = String.fromCharCode(65 + Math.floor(Math.random() * 4)); // A-D
  const chiffre = 10 + Math.floor(Math.random() * 89);
  return `${lettre}-${String(chiffre).padStart(3, '0')}`;
}

function genererCodeQr(numeroRdv) {
  return `RDV-${numeroRdv}-${Date.now()}`;
}

// Toutes les routes de rendez-vous nécessitent d'être connecté
router.use(authentifier);

// POST /api/rendezvous — Prendre un rendez-vous sur un créneau donné
router.post('/', async (req, res) => {
  const { creneau_id } = req.body;
  if (!creneau_id) {
    return res.status(400).json({ erreur: 'creneau_id requis' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // On verrouille la ligne pour éviter que 2 personnes réservent
    // le même créneau en même temps.
    const creneauResultat = await client.query(
      'SELECT * FROM creneaux WHERE id = $1 FOR UPDATE',
      [creneau_id]
    );

    if (creneauResultat.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ erreur: 'Créneau introuvable' });
    }

    const creneau = creneauResultat.rows[0];
    if (!creneau.disponible) {
      await client.query('ROLLBACK');
      return res.status(409).json({ erreur: 'Ce créneau n\'est plus disponible' });
    }

    const numeroRdv = genererNumeroRdv();
    const codeQr = genererCodeQr(numeroRdv);

    const rdvResultat = await client.query(
      `INSERT INTO rendezvous (utilisateur_id, creneau_id, numero_rdv, code_qr)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [req.utilisateurId, creneau_id, numeroRdv, codeQr]
    );

    await client.query(
      'UPDATE creneaux SET disponible = FALSE WHERE id = $1',
      [creneau_id]
    );

    await client.query('COMMIT');
    res.status(201).json(rdvResultat.rows[0]);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur lors de la réservation' });
  } finally {
    client.release();
  }
});

// GET /api/rendezvous — Mes rendez-vous (avec détails service + administration)
router.get('/', async (req, res) => {
  try {
    const resultat = await pool.query(
      `SELECT
         rv.id, rv.numero_rdv, rv.code_qr, rv.statut, rv.date_creation,
         c.date, c.heure_debut, c.heure_fin,
         s.nom AS service_nom,
         a.nom AS administration_nom, a.ville AS administration_ville
       FROM rendezvous rv
       JOIN creneaux c ON c.id = rv.creneau_id
       JOIN services s ON s.id = c.service_id
       JOIN administrations a ON a.id = s.administration_id
       WHERE rv.utilisateur_id = $1
       ORDER BY c.date DESC, c.heure_debut DESC`,
      [req.utilisateurId]
    );
    res.json(resultat.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
});

// PATCH /api/rendezvous/:id/annuler — Annuler un rendez-vous
router.patch('/:id/annuler', async (req, res) => {
  const { id } = req.params;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const rdvResultat = await client.query(
      'SELECT * FROM rendezvous WHERE id = $1 AND utilisateur_id = $2',
      [id, req.utilisateurId]
    );

    if (rdvResultat.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ erreur: 'Rendez-vous introuvable' });
    }

    const rdv = rdvResultat.rows[0];

    await client.query(
      "UPDATE rendezvous SET statut = 'annule' WHERE id = $1",
      [id]
    );
    await client.query(
      'UPDATE creneaux SET disponible = TRUE WHERE id = $1',
      [rdv.creneau_id]
    );

    await client.query('COMMIT');
    res.json({ message: 'Rendez-vous annulé' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ erreur: 'Erreur serveur lors de l\'annulation' });
  } finally {
    client.release();
  }
});

module.exports = router;
