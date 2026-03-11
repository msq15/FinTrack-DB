-- ==========================================
-- 1. CRÉATION DES TABLES (DDL)
-- ==========================================

DROP TABLE IF EXISTS Historique_Prix CASCADE;
DROP TABLE IF EXISTS Transactions CASCADE;
DROP TABLE IF EXISTS Portefeuilles CASCADE;
DROP TABLE IF EXISTS Actifs CASCADE;
DROP TABLE IF EXISTS Utilisateurs CASCADE;

CREATE TABLE Utilisateurs (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    date_inscription DATE DEFAULT CURRENT_DATE,
    solde_especes NUMERIC(15, 2) DEFAULT 0.00 CHECK (solde_especes >= 0)
);

CREATE TABLE Actifs (
    id SERIAL PRIMARY KEY,
    ticker_symbol VARCHAR(10) UNIQUE NOT NULL,
    nom_entreprise VARCHAR(100) NOT NULL,
    secteur VARCHAR(50)
);

CREATE TABLE Portefeuilles (
    id SERIAL PRIMARY KEY,
    utilisateur_id INT REFERENCES Utilisateurs(id) ON DELETE CASCADE,
    nom_portefeuille VARCHAR(100) NOT NULL
);

CREATE TABLE Transactions (
    id SERIAL PRIMARY KEY,
    portefeuille_id INT REFERENCES Portefeuilles(id) ON DELETE CASCADE,
    actif_id INT REFERENCES Actifs(id),
    type_ordre VARCHAR(10) CHECK (type_ordre IN ('ACHAT', 'VENTE')),
    quantite NUMERIC(10, 4) NOT NULL CHECK (quantite > 0),
    prix_unitaire NUMERIC(15, 2) NOT NULL CHECK (prix_unitaire > 0),
    date_transaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Historique_Prix (
    actif_id INT REFERENCES Actifs(id) ON DELETE CASCADE,
    date_cotation DATE NOT NULL,
    prix_cloture NUMERIC(15, 2) NOT NULL CHECK (prix_cloture > 0),
    PRIMARY KEY (actif_id, date_cotation)
);

-- ==========================================
-- 2. JEU DE DONNÉES (MOCK DATA)
-- ==========================================

-- Utilisateurs
INSERT INTO Utilisateurs (nom, email, date_inscription, solde_especes) VALUES
('Thomas Martin', 'thomas.m@email.com', '2023-01-15', 5000.00),
('Sophie Bernard', 'sophie.b@email.com', '2023-03-22', 12500.50),
('Lucas Dubois', 'lucas.d@email.com', '2023-06-10', 800.00),
('Emma Petit', 'emma.p@email.com', '2023-09-05', 25000.00),
('Hugo Leroy', 'hugo.l@email.com', '2023-11-20', 3200.00);

-- Actifs (Actions)
INSERT INTO Actifs (ticker_symbol, nom_entreprise, secteur) VALUES
('AAPL', 'Apple Inc.', 'Technologie'),
('MSFT', 'Microsoft Corp.', 'Technologie'),
('LVMH', 'LVMH Moët Hennessy', 'Luxe'),
('TSLA', 'Tesla Inc.', 'Automobile'),
('TTE', 'TotalEnergies SE', 'Énergie'),
('SAN', 'Sanofi', 'Santé'),
('NVDA', 'NVIDIA Corp.', 'Technologie'),
('BNP', 'BNP Paribas', 'Finance'),
('AIR', 'Airbus SE', 'Industrie'),
('OR', 'L''Oréal', 'Biens de consommation');

-- Portefeuilles
INSERT INTO Portefeuilles (utilisateur_id, nom_portefeuille) VALUES
(1, 'PEA Croissance'),
(2, 'Compte Titres Tech'),
(3, 'Portefeuille Débutant'),
(4, 'PEA Dividendes'),
(5, 'Trading Court Terme');

-- Transactions (Historique)
INSERT INTO Transactions (portefeuille_id, actif_id, type_ordre, quantite, prix_unitaire, date_transaction) VALUES
(1, 1, 'ACHAT', 10, 150.00, '2024-01-10 10:00:00'),
(1, 3, 'ACHAT', 5, 750.00, '2024-01-15 11:30:00'),
(2, 2, 'ACHAT', 20, 320.00, '2024-02-01 09:15:00'),
(2, 7, 'ACHAT', 15, 450.00, '2024-02-10 14:20:00'),
(2, 2, 'VENTE', 5, 340.00, '2024-02-28 16:45:00'),
(4, 5, 'ACHAT', 100, 60.00, '2024-03-05 10:10:00'),
(4, 8, 'ACHAT', 50, 55.00, '2024-03-10 09:05:00');

-- Historique Prix (Derniers jours pour AAPL et MSFT)
INSERT INTO Historique_Prix (actif_id, date_cotation, prix_cloture) VALUES
(1, '2024-03-01', 170.50), (1, '2024-03-02', 171.00), (1, '2024-03-03', 169.80),
(1, '2024-03-04', 172.50), (1, '2024-03-05', 173.00), (1, '2024-03-06', 175.20),
(1, '2024-03-07', 174.90), (1, '2024-03-08', 176.00),
(2, '2024-03-08', 405.00),
(3, '2024-03-08', 820.00),
(5, '2024-03-08', 63.50),
(7, '2024-03-08', 850.00),
(8, '2024-03-08', 60.20);