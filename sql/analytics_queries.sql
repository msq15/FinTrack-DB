-- 1. JOINTURE DE BASE : Historique détaillé des transactions de l'utilisateur "Sophie Bernard"
SELECT 
    t.date_transaction,
    a.nom_entreprise,
    a.ticker_symbol,
    t.type_ordre,
    t.quantite,
    t.prix_unitaire,
    (t.quantite * t.prix_unitaire) AS montant_total
FROM Transactions t
JOIN Portefeuilles p ON t.portefeuille_id = p.id
JOIN Actifs a ON t.actif_id = a.id
JOIN Utilisateurs u ON p.utilisateur_id = u.id
WHERE u.nom = 'Sophie Bernard'
ORDER BY t.date_transaction DESC;


-- 2. AGRÉGATION COMPLEXE : Calcul de la position actuelle par actif dans chaque portefeuille
-- (Quantité ACHAT - Quantité VENTE = Quantité possédée)
SELECT 
    p.nom_portefeuille,
    a.ticker_symbol,
    SUM(CASE WHEN t.type_ordre = 'ACHAT' THEN t.quantite ELSE -t.quantite END) AS quantite_actuelle
FROM Transactions t
JOIN Portefeuilles p ON t.portefeuille_id = p.id
JOIN Actifs a ON t.actif_id = a.id
GROUP BY p.nom_portefeuille, a.ticker_symbol
HAVING SUM(CASE WHEN t.type_ordre = 'ACHAT' THEN t.quantite ELSE -t.quantite END) > 0;


-- 3. SOUS-REQUÊTE / CTE (WITH) : Valorisation totale en temps réel de tous les portefeuilles
-- On croise la quantité actuelle (calculée ci-dessus) avec le TOUT DERNIER prix connu.
WITH PositionsActuelles AS (
    SELECT 
        p.utilisateur_id,
        t.actif_id,
        SUM(CASE WHEN t.type_ordre = 'ACHAT' THEN t.quantite ELSE -t.quantite END) AS qte
    FROM Transactions t
    JOIN Portefeuilles p ON t.portefeuille_id = p.id
    GROUP BY p.utilisateur_id, t.actif_id
),
DerniersPrix AS (
    SELECT 
        actif_id, 
        prix_cloture
    FROM Historique_Prix hp1
    WHERE date_cotation = (SELECT MAX(date_cotation) FROM Historique_Prix hp2 WHERE hp1.actif_id = hp2.actif_id)
)
SELECT 
    u.nom,
    SUM(pa.qte * dp.prix_cloture) AS valorisation_totale_portefeuille
FROM PositionsActuelles pa
JOIN DerniersPrix dp ON pa.actif_id = dp.actif_id
JOIN Utilisateurs u ON pa.utilisateur_id = u.id
GROUP BY u.nom
ORDER BY valorisation_totale_portefeuille DESC;


-- 4. FONCTION DE FENÊTRAGE (WINDOW FUNCTION) : Moyenne mobile sur 7 jours d'une action (ex: AAPL)
SELECT 
    a.ticker_symbol,
    hp.date_cotation,
    hp.prix_cloture,
    ROUND(AVG(hp.prix_cloture) OVER (
        PARTITION BY hp.actif_id 
        ORDER BY hp.date_cotation 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS moyenne_mobile_7j
FROM Historique_Prix hp
JOIN Actifs a ON hp.actif_id = a.id
WHERE a.ticker_symbol = 'AAPL'
ORDER BY hp.date_cotation;