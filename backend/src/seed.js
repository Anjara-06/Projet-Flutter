const pool = require('./config/db');

async function peupler() {
  console.log('Insertion des données de test...');

  const administrations = [
    ["Mairie d'Analakely", 'Analakely', 'Antananarivo', '08h00 - 16h00', 'building-bank'],
    ['Fokontany Isotry', 'Isotry', 'Antananarivo', '08h00 - 15h30', 'file-certificate'],
    ['Mairie Antsirabe I', 'Centre-ville', 'Antsirabe', '08h00 - 16h00', 'building-bank'],
  ];

  const administrationIds = [];
  for (const admin of administrations) {
    const resultat = await pool.query(
      `INSERT INTO administrations (nom, adresse, ville, horaires, icone)
       VALUES ($1, $2, $3, $4, $5) RETURNING id`,
      admin
    );
    administrationIds.push(resultat.rows[0].id);
  }

  const services = [
    [administrationIds[0], 'Certificat de résidence', 'Justificatif de domicile officiel', 20],
    [administrationIds[0], 'Acte de naissance', "Copie ou extrait d'acte de naissance", 30],
    [administrationIds[0], 'Légalisation de document', "Authentification d'une signature ou copie", 15],
    [administrationIds[1], 'Attestation de résidence Fokontany', 'Document délivré par le chef Fokontany', 20],
    [administrationIds[1], 'Déclaration de recensement', 'Mise à jour du registre des habitants', 25],
    [administrationIds[2], 'Certificat de résidence', 'Justificatif de domicile officiel', 20],
  ];

  const serviceIds = [];
  for (const service of services) {
    const resultat = await pool.query(
      `INSERT INTO services (administration_id, nom, description, duree_minutes)
       VALUES ($1, $2, $3, $4) RETURNING id`,
      service
    );
    serviceIds.push(resultat.rows[0].id);
  }

  // Génère des créneaux pour les 6 prochains jours, 8h-16h, par tranches de 45 min
  let totalCreneaux = 0;
  for (const serviceId of serviceIds) {
    for (let jourOffset = 0; jourOffset < 6; jourOffset++) {
      const date = new Date();
      date.setDate(date.getDate() + jourOffset);
      const dateStr = date.toISOString().split('T')[0];

      let heure = 8;
      let minute = 0;
      let compteur = 0;

      while (heure < 16) {
        const heureDebut = `${String(heure).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
        let finHeure = heure;
        let finMinute = minute + 45;
        if (finMinute >= 60) {
          finMinute -= 60;
          finHeure += 1;
        }
        const heureFin = `${String(finHeure).padStart(2, '0')}:${String(finMinute).padStart(2, '0')}`;
        const disponible = compteur % 3 !== 0;

        await pool.query(
          `INSERT INTO creneaux (service_id, date, heure_debut, heure_fin, disponible)
           VALUES ($1, $2, $3, $4, $5)`,
          [serviceId, dateStr, heureDebut, heureFin, disponible]
        );

        totalCreneaux++;
        compteur++;
        minute += 45;
        if (minute >= 60) {
          minute -= 60;
          heure += 1;
        }
      }
    }
  }

  console.log(`${administrationIds.length} administrations, ${serviceIds.length} services, ${totalCreneaux} créneaux insérés.`);
  await pool.end();
}

peupler().catch((err) => {
  console.error('Erreur lors du peuplement :', err);
  process.exit(1);
});
