-- Schéma de la base de données — App de prise de rendez-vous administratif

DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS rendezvous CASCADE;
DROP TABLE IF EXISTS creneaux CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS administrations CASCADE;
DROP TABLE IF EXISTS utilisateurs CASCADE;

CREATE TABLE utilisateurs (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  mot_de_passe VARCHAR(255) NOT NULL,
  telephone VARCHAR(30),
  date_creation TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE administrations (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(150) NOT NULL,
  adresse VARCHAR(255) NOT NULL,
  ville VARCHAR(100) NOT NULL,
  horaires VARCHAR(150) NOT NULL,
  icone VARCHAR(50) NOT NULL DEFAULT 'building-bank'
);

CREATE TABLE services (
  id SERIAL PRIMARY KEY,
  administration_id INTEGER NOT NULL REFERENCES administrations(id) ON DELETE CASCADE,
  nom VARCHAR(150) NOT NULL,
  description VARCHAR(255),
  duree_minutes INTEGER NOT NULL DEFAULT 30
);

CREATE TABLE creneaux (
  id SERIAL PRIMARY KEY,
  service_id INTEGER NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  heure_debut TIME NOT NULL,
  heure_fin TIME NOT NULL,
  disponible BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE rendezvous (
  id SERIAL PRIMARY KEY,
  utilisateur_id INTEGER NOT NULL REFERENCES utilisateurs(id) ON DELETE CASCADE,
  creneau_id INTEGER NOT NULL REFERENCES creneaux(id) ON DELETE CASCADE,
  numero_rdv VARCHAR(20) UNIQUE NOT NULL,
  code_qr VARCHAR(255) UNIQUE NOT NULL,
  statut VARCHAR(20) NOT NULL DEFAULT 'confirme' CHECK (statut IN ('confirme', 'annule', 'termine')),
  date_creation TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  utilisateur_id INTEGER NOT NULL REFERENCES utilisateurs(id) ON DELETE CASCADE,
  rendezvous_id INTEGER REFERENCES rendezvous(id) ON DELETE CASCADE,
  message VARCHAR(255) NOT NULL,
  date_envoi TIMESTAMP NOT NULL DEFAULT NOW(),
  lue BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_services_admin ON services(administration_id);
CREATE INDEX idx_creneaux_service_date ON creneaux(service_id, date);
CREATE INDEX idx_rdv_utilisateur ON rendezvous(utilisateur_id);
CREATE INDEX idx_notifications_utilisateur ON notifications(utilisateur_id);
