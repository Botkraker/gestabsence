-- ============================================
-- Base de données : gest_absence
-- Créer dans phpMyAdmin (XAMPP)
-- ============================================
CREATE DATABASE IF NOT EXISTS gest_absence
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gest_absence;
-- Table des utilisateurs (commun aux 3 rôles)
CREATE TABLE utilisateurs (
id INT AUTO_INCREMENT PRIMARY KEY,
nom VARCHAR(100) NOT NULL,
prenom VARCHAR(100) NOT NULL,
email VARCHAR(150) NOT NULL UNIQUE,
password VARCHAR(255) NOT NULL,
role ENUM('admin','enseignant','etudiant') NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Table des classes
CREATE TABLE classes (
id INT AUTO_INCREMENT PRIMARY KEY,
nom VARCHAR(50) NOT NULL,
niveau VARCHAR(50)
);
-- Table des étudiants (liée à utilisateurs + classes)
CREATE TABLE etudiants (
id INT AUTO_INCREMENT PRIMARY KEY,
utilisateur_id INT NOT NULL,
classe_id INT NOT NULL,
FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
FOREIGN KEY (classe_id) REFERENCES classes(id)
);
-- Table des enseignants
CREATE TABLE enseignants (
id INT AUTO_INCREMENT PRIMARY KEY,
utilisateur_id INT NOT NULL,
specialite VARCHAR(100),
FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);
-- Table des matières
CREATE TABLE matieres (
id INT AUTO_INCREMENT PRIMARY KEY,
nom VARCHAR(100) NOT NULL
);
-- Table des séances
CREATE TABLE seances (
id INT AUTO_INCREMENT PRIMARY KEY,
enseignant_id INT NOT NULL,
classe_id INT NOT NULL,
matiere_id INT NOT NULL,
date_seance DATE NOT NULL,
heure_debut TIME NOT NULL,
heure_fin TIME NOT NULL,
FOREIGN KEY (enseignant_id) REFERENCES enseignants(id),
FOREIGN KEY (classe_id) REFERENCES classes(id),
FOREIGN KEY (matiere_id) REFERENCES matieres(id)
);
-- Table des absences
CREATE TABLE absences (
id INT AUTO_INCREMENT PRIMARY KEY,
seance_id INT NOT NULL,
etudiant_id INT NOT NULL,
statut ENUM('present','absent') NOT NULL DEFAULT 'present',
UNIQUE KEY unique_appel (seance_id, etudiant_id),
FOREIGN KEY (seance_id) REFERENCES seances(id) ON DELETE CASCADE,
FOREIGN KEY (etudiant_id) REFERENCES etudiants(id) ON DELETE CASCADE
);
-- ============================================
-- Données de test
-- ============================================
INSERT INTO utilisateurs (nom,prenom,email,password,role) VALUES
('Admin','Système','admin@school.tn','admin123','admin'),
('Ben Ali','Sami','sami@school.tn','prof123','enseignant'),
('Trabelsi','Amine','amine@school.tn','etu123','etudiant');
INSERT INTO classes (nom,niveau) VALUES ('CI2-A','Cycle Ingénieur 2');
INSERT INTO matieres (nom) VALUES ('Développement Mobile'),('Réseaux'),('BDD');
INSERT INTO enseignants (utilisateur_id,specialite) VALUES (2,'Informatique');
INSERT INTO etudiants (utilisateur_id,classe_id) VALUES (3,1);