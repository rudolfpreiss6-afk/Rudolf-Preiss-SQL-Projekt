-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH wages AS (
    SELECT 
        rok, 
        prumerna_mzda AS wage
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf
    WHERE odvetvi IS NULL
    GROUP BY rok, prumerna_mzda
),
prices AS (
    SELECT 
        rok, 
        AVG(prumerna_cena) AS avg_basket_price
    FROM (
        SELECT DISTINCT rok, kategorie_potravin, prumerna_cena 
        FROM "t_Rudolf_Preiss_project_SQL_primary_final"
    ) sub
    GROUP BY rok
),
growth_comparison AS (
    SELECT 
        w.rok,
        ((w.wage - LAG(w.wage) OVER (ORDER BY w.rok)) / LAG(w.wage) OVER (ORDER BY w.rok) * 100)::numeric AS wage_growth,
        ((p.avg_basket_price - LAG(p.avg_basket_price) OVER (ORDER BY p.rok)) / LAG(p.avg_basket_price) OVER (ORDER BY p.rok) * 100)::numeric AS price_growth
    FROM wages w
    JOIN prices p ON w.rok = p.rok
)
SELECT 
    rok,
    ROUND(wage_growth, 2) AS růst_mezd_v_procentech,
    ROUND(price_growth, 2) AS růst_cen_potravin_v_procentech,
    ROUND(price_growth - wage_growth, 2) AS rozdíl_v_procentech
FROM growth_comparison
WHERE wage_growth IS NOT NULL 
  AND price_growth IS NOT NULL
ORDER BY rok;