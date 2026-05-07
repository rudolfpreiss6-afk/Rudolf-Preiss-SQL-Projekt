-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH prices AS (
    SELECT DISTINCT
        rok,
        kategorie_potravin,
        prumerna_cena
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf
    WHERE prumerna_cena IS NOT NULL
),
yoy_growth AS (
    SELECT
        kategorie_potravin,
        (((prumerna_cena - LAG(prumerna_cena) OVER (PARTITION BY kategorie_potravin ORDER BY rok)) / 
        LAG(prumerna_cena) OVER (PARTITION BY kategorie_potravin ORDER BY rok)) *100)::numeric AS growth
    FROM prices
),
final AS (
    SELECT
        kategorie_potravin AS potravina,
        ROUND(AVG(growth), 2) AS průměrný_procentuální_růst
    FROM yoy_growth
    WHERE growth IS NOT NULL
    GROUP BY kategorie_potravin
)
SELECT *
FROM final
WHERE průměrný_procentuální_růst > 0 
ORDER BY průměrný_procentuální_růst ASC
LIMIT 1;